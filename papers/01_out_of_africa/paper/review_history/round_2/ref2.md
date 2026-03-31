## Referee 2 Report: DML Methods
**Round:** 2
**Overall verdict:** Major concerns

---

### Blocking issues

- None. The Round 1 blocking issues (degenerate RF nuisance R² computation and missing LassoCV nuisance R²) are resolved in principle: `dml_results.json` now documents `rf_nuisance_degenerate: true` with `rf_r2_treatment: null`, LassoCV nuisance R² values are computed and stored (`lasso_r2_outcome=0.409`, `lasso_r2_treatment=-97090`), and the forest plot has been regenerated excluding the degenerate RF row.

---

### Major issues

1. **Paper text is out of sync with revised `dml_results.json`.** The paper (`paper.tex`) continues to report the pre-revision LassoCV estimate of $\hat{\theta} = -23.19$ (SE $= 5.65$, 95% CI $[-34.27,\,-12.11]$, $p < 0.001$) in the abstract (line 32), the results subsection (line 166), and the Interpreting the Sign Change subsection (line 192). The revised `dml_results.json` reports `coef = -25.471`, `se = 5.643`, `ci_lo = -36.531`, `ci_hi = -14.410`. These are materially different values. Every quoted number in the paper must be updated to match the current JSON output.

2. **Diagnostics table in the paper contains stale and incorrect values.** Table 3 (Diagnostic Checks) cites `$R^2_D = -127\,810$` (line 237) — this is the pre-correction buggy value now superseded by the revised computation. It also reports `$R^2_Y = 0.50$` (line 247) as the LassoCV nuisance quality indicator, but the revised `lasso_r2_outcome = 0.409`. The table also describes the RF degenerate coefficient as `$\hat{\theta} = -286.33$, SE $= 378.63$` (line 169 in body text), while `dml_results.json` now records `coef = -588.594`, `se = 1218.712`. All stale values must be corrected before this paper can be considered finalised.

3. **LassoCV treatment nuisance R² is also non-positive (`-97,090`) and remains unexplained in the paper.** The diagnostics flag this as a "DoubleML prediction index artifact, not a model failure," and `dml_results.json` carries a note to this effect. However, the paper itself offers no explanation to the reader. This matters because a reader cannot independently verify that LassoCV is a valid preferred learner if its reported treatment nuisance R² is as extreme as that of the rejected RF learner. The paper must either (a) report the DoubleML-native `ml_m` RMSE values (from the printed fit summary: ~5.71–5.77 across reps) as the primary nuisance quality metric, alongside an explanation of why the prediction-array R² is uninformative for PLIV treatment nuisance, or (b) compute the R² correctly. Without this, the reader has no basis to prefer LassoCV over RF on nuisance quality grounds.

---

### Minor issues

1. **Learner diversity is limited.** The nuisance learner grid contains only Random Forest and LassoCV. Standard practice in DML applications includes at least one ensemble method (e.g., gradient-boosted trees) or an additional penalised regression variant (e.g., ElasticNet or Ridge) to confirm that the preferred estimate is not sensitive to this binary choice. With only two learners — one of which is degenerate — the LassoCV estimate cannot be validated against an independent comparator.

2. **N_rep=3 is modest; no check for rep-to-rep stability is reported.** With K=5 and N_rep=3, the estimate is averaged over 15 independent train/test splits. The paper does not report the range or standard deviation of the coefficient across the 3 repetitions. Given that the LassoCV RMSE for `ml_m` varies from 5.71 to 5.77 across reps (near-stable), this is unlikely to be a substantive concern, but the analysis is silent on it.

3. **Minimum fold size marginally below rule of thumb.** With N=148 and K=5, the minimum fold size is approximately 29 (148 / 5 = 29.6), which is marginally below the K × min_fold_size > 30 rule of thumb. This is not a serious concern at this sample size, but should be acknowledged or addressed by reducing to K=4 (min fold size ~37) if the authors wish to be conservative.

4. **Forest plot caption and figure description are inconsistent with revised content.** The figure caption (line 183) states "OLS (Tables 1, 3, 6, 7), 2SLS (Table 2), and DML-PLIV (LassoCV)" but the revised forest plot contains only OLS (Tables 6 and 7) and DML-PLIV LassoCV. The caption must match the actual figure content.

---

### Comments to the authors

The core methodological choices remain sound. `DoubleMLPLIV` is the correct model class for an explicitly IV-based design, and the `partialling out` score function (confirmed from the fit summary printed in the notebook) is appropriate for PLIV. Cross-fitting with K=5 and N_rep=3 is a reasonable default. The LassoCV coefficient of approximately $-25.5$ (SE $\approx 5.6$) is statistically precise and internally consistent with the RMSE values reported by DoubleML's own fit summary (`ml_l` RMSE ~0.91, `ml_m` RMSE ~5.73 across reps), which confirm the nuisance models are fitting. Confidence intervals are drawn from `obj_lasso.confint()` and `.se[0]`, i.e., from the DML asymptotic variance estimator, not from naive OLS post-residualisation. This is correct.

The most pressing unresolved problem is the disconnect between the revised `dml_results.json` and the paper text. The revision round updated the JSON correctly but did not propagate the new numbers back into `paper.tex`. Every hard-coded coefficient, standard error, confidence bound, and nuisance R² value in the paper currently refers to a superseded run. Until the paper text matches the JSON, the document is internally inconsistent, and a reader comparing the abstract to the table will find irreconcilable numbers.

The LassoCV treatment nuisance R² of $-97,090$ requires explicit treatment in the paper. The note in `dml_results.json` correctly identifies this as a prediction-array indexing artifact arising from how cross-fitted predictions are aggregated before calling `r2_score`, not from a failure of the LassoCV model itself. The evidence for LassoCV performing adequately on the treatment nuisance is the DoubleML-reported `ml_m` RMSE of approximately 5.73, which can be compared against the raw standard deviation of `pdiv_aa` to yield an approximate out-of-sample R² in the conventional sense. The paper should present this calculation explicitly and retire the artifactual $-97,090$ figure as a reported result; it should appear only in a footnote or appendix as a documented artifact.

Finally, while the learner grid concern is minor, the pipeline would benefit from adding at least one additional learner (e.g., GradientBoostingRegressor or ElasticNetCV) in a future revision to demonstrate robustness of the $\approx -25.5$ estimate. With only two learners and one degenerate, the single surviving estimate has no within-pipeline comparator. This is a limitation that should at minimum be acknowledged in the paper's limitations paragraph.

---

**Summary for the revision agent:** Three paper-text corrections are required before this report can be downgraded to Minor concerns: (1) update all hard-coded DML numbers in `paper.tex` to match current `dml_results.json` values; (2) replace the stale diagnostics table entries ($R^2_D = -127\,810$, $R^2_Y = 0.50$, RF coef $= -286.33$) with current values or RMSE-based alternatives; (3) add a brief explanation in the paper of why the LassoCV treatment nuisance R² is reported as a large negative number and what the correct quality metric is.
