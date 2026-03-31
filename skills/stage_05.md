# Skill: Stage 05 — Diagnostics

## Your job
Run automated checks on the replication and DML results. Produce a structured
JSON of flags that the Advisor Gate uses to decide whether to proceed.

## Files you read
- `data/results/replication_check.json`
- `data/results/replication_results.json`
- `data/results/dml_results.json` (optional — skip Checks 2–4 if absent; CF-only pipeline)
- `data/results/hte_results.json` (optional — skip Check 6 if absent)
- `data/results/causal_forest_results.json` (optional — skip Checks 7–8 if absent)
- `data/paper_spec.json`

## Files you write
- `data/results/diagnostics_flags.json`

## Checks to run

### Check 1: Replication pass
```
PASS if replication_check.json["pass"] == true
WARN if worst_rel_diff_pct in [5, 15]
FAIL if worst_rel_diff_pct > 15
```

### Check 2: DML coefficient direction
```
Source: dml_results.json (skip if file does not exist — CF-only pipeline)
PASS if sign(dml_results["preferred_coef"]) == sign(published main coef)
WARN if abs(dml - published) / abs(published) > 0.5
FAIL if sign_change == true
```

### Check 3: DML confidence interval coverage
```
Source: dml_results.json (skip if file does not exist — CF-only pipeline)
PASS if published main coef is inside dml CI
WARN if published coef is outside DML CI but within 1 SE
FAIL if published coef is > 2 SE outside DML CI
```

### Check 4: Nuisance model quality
```
Source: dml_results.json (skip if file does not exist — CF-only pipeline)
PASS if r2_outcome > 0.3 and r2_treatment > 0.3
WARN if either r2 in [0.1, 0.3]
FAIL if either r2 < 0.1
```

### Check 5: Sample size
```
PASS if n_obs >= 50
WARN if n_obs in [30, 50]
FAIL if n_obs < 30
```

### Check 6: HTE heterogeneity signal
```
Source: hte_results.json (skip entirely if file does not exist)
PASS if heterogeneity_detected == true (at least two GATE CIs do not overlap)
WARN if all GATE CIs overlap (treatment effect appears homogeneous across groups)
```

### Check 7: Causal forest ATE consistency
```
Source: causal_forest_results.json (skip entirely if file does not exist)

If dml_results.json exists (DML+CF pipeline):
  PASS if sign(cf_ate) == sign(dml preferred_coef) and abs(cf_ate - dml) / abs(dml) < 0.5
  WARN if sign matches but magnitude differs by > 50%
  FAIL if sign_change_vs_dml == true

If dml_results.json does NOT exist (CF-only pipeline):
  Compare CF ATE against published coefficient instead:
  PASS if sign(cf_ate) == sign(published main coef)
  WARN if abs(cf_ate - published) / abs(published) > 0.5
  FAIL if sign_change_vs_published == true
```

### Check 8: Causal forest CATE plausibility
```
Source: causal_forest_results.json (skip entirely if file does not exist)
PASS if 0.10 < pct_significant < 0.95
WARN if pct_significant < 0.10 (forest may lack power) or pct_significant > 0.95 (suspiciously precise)
FAIL if pct_significant > 0.99 and n_obs < 200 (almost certainly overfitting)
```

### Check 9: ATE SE plausibility
```
Source: causal_forest_results.json AND hte_results.json (skip if either absent)

Compute: ate_ci_width = ate_ci_hi - ate_ci_lo
         mean_cate_ci_width = mean of (ci_hi - ci_lo) across GATE groups from hte_results.json
         ratio = mean_cate_ci_width / ate_ci_width

PASS if ratio < 5 (ATE CI is narrower than CATE CIs, but not implausibly so)
WARN if ratio in [5, 10] (ATE CI is suspiciously narrow relative to individual estimates)
FAIL if ratio > 10 (ATE SE is almost certainly computed incorrectly — likely using std/sqrt(n)
      instead of predict_interval bounds; this is a BLOCKING bug)
```
This check catches the common mistake of computing ATE SE as `std(CATEs)/sqrt(n)`,
which treats individual CATEs as known values and produces implausibly narrow CIs.

## Output schema: `diagnostics_flags.json`
```json
{
  "overall": "PASS",
  "checks": {
    "replication_pass": {"status": "PASS", "value": 1.6, "note": "1.6% max diff"},
    "dml_direction": {"status": "PASS", "value": -0.134, "note": "same sign as published"},
    "dml_ci_coverage": {"status": "WARN", "value": -0.089, "note": "published coef at edge of CI"},
    "nuisance_quality": {"status": "PASS", "value": {"r2_outcome": 0.72, "r2_treatment": 0.68}},
    "sample_size": {"status": "PASS", "value": 145},
    "hte_heterogeneity": {"status": "WARN", "value": false, "note": "all GATE CIs overlap — homogeneous effect"},
    "cf_ate_consistency": {"status": "PASS", "value": -0.128, "note": "same sign, 4.5% magnitude diff vs DML"},
    "cf_cate_plausibility": {"status": "PASS", "value": 0.72, "note": "72% of individual CATEs significant"}
  },
  "blocking_issues": [],
  "warnings": ["dml_ci_coverage: published coef near edge of DML CI"]
}
```

`overall`:
- `PASS` — all checks PASS or WARN
- `WARN` — one or more WARNs, no FAILs
- `FAIL` — any check is FAIL (blocks Advisor Gate)

### Check 10: Cross-fitting stability
```
Source: dml_results.json — per_rep_coefs in Best learner of primary spec
(skip if per_rep_coefs not available)
Compute: sd_across_reps = std(per_rep_coefs)
         median_se = median(per_rep_ses)

PASS if sd_across_reps < 0.5 * median_se (stable across splits)
WARN if sd_across_reps in [0.5, 1.0] * median_se
FAIL if sd_across_reps > median_se (estimates vary wildly across random splits)
```

### Check 11: Learner sign agreement
```
Source: dml_results.json — all learner coefficients for primary spec
(skip if only one learner)
Count how many individual learners (excluding Ensemble/Best) agree on sign.

PASS if all learners agree on sign
WARN if majority (>50%) agree but one or two disagree
FAIL if learners split evenly on sign (no robust directional finding)
```

### Check 12: Lasso variable selection
```
Source: dml_results.json — lasso_diagnostics for primary spec
(skip if Lasso not among learners or lasso_diagnostics is null)

PASS if n_nonzero > 0 for both outcome and treatment nuisance models
WARN if n_nonzero == 0 for either model (Lasso is predicting the mean — degenerate)
```

## Rules
- A FAIL in any single check sets `overall = FAIL`
- List all FAIL checks in `blocking_issues`
- Write the file even if all checks fail
