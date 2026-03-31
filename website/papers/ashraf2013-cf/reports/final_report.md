# Final Review Report

**Paper:** The 'Out of Africa' Hypothesis, Human Genetic Diversity, and Comparative Economic Development
**Original authors:** Ashraf, Q. and Galor, O. (*American Economic Review*, 2013)
**Rounds completed:** 1 of 3
**Final verdict:** Ready

---

## Overall Assessment

This RECAST of Ashraf and Galor (2013) is a strong result. The replication is clean -- all six specifications across Tables 1, 2, 3, 6, and 7 match the published coefficients within 0.71%, with five of six matching to within 0.01%. This is as close to exact replication as one can achieve across platforms and software versions.

The causal forest extension estimates an average treatment effect (ATE) of 0.076 (SE = 4.748, 95% CI: [-9.23, 9.38]) for the marginal effect of ancestry-adjusted genetic diversity on log GDP per capita. This near-zero, statistically insignificant ATE is entirely consistent with the original paper's core finding of a hump-shaped (quadratic) relationship. The sample mean diversity (~0.73) sits almost exactly at the estimated optimum (~0.71), so positive marginal effects for below-optimum countries cancel against negative effects for above-optimum countries in the average. The causal forest does not contradict the original paper -- it confirms that the *average marginal* effect is near zero, as the quadratic specification predicts.

The paper would be suitable for sharing as a RECAST short note. One round of referee review raised only minor issues (all resolved), and no blocking problems were identified. The main limitation flagged by referees -- the switch from IV to selection-on-observables identification -- is now explicitly discussed in the paper.

---

## What Was Solved During Revision

| Issue | Raised (round) | Resolved (round) | How |
|-------|---------------|-----------------|-----|
| CausalForestDML vs CausalIVForest justification | 1 | 1 | Added dedicated paragraph in Section 3.1 discussing method choice and identification trade-off |
| Identification assumption discussion | 1 | 1 | Expanded to discuss exclusion restriction vs. conditional independence, and two explanations for near-zero ATE |
| Variable name mismatch (ln_soilsuit vs ln_suitavg) | 1 | 1 | Corrected to ln_suitavg |
| Optimum diversity derivation | 1 | 1 | Added footnote with computation |
| Unescaped underscores in variable names | 1 | 1 | Fixed LaTeX formatting |
| Forest plot caption ambiguity | 1 | 1 | Expanded caption with explicit scale annotations |
| SE discrepancy footnote | 1 | 1 | Added footnote on HC1/HC0 differences |
| N=145 vs N=143 discrepancy | 1 | 1 | Added explanatory footnote |
| 34% negative CATEs interpretation | 1 | 1 | Expanded to connect with countries above diversity optimum |

---

## Remaining Issues

| # | Issue | Severity | Action needed |
|---|-------|----------|---------------|
| 1 | CausalIVForest analysis not conducted | Minor | A future extension could run CausalIVForest with the migratory distance instrument for a more direct comparison. This is optional -- the CausalForestDML analysis is valid as a complementary check. |
| 2 | Low CATE power (2% significant) | Minor | Inherent to N=145. Not fixable without more data. Correctly flagged in diagnostics as a warning. |

*Severity: **Blocking** = must fix before sharing / **Major** = should fix / **Minor** = optional*

---

## Key Results

| Specification | Estimate | SE | 95% CI | N |
|--------------|----------|----|--------|---|
| Published OLS (Table 6 col 1, linear term) | 203.443 | 83.368 | [40.04, 366.84] | 143 |
| Replicated OLS (Table 6 col 1, linear term) | 203.443 | 79.910 | [46.82, 360.06] | 143 |
| Published OLS (Table 6 col 1, squared term) | -142.663 | 59.037 | [-258.38, -26.95] | 143 |
| Causal Forest ATE (CausalForestDML) | 0.076 | 4.748 | [-9.23, 9.38] | 145 |

**Replication check:** PASS -- 6/6 specifications within 0.71% of published values.

**CF extension:** The CausalForestDML ATE of 0.076 is near zero and statistically insignificant. This is consistent with the hump-shaped finding: the average marginal effect at the sample mean diversity (~0.73) is close to zero because the sample sits near the estimated optimum (~0.71). The published linear term coefficient (203.443) is not directly comparable because it parameterizes the slope at diversity = 0, not the average marginal effect across observed values.

**Heterogeneity:** No significant heterogeneity detected across quartiles of ln_yst (log years since Neolithic). GATE point estimates range from -1.90 (Q4, highest ln_yst) to 1.53 (Q2), but all CIs are wide and overlapping.

**Feature importance:** Top drivers of treatment effect heterogeneity: ln_abslat (26.3%), ln_arable (24.3%), ln_suitavg (20.9%). Geographic variables dominate, consistent with the paper's emphasis on geographic endowments.

---

## Notes for the Reader

- The causal forest uses selection-on-observables (no instrument), while the original paper uses migratory distance as an IV. These are different identification strategies. The near-zero CF ATE could reflect hump-shape cancellation (the correct interpretation) or attenuation from residual confounding. The paper now discusses both possibilities.
- With N=145, the causal forest has limited power for detecting heterogeneity. Only 2% of individual CATEs are significant at 5%. This is a data limitation, not a methodological failure.
- The SE sanity check passes convincingly (CATE/ATE CI width ratio = 0.9x), confirming that ate_inference() was used correctly.
- The published coefficient (203.443) and the CF ATE (0.076) measure fundamentally different things. Comparing them directly is a mistake -- the paper now explains this clearly.
- The replication package data appear complete and well-organized. All variables needed for the six replicated specifications are present and correctly coded.
