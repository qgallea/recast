## Referee 2 Report: DML Methods & Causal Forest
**Round:** 1
**Overall verdict:** Minor revision

### Methodological contribution

The DML extension is well-suited to this setting. Nunn and Trefler (2010) use OLS with 17 controls in a sample of only 63 countries ($p/N \approx 0.27$), making regularisation bias a first-order concern. PLR is the correct model class for continuous treatment with selection-on-observables identification. The comparison of 7 ML methods (5 base + Ensemble + Best) provides genuine evidence about whether the positive tariff--growth relationship survives flexible nonlinear control adjustment --- and it does, directionally, though at roughly half the OLS magnitude. The close agreement with Baiardi and Naghi (2024) benchmarks (within 0.001--0.002 across all three treatments) provides strong external validation.

### Essential issues

1. **n_rep = 5 is below the recommended minimum of 20 (Checklist item 3).** The code explicitly overrides the config value (`n_rep = 5`, line 155: "Override n_rep to 5 for speed") and the SE formula correctly applies the B&N median-aggregation adjustment. However, with only 5 repetitions the median coefficient and the variance term $(\hat\theta_k - \tilde\theta)^2$ in the adjusted SE are estimated from very few draws. This matters because $N = 63$ with $K = 2$ folds means each fold has $\approx$31 observations, so cross-fitting variability can be substantial. **Scientific justification:** With 5 reps, the inter-rep variance component in the adjusted SE is estimated with effectively 4 degrees of freedom. A single aberrant fold split could shift the median coefficient or inflate/deflate the adjusted SE by 20--30%. Since all three primary specifications have CIs that just barely include or exclude zero (p-values in the 0.03--0.20 range), the marginal significance conclusions are sensitive to cross-fitting noise. **Recommended fix:** Re-run with n_rep = 20 (the config default). This is computationally cheap for $N = 63$ and 5 learners. If the point estimates and p-value ordering remain unchanged, the current conclusions are confirmed; if they shift, the paper must update its significance statements.

2. **"Best" learner copies the Forest result wholesale rather than combining the best-outcome and best-treatment learners (Checklist item 4).** The code (line 520) copies all results from `best_outcome_method` (Forest for Panel A), including its coefficient and SE. But the `best_treatment_method` is Lasso for Panel A. In the Baiardi and Naghi (2024) methodology, "Best" should re-fit the PLR using the best outcome learner (Forest) for `ml_l` and the best treatment learner (Lasso) for `ml_m`. Instead, the current "Best" is simply the Forest result (Forest for both nuisance equations). **Scientific justification:** The treatment nuisance $R^2$ for Forest is 0.286 vs. 0.312 for Lasso (Panel A). Using the wrong treatment learner means the first-stage residualisation of $D$ is suboptimal, which inflates the DML standard error and may attenuate the point estimate. The paper explicitly states "Best learner (Forest for outcome, Lasso for treatment)" but the reported coefficient (0.018) and SE (0.0106) are identical to the Forest row, confirming that the best-treatment learner was not actually used. **Recommended fix:** Re-fit the Best specification using Forest for `ml_l` and Lasso for `ml_m`. This requires one additional `DoubleMLPLR` call per specification.

### Suggestions

1. **Ensemble SE is computed as a weighted average of individual SEs (Checklist item 8).** The code (lines 500--501) computes `ensemble_se = sum(weights * se)`. This is not a valid standard error --- it does not account for covariance between learner estimates. The correct approach is either (a) to use the delta method with the stacking covariance matrix, or (b) to report the ensemble as a point estimate only and note that no valid SE is available. The current CIs are therefore unreliable for the Ensemble column, though since the paper's main conclusions rest on the "Best" learner this is not blocking.

2. **Low nuisance $R^2$ merits a more structured discussion (Checklist item 6).** The outcome $R^2$ ranges from $-38.8$ (NeuralNet, catastrophic) to $0.19$ (Boosting, Panel B). The paper correctly notes that low $R^2$ inflates SEs without biasing point estimates via Neyman orthogonality, and correctly identifies external validation via B&N. This is adequate but could be strengthened by reporting a table of nuisance $R^2$ values for all learners across all three panels, making transparent which learners achieve positive $R^2$ and which do not.

3. **NeuralNet should be formally excluded or downweighted in interpretation (Checklist item 6).** The NeuralNet outcome $R^2$ is catastrophic ($-38.8$ to $-44.3$) across all three panels, meaning its nuisance predictions are worse than a constant. The paper describes this as "unreliable" but still includes NeuralNet in the forest plot and the main results table. A cleaner approach is to report it in a footnote or appendix and note that the Ensemble correctly downweights it (weight 0.5--0.6%).

4. **BLP implementation uses manual OLS rather than the DoubleML API (Checklist items 10--11).** The code (lines 750--752) constructs the BLP regression manually via `sm.OLS(Y_res, X_blp)` with HC1 standard errors, rather than using `obj_hte.blp()`. The manual approach is methodologically valid if the residuals $Y_{res}$ and $D_{res}$ are correctly extracted from the DML object, which appears to be the case (lines 733--734). However, using the built-in API would reduce the risk of implementation error and ensure consistency with the GATE computation.

5. **CLAN lacks statistical power and could note this more explicitly (Checklist item 13).** CLAN is reported with $N = 13$ per extreme quintile and no covariate reaches significance. The paper mentions this is "expected given the small sample" but could add that with 13 observations per group, a standardised effect of $d \approx 1.1$ would be needed for 80% power, making CLAN essentially uninformative here.

6. **Cross-fitting stability diagnostic is skipped (Checklist item, diagnostics_flags.json).** The `cross_fitting_stability` check returns SKIP because `per_rep_coefs` are not stored in the Best learner. Storing and reporting the per-rep coefficients (trivially available from `obj.all_coef`) would allow readers to assess fold-split sensitivity, which is particularly relevant at $N = 63$.

### DML Checklist Summary

| # | Item | Verdict |
|---|------|---------|
| 1 | Model class (PLR) | PASS |
| 2 | K-fold adaptive to N | PASS (K=2 for N=63 < 200) |
| 3 | n_rep >= 20 | ESSENTIAL (n_rep=5, see issue 1) |
| 4 | Best by lowest nuisance MSE | ESSENTIAL (copies outcome-best wholesale, see issue 2) |
| 5 | >= 5 method classes | PASS (Lasso, Tree, Boosting, Forest, NNet + Ensemble + Best) |
| 6 | Nuisance R2 reported honestly | PASS (reported; see suggestion 2 for improvement) |
| 7 | Score function appropriate | PASS (default PLR score) |
| 8 | CIs from DML SEs | SUGGESTION (Ensemble SE invalid; Best/individual correct) |
| 9 | Lasso diagnostics reported | PASS (3/17 and 5/17 non-zero for Panel A) |
| 10 | BLP reported before GATE | PASS (beta2 = 1.083, p < 0.001) |
| 11 | GATE on predicted CATE quintiles | PASS |
| 12 | Jointly valid GATE CIs | PASS (confint(joint=True) confirmed in code) |
| 13 | CLAN included | PASS (reported; underpowered as expected) |

### Comments to the authors

The DML implementation is generally sound and produces results that are well-aligned with the Baiardi and Naghi (2024) benchmarks, which is the strongest possible external validation for this paper. The PLR model class is appropriate, K=2 is correct for the small sample, the B&N adjusted SE formula is correctly implemented, and the GATE analysis with jointly valid CIs is properly executed via the DoubleML API. The finding that DML coefficients are roughly half the OLS values across all three treatment measures, with all well-behaved learners agreeing on a positive sign, is a genuinely informative result.

The two essential issues are both fixable with modest computational effort. First, increasing n_rep from 5 to 20 will stabilise the median coefficient and the adjusted SE, which is important because the marginal significance of several specifications (p-values in the 0.05--0.20 range) could shift with different cross-fitting draws. Second, the "Best" learner should combine the best outcome learner (Forest) with the best treatment learner (Lasso) in a single PLR fit, rather than simply copying the Forest row. This discrepancy is visible in the data: the Best and Forest rows in dml_results.json are identical (coef = 0.01764, SE = 0.01058), yet the paper claims "Best" uses Forest for outcome and Lasso for treatment. Fixing this will likely produce a slightly different coefficient and potentially a tighter SE (since Lasso achieves higher treatment $R^2$ than Forest: 0.312 vs. 0.286).

Neither issue is likely to change the paper's qualitative conclusions --- the DML estimates will almost certainly remain positive, smaller than OLS, and marginally significant --- but they are needed for methodological correctness.
