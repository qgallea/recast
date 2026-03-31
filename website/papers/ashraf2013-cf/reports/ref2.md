## Referee 2 Report: DML Methods & Causal Forest
**Round:** 1
**Overall verdict:** Minor concerns

### Blocking issues
- None

### Major issues
1. **CausalForestDML chosen over CausalIVForest for an IV paper (Section 3.1).** The config sets `method: CausalForestDML`, which drops the instrument and uses selection-on-observables. For an IV paper, the natural choice would be `CausalIVForest` from `econml.grf`, which uses the instrument directly in the forest estimation. The paper should explicitly justify why CausalForestDML was chosen and discuss what would change under CausalIVForest. This is not a blocking issue because the config intentionally specifies CausalForestDML, but it is a major methodological choice that the paper does not fully discuss.

### Minor issues
1. **`honest=True` and `inference=True` are correctly set.** No issue here. Verified from `causal_forest_results.json`.
2. **`n_estimators=1000` is adequate.** Sufficient for stable estimates.
3. **`min_samples_leaf=5` with N=145:** The ratio N/min_samples_leaf = 29 is borderline (rule of thumb: > 20). This is acceptable but should be noted. With 145 observations split across 5 CV folds, each fold has ~29 observations for residualization. This is tight but not disqualifying.
4. **CATE significance rate of 2% (from diagnostics).** Only 3 of 145 individual CATEs reject H0: theta(x)=0 at 5%. This is consistent with a near-zero ATE and wide individual-level CIs. The paper correctly interprets this as a power issue. No change needed.
5. **Feature importances correctly interpreted.** The paper includes the caveat that importance does not imply causal moderation. Good.
6. **ATE SE is plausible.** The SE sanity check passes: ATE CI width (18.61) is comparable to mean CATE CI width (16.83), ratio = 0.9x. The `ate_inference()` method was used correctly (not the naive std/sqrt(n) approach).
7. **Section 3.4, line 170-171:** Variable names `ln_abslat`, `ln_arable`, `ln_suitavg` appear in plain text without LaTeX escaping of underscores. These will render incorrectly as subscripts. Should use `\texttt{ln\_abslat}` formatting.

### Comments to the authors

The CausalForestDML implementation is technically sound. The first-stage nuisance models (RandomForestRegressor with 200 trees, max_depth=5) are reasonable choices for this sample size. The 5-fold cross-fitting is standard. The `ate_inference()` method is correctly used for ATE standard errors, avoiding the common pitfall of computing SE as std(CATEs)/sqrt(n).

The main methodological concern is the choice of CausalForestDML over CausalIVForest. Since the original paper's entire identification strategy relies on the migratory distance instrument, a forest-based IV estimator would provide a more apples-to-apples comparison. The paper should add a brief discussion of why the selection-on-observables approach was chosen and what the reader should conclude from the comparison. One defensible argument is that CausalForestDML provides a complementary identification check: if the effect is robust to dropping the instrument and relying on flexible covariate control, this strengthens the evidence. But this argument should be made explicitly.

The 2% CATE significance rate is not concerning given the sample size and the theoretical expectation of a near-zero ATE. The diagnostics correctly flag this as a warning (power issue) rather than a failure.
