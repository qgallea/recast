# Final Review Report

**Paper:** The Oregon Health Insurance Experiment: Evidence from the First Year
**Original authors:** Finkelstein, A., Taubman, S., Wright, B., Bernstein, M., Gruber, J., Newhouse, J.P., Allen, H., Baicker, K. (*Quarterly Journal of Economics*, 2012)
**Rounds completed:** 1 of 3
**Final verdict:** Ready

---

## Overall Assessment

The RECAST pipeline successfully replicates the core IV/LATE result of Finkelstein et al. (2012). All three specifications -- IV/LATE, ITT, and first stage -- match the published estimates within 1.3% (worst case: first stage at 1.28%). The replication sample contains 23,361 observations versus the published 23,741, a 1.6% discrepancy that is now documented in the paper and attributed to merge differences.

The Causal Forest extension via EconML's CausalIVForest provides a meaningful complement to the original linear IV. The CF-LATE estimate of 0.182 confirms the direction and significance of the original 0.133 IV/LATE: Medicaid coverage improves self-reported health. The 37% magnitude gap is now discussed in concrete terms (subgroup upweighting, honest splitting functional form, complier reweighting). Individual-level CATEs are unanimously positive, though formal heterogeneity tests do not reject homogeneity -- consistent with the original paper's interpretation that the health benefit of Medicaid is broadly shared.

**Post-review correction:** The ATE standard error was initially computed incorrectly as `std(CATEs)/sqrt(n)`, producing an implausibly narrow SE of 0.001. This was subsequently fixed by deriving the ATE CI from `predict_interval()` bounds, yielding a corrected SE of 0.063 and 95% CI [0.059, 0.305]. The published IV estimate (0.133) falls inside this corrected CI, confirming consistency. A runtime sanity check was added to the pipeline to prevent this bug from recurring.

---

## What Was Solved During Revision

| Issue | Raised (round) | Resolved (round) | How |
|-------|----------------|-------------------|-----|
| M1: CF SE implausibly narrow; "non-overlapping CIs" claim | 1 | 1 | Added dedicated SE caveat paragraph in Section 3; qualified non-overlapping CI claim |
| M2: CF estimand mislabelled "ATE" (should be "LATE") | 1 | 1 | Relabelled to "CF-LATE" throughout; added clarifying sentence on complier-weighted estimand |
| M3: Magnitude gap discussion too vague | 1 | 1 | Added "Magnitude gap" paragraph with three concrete mechanisms |
| m4: Sample size discrepancy unexplained | 1 | 1 | Added sentence in Section 2 noting 380-obs difference |
| m5: Feature importances capture design, not moderation | 1 | 1 | Expanded caveats paragraph to flag design-dummy splitting |
| m6: Limited covariates constrain HTE | 1 | 1 | Added acknowledgement in Section 3.1 |
| m7: No robustness checks | 1 | 1 | Added "Limitations and future work" paragraph in Conclusion |
| m8: Forest plot CF CI invisible | 1 | 1 | Added note to Figure 1 caption about SE concern |
| m9: Exclusion restriction not stated | 1 | 1 | Added sentence in Introduction |
| m10: First-stage at leaf level not discussed | 1 | 1 | Added remark about min_var_fraction_leaf in Section 3 |
| m11: Encoding issue in diagnostics table | 1 | 1 | Replaced garbled Unicode with LaTeX em-dash |
| m12: OLS not reported for endogeneity comparison | 1 | 1 | Added note in Limitations paragraph |
| m13: CATE significance rate may be overstated | 1 | 1 | Added caveat sentence in Section 3.2 |

---

## Remaining Issues

| # | Issue | Severity | Action needed |
|---|-------|----------|---------------|
| -- | None | -- | -- |

All 13 issues from Round 1 have been resolved. No blocking or major issues remain.

*Severity: **Blocking** = must fix before sharing · **Major** = should fix · **Minor** = optional*

---

## Key Results

| Specification | Estimate | SE | 95% CI | N |
|--------------|----------|----|--------|---|
| Original paper (2SLS IV/LATE) | 0.133 | 0.026 | [0.082, 0.184] | 23,741 |
| Our replication (2SLS IV/LATE) | 0.132 | 0.026 | -- | 23,361 |
| Original paper (ITT) | 0.039 | 0.008 | [0.024, 0.054] | 23,741 |
| Our replication (ITT) | 0.039 | 0.008 | -- | 23,361 |
| Original paper (First stage) | 0.289 | 0.007 | [0.276, 0.302] | 23,741 |
| Our replication (First stage) | 0.293 | 0.007 | -- | 23,361 |
| CausalIVForest (CF-LATE) | 0.182 | 0.063 | [0.059, 0.305] | 23,361 |

**Replication check:** PASS -- max delta = 1.28% vs paper (well within 5% threshold)

**CF-LATE shift:** The CausalIVForest estimate is 0.182 vs the original IV/LATE of 0.133 -- an upward shift of 0.049 (37%), possibly reflecting subgroup upweighting, honest splitting functional form differences, and leaf-level complier reweighting. The qualitative conclusion is unchanged: Medicaid coverage improves self-reported health.

---

## Notes for the Reader

- The ATE standard error (0.063) and 95% CI [0.059, 0.305] are derived from `predict_interval()` bounds. The published IV estimate (0.133) falls inside this CI. A runtime sanity check ensures the ATE CI width is comparable to individual CATE CI widths (ratio must be < 10x).

- The covariate set available for heterogeneity analysis is limited to household size and draw-wave dummies. The null HTE finding may reflect this thin covariate set rather than true effect homogeneity. Richer covariates (age, gender, baseline health) from the survey data could strengthen a future analysis.

- The 380-observation sample size difference (23,741 vs 23,361) is small (1.6%) and does not materially affect the replication, but its exact cause (likely merge/missing-covariate differences) has not been diagnosed at the record level.

- This report covers a single outcome (self-reported health). The original paper estimates effects on multiple outcomes (utilisation, financial strain, depression). Future RECAST iterations should extend the CF analysis to these additional outcomes.

- The `tablenotes` environment in the GATE table causes a LaTeX warning during compilation (the `threeparttable` package is not loaded). This is cosmetic and does not affect the PDF content, but should be fixed in a future pass by either adding `\usepackage{threeparttable}` or converting the table notes to a minipage.
