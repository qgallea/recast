# Final Review Report

**Paper:** The Oregon Health Insurance Experiment: Evidence from the First Year
**Original authors:** Finkelstein, A., Taubman, S., Wright, B., Bernstein, M., Gruber, J., Newhouse, J.P., Allen, H., Baicker, K. (*Quarterly Journal of Economics*, 2012)
**Rounds completed:** 1 of 3
**Final verdict:** Ready

---

## Overall Assessment

This RECAST of Finkelstein et al. (2012) is a clean success. The replication is excellent -- all three key specifications (IV/LATE, ITT, first stage) match the published estimates within 1.3% relative deviation. The DoubleML extension using the PLIV model is methodologically appropriate for the IV design and yields a point estimate (0.165) that is approximately 24% larger than the published IV (0.133) but fully compatible statistically: the published coefficient falls well within the DML 95% confidence interval [0.120, 0.209].

The DML extension contributes modest but real value over the original paper. It demonstrates that the IV results are robust to flexible, data-driven estimation of nuisance functions -- a useful confirmation, though not surprising given the strength of the experimental design. The near-identical estimates across Random Forest (0.164) and LassoCV (0.165) further reinforce robustness. The GATE analysis by household size is a reasonable first pass at heterogeneity, finding suggestive evidence that two-person households benefit more from Medicaid than single-person households, though the confidence intervals overlap.

The paper would be publishable as a short replication-and-extension note in its current form. The main limitation is the narrow scope -- only one outcome (self-reported health) is RECASTed, and only two ML learners are tested. The nuisance model FAIL is well-explained as a feature of the randomized design, not a bug.

---

## What Was Solved During Revision

| Issue | Raised (round) | Resolved (round) | How |
|-------|---------------|-----------------|-----|
| LATE estimand not restated in DML section | 1 | 1 | Added explicit sentence clarifying PLIV targets same LATE as 2SLS |
| Diagnostics table FAIL misleading without qualifier | 1 | 1 | Added dagger footnote and explanatory text in the table |
| GATE CIs mislabeled as "joint" (actually pointwise) | 1 | 1 | Corrected labels in table and figure caption |
| Magnitude difference inconsistent (24.1% vs 23.9%) | 1 | 1 | Harmonized to "approximately 24%" |
| Sample size discrepancy not documented | 1 | 1 | Added explanation of 380-observation difference (missing covariate values) |
| Heterogeneity claim overstated | 1 | 1 | Softened to "suggestive evidence"; noted overlapping CIs |
| First-stage F not discussed for DML | 1 | 1 | Added note that instrument remains strong in DML context |
| No explanation for absent causal forest | 1 | 1 | Added rationale (IV design + categorical covariate) |
| ITT and first-stage not discussed in text | 1 | 1 | Added specific estimates to replication section |
| Missing limitations discussion | 1 | 1 | Added limitations paragraph to conclusion |
| DML-IV magnitude difference unexplained | 1 | 1 | Added discussion of possible drivers (sample diff, FE handling, cross-fitting) |
| Learner selection criterion ad hoc | 1 | 1 | Reframed as robustness across learners rather than "preferred" |
| Only two learners tested | 1 | 1 | Acknowledged as limitation; suggested boosting as extension |

---

## Remaining Issues

| # | Issue | Severity | Action needed |
|---|-------|----------|---------------|
| -- | None | -- | -- |

All issues identified in Round 1 were resolved through paper.tex edits. No blocking issues requiring notebook re-runs were identified.

*Severity: **Blocking** = must fix before sharing -- **Major** = should fix -- **Minor** = optional*

---

## Key Results

| Specification | Estimate | SE | 95% CI | N |
|--------------|----------|----|--------|---|
| Original paper (2SLS/IV) | 0.133 | 0.026 | [0.082, 0.184] | 23,741 |
| Our replication (2SLS/IV) | 0.132 | 0.026 | [0.081, 0.184] | 23,361 |
| DML preferred (LassoCV) | 0.165 | 0.023 | [0.120, 0.209] | 23,361 |
| DML alternative (RandomForest) | 0.164 | 0.023 | [0.119, 0.208] | 23,361 |

**Replication check:** PASS -- delta = 1.3% vs paper (worst across 3 specs)

**DML shift:** The preferred DML estimate is 0.165 vs IV 0.133 -- an upward shift of approximately 24% in magnitude. The published coefficient falls inside the DML 95% CI, so the estimates are statistically compatible. The DML standard error (0.023) is slightly smaller than the published SE (0.026), reflecting marginally more precise estimation.

---

## Notes for the Reader

- **Nuisance R-squared is low by design.** The outcome R-squared is 0.004 and the treatment R-squared is -0.28 (worse than predicting the mean). This is expected in a randomized lottery experiment where treatment assignment is independent of covariates. The DML Neyman-orthogonal score is robust to poor nuisance estimation, so this does not invalidate the results.

- **GATE heterogeneity is suggestive, not conclusive.** The numhh=1 (0.144) and numhh=2 (0.252) estimates have overlapping confidence intervals. The numhh=3 estimate (-1.336, N=57) is unreliable and should be ignored. No formal test of heterogeneity across groups is performed.

- **Only one outcome is RECASTed.** The original paper examines health care utilization, financial strain, and multiple health outcomes. Extending to additional outcomes would strengthen the analysis.

- **The pipeline cannot verify data provenance or the original randomization.** We take the lottery as random because the original authors demonstrate balance in the published paper. This RECAST relies on the same data and cannot independently verify data integrity.

- **Survey weights are used in the replication but not in DML.** The DoubleML framework does not natively support survey weights. The DML estimates are unweighted, which could contribute to the 24% magnitude difference. Testing sensitivity to weighting is a natural robustness check that would require manual implementation.
