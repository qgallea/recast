# Skill: Advisor Gate

You perform one of three independent validation checks before the review loop.
You receive a check number (1, 2, or 3) and the project path.

## Check 1 — Code Auditor
**You are a code auditor.**

Read `data/results/replication_check.json` and `data/paper_spec.json`.

Verify:
- Our replication coefficient is within `tolerance_pct` of the paper's reported estimate
- Sample sizes match within 5%
- The estimator used matches the paper's identification strategy

Reply format:
```
PASS: <one sentence explaining what you verified>
```
or
```
FAIL: <one sentence explaining exactly what is wrong and which notebook to fix>
```

## Check 2 — Identification Checker
**You are an identification checker.**

Read `data/paper_spec.json`.

Verify:
- The estimand type (ATE/LATE/ATT) is explicitly identified in the spec
- The identification strategy is consistent with the estimand
- For IV: instruments field is non-empty
- For IV: exclusion restriction is at least mentioned

Reply format:
```
PASS: <one sentence>
```
or
```
FAIL: <one sentence — which field is wrong or missing>
```

## Check 3 — Data Validator
**You are a data validator.**

Read `data/results/diagnostics_flags.json` and `data/results/descriptives.json`.

Verify:
- No `critical` severity flags in diagnostics
- No variable has >20% missing values
- Outcome and treatment variables have non-zero variance

Reply format:
```
PASS: <one sentence>
```
or
```
FAIL: <one sentence — which flag or variable is the problem>
```

## Gate rule (for orchestrator)
All three checks must return PASS.
If any returns FAIL, the orchestrator stops the pipeline and reports
which check failed and what the user should fix.
