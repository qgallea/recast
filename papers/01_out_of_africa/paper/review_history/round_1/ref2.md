## Referee 2 Report: DML Methods
**Round:** 1
**Overall verdict:** Major concerns

---

### Blocking issues

- **RF nuisance R² for treatment is -127,810**: The Random Forest learner produces a treatment nuisance R² of -127,810.35 (`nuisance_r2_treatment = -127810.347` in `dml_results.json`). This is not merely a weak instrument problem — it is a computational pathology. The RF `ml_m` predictions are mean-averaged across 3 repetitions from `obj_rf.predictions['ml_m']`, but the displayed RMSE values per fold (~2.61, ~2.74, ~2.68) are plausible. The catastrophically negative R² arises because the average of predictions across repetitions does not align with the actual treatment values in a way that `r2_score` can interpret correctly when the predictions are indexed or aligned incorrectly. The code computes `d_pred = obj_rf.predictions['ml_m'].mean(axis=1).squeeze()` — if this array is not properly aligned with `dml_data.d`, the R² will be spurious. This blocking issue means the RF learner results cannot be trusted and must be either corrected or excluded entirely. The paper correctly excludes RF as the preferred learner, but the degenerate R² figure is logged in `nuisance_scores` and is misleading to any reader of `dml_results.json`.

- **LassoCV nuisance R² values are not reported for the preferred learner**: The `dml_results.json` stores `nuisance_scores` with only the RF values (`r2_outcome = 0.505`, `r2_treatment = -127810.347`). No nuisance R² is stored or reported for the LassoCV preferred learner. The code cell for LassoCV (`cell id 087e4487`) does not compute or store nuisance R² values — `lasso_results` contains only `coef`, `se`, `ci_lo`, `ci_hi`, `pval`. The paper states nuisance R² values are reported, but only the RF values appear in the JSON. This is a blocking gap: without LassoCV nuisance R², it is impossible to assess whether the preferred learner achieves adequate outcome and treatment fit.

---

### Major issues

- **Learner grid is not diverse enough**: Only two learners are evaluated — RandomForest and LassoCV. The checklist requires the grid to span linear, tree-based, and ensemble methods. LassoCV covers the linear family; RandomForest covers tree-based/ensemble. However, no gradient boosting (e.g., `GradientBoostingRegressor` or XGBoost), no ridge regression, and no ElasticNet are included. For a sample of N=148 with 8 covariates, additional learner diversity is both feasible and important for selecting the best-fitting nuisance specification. The current grid is minimal.

- **Score function is `partialling out` for a PLIV model**: The notebook output confirms `Score function: partialling out` for both RF and LassoCV PLIV objects. In `doubleml`, `DoubleMLPLIV` supports both `'partialling out'` and `'IV-type'` scores. The `'partialling out'` score in PLIV is correct under the Chernozhukov et al. (2018) formulation, but requires a third nuisance learner `ml_r` to model `E[Z|X]` (the instrument residual). The code supplies `ml_r_rf` and `ml_r_lasso` correctly, and the RMSE for `ml_r` (RF: ~0.003; Lasso: ~0.021) is very low, suggesting the instrument is nearly perfectly predicted from covariates. This raises an exclusion restriction concern (if Z is predictable from X, the instrument may not be truly exogenous conditional on X), though this is primarily an identification issue. From a DML methods standpoint, the near-zero `ml_r` RMSE deserves explicit discussion in the paper, which is currently absent.

- **N_reps = 3 is borderline for assessing sampling variability**: With N=148 and K=5 folds (min fold size = 29, slightly below the rule-of-thumb threshold of 30), using only 3 repetitions provides limited ability to assess the variance of cross-fitting splits. The paper does not report whether the coefficient or standard error varies substantially across the 3 repetitions. The LassoCV RMSE values across repetitions (~0.897, ~0.926, ~0.908 for outcome; ~5.718, ~5.700, ~5.751 for treatment) suggest moderate stability, but the DML theta estimate variance across repetitions is not reported. The paper should either increase N_reps to at least 10 or report within-repetition variance to validate stability.

---

### Minor issues

- **Min fold size is 29 (below the rule-of-thumb of 30)**: With N=148 and K=5, the minimum fold size for the held-out set is 29 (148/5 = 29.6, so at least one fold has 29 observations). The rule of thumb K × min_fold_size > 30 is satisfied marginally (5 × 29 = 145 > 30), but the min fold size itself is below 30. This is not a blocking issue but merits acknowledgment, particularly given the moderate number of covariates (8) relative to fold size.

- **CIs are correctly computed from DML standard errors**: The paper reports CIs as `[-34.27, -12.11]`, matching `obj_lasso.confint()` output exactly (`[-34.265649, -12.113749]`). This confirms CIs are drawn from DML asymptotic standard errors, not naive OLS SEs post-residualisation. No issue here; noted for completeness.

- **`DoubleMLPLIV` is the correct model class**: Given the paper's IV design (instrument = migratory distance from East Africa), `DoubleMLPLIV` is appropriate. `DoubleMLPLR` would be incorrect because it assumes no instrument. The choice is correct and consistent with the specification in the paper.

- **The preferred learner selection heuristic is ad hoc but reasonable**: The code switches from RF to LassoCV if `r2_treatment < 0` or `se_RF > 10 × se_Lasso`. This heuristic correctly identifies the RF degenerate case, but is not a principled information criterion. A more rigorous approach would compare out-of-sample RMSE for both learners on all three nuisance components and select the learner minimising total nuisance prediction error.

---

### Comments to the authors

The model class selection (`DoubleMLPLIV`) is appropriate for this design, and the use of the `partialling out` score with a third nuisance learner for `E[Z|X]` follows Chernozhukov et al. (2018) correctly. The LassoCV preferred estimate ($\hat{\theta} = -23.19$, SE $= 5.65$, 95% CI $= [-34.27, -12.11]$, $p < 0.001$) is precisely estimated and the CIs are correctly derived from DML standard errors. The sign change relative to OLS is coherently explained in the paper as reflecting linearisation of a quadratic treatment combined with LATE weighting via the instrument.

However, there are two blocking issues that must be resolved before this analysis can be considered methodologically sound. First, the treatment nuisance R² for the RF learner recorded in `dml_results.json` ($R^2 = -127{,}810$) is a computational artifact, most plausibly arising from misalignment between the averaged prediction array and `dml_data.d` in the R² computation. While this does not affect the preferred LassoCV estimate, it taints the reported diagnostics and must be corrected or explicitly labelled as invalid. Second, and more seriously, no nuisance R² values are computed or stored for the LassoCV preferred learner. The LassoCV fit cell (`cell id 087e4487`) lacks the post-fit R² computation that is present in the RF cell. Without these values, the quality of the preferred nuisance estimation cannot be assessed. The outcome nuisance RMSE across repetitions (~0.90–0.93) implies an R² of roughly 0.50 (consistent with the RF outcome R² of 0.505), which is adequate but not strong. The treatment nuisance RMSE (~5.70–5.75) is high relative to the scale of `pdiv_aa` — this must be checked and reported.

The learner grid (RF and LassoCV only) is minimal. For a dataset of this size (N=148, 8 covariates), adding at least one gradient-boosted ensemble (e.g., `HistGradientBoostingRegressor`) would meaningfully test whether the LassoCV nuisance estimates are sensitive to learner choice. The near-zero `ml_r` RMSE (~0.002–0.003 for RF; ~0.021 for Lasso) warrants explicit discussion: an instrument that is almost perfectly predicted from the covariate set is potentially problematic for the exclusion restriction, even if this is ultimately an identification question rather than a DML implementation question.

With N_reps=3 and K=5 yielding a minimum fold size of 29 (marginally below the rule-of-thumb of 30), the stability of the cross-fitting procedure across random splits is not fully characterised. The authors should either increase N_reps to 10 or report the standard deviation of the DML coefficient across the 3 repetitions to confirm the estimate is not artefactually precise due to a favourable random split.
