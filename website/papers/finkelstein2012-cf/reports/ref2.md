## Referee 2 Report: DML Methods & Causal Forest
**Round:** 1
**Overall verdict:** Major concerns

### Blocking issues
- None

### Major issues

1. **Implausibly narrow ATE standard error (Check 14/18).** The CausalIVForest reports an ATE of 0.182 with SE = 0.00056 and 95% CI [0.181, 0.183]. This CI width of 0.002 is extraordinarily narrow for n = 23,361 with a binary outcome and a binary instrument. For comparison, the replicated 2SLS SE is 0.026 -- roughly 46 times larger. Even accounting for the forest's different variance estimator, a 46-fold reduction in standard error is implausible. This likely reflects a known issue with EconML's `CausalIVForest` where the reported SE is the standard error of the *mean of leaf-level point estimates* rather than a proper inferential SE accounting for estimation uncertainty within leaves. The paper should (a) flag this explicitly, (b) not draw inferential conclusions from the CI (e.g., the claim of "non-overlapping confidence intervals" in Section 3 is driven by the artificially tight CF CI), and (c) consider reporting bootstrap-based CIs or the variance of the CATE distribution as a more honest uncertainty measure.

2. **GATE standard errors similarly suspect (related to #1).** The GATE SEs in hte_results.json are also extremely small: numhh=1 has SE = 0.000366, numhh=2 has SE = 0.001392, numhh=3 has SE = 0.000145. These are implausibly precise for subgroup averages from an IV design. The CI widths reported in the JSON (e.g., [0.069, 0.240] for numhh=1) appear to come from a different calculation than the SE -- the CI width of 0.171 is consistent with proper inference, but SE = 0.000366 implies a CI width of ~0.0014. The paper reports the wider CIs in the text, which is correct, but the underlying SE values in the JSON should be flagged as unreliable. Table formatting should use the CI bounds, not SE-derived intervals.

3. **37% magnitude difference between CF ATE and published IV warrants more discussion.** The diagnostics flag `cf_ate_consistency` as PASS with "37.1% magnitude diff." A 37% difference (0.182 vs 0.133) with the same sign is not alarming per se, but the current discussion attributes it vaguely to "nonlinear effects or differences in implicit weighting." The paper should discuss more concretely: (a) the CF may upweight complier subgroups with larger effects, (b) the honest splitting and different functional form assumptions in the forest may yield a different implicit estimand, and (c) whether the difference is driven by the household-size composition (given that numhh=2 has a GATE of 0.248 vs numhh=1 at 0.155).

### Minor issues

1. **Feature importances dominated by fixed-effect dummies (Check 19).** The top features by importance are draw-wave x household-size dummies (ddd_d3_n2 at 23.1%, numhh_list at 19.3%, ddd_d6_n2 at 13.7%). These are design variables, not substantive moderators. The paper correctly notes this in the caveats paragraph, but should go further: splitting on fixed-effect dummies may mean the forest is capturing residual design variation rather than genuine treatment effect heterogeneity. This is consistent with the null heterogeneity test result.

2. **Limited covariate set for heterogeneity analysis (Check 10).** The only non-fixed-effect covariate is `numhh_list` (household size, with values 1, 2, 3). This is a very thin covariate space for exploring heterogeneity. The paper acknowledges this implicitly ("the only covariate that varies in the model") but should state explicitly that the limited covariate set constrains the forest's ability to detect meaningful heterogeneity. Richer covariates (age, gender, baseline health) would be needed for substantive heterogeneity analysis.

3. **Number of trees is adequate (Check 15).** n_estimators = 1000 with honest = True is appropriate. No concern here.

4. **CATE distribution: 76.7% significant (Check 18).** With n = 23,361, 76.7% individually significant CATEs is plausible and not suspicious. However, given the SE concerns above, this number should be interpreted cautiously -- if individual CATE SEs are similarly deflated, the significance rate may be overstated.

### Comments to the authors

The CausalIVForest implementation follows correct practices in several respects: honest splitting is enabled, 1,000 trees provide stable estimates, and the instrument (lottery selection) is appropriate for the IV-forest framework. The choice of CausalIVForest over CausalForestDML is correct given the IV design.

The most important methodological concern is the implausibly narrow standard errors. The ATE SE of 0.00056 implies a coefficient of variation of 0.3%, which is unrealistic for any treatment effect estimate from an observational or quasi-experimental study with ~23,000 observations. This is a known limitation of certain EconML implementations where the variance of the point predictions is reported rather than a proper inferential variance. The practical consequence is that the claim of "non-overlapping confidence intervals" between the CF ATE and the published IV/LATE (Section 3) is not well-founded -- the non-overlap is driven entirely by the CF's artificially tight CI, not by a genuinely precisely estimated difference. The paper should qualify this claim.

The heterogeneity analysis is honestly reported: the formal test does not reject homogeneity, and the paper does not overclaim. However, the limited covariate set (essentially only household size and draw-wave dummies) means the forest has very little to work with for detecting heterogeneity. The null result is unsurprising given this constraint rather than strong evidence of truly homogeneous effects. A sentence acknowledging this limitation would strengthen the discussion.

The 37% gap between the CF ATE (0.182) and the IV/LATE (0.133) deserves a more structured discussion. One concrete hypothesis: the numhh=2 subgroup shows a GATE of 0.248 (87% larger than the overall IV estimate), and if the forest implicitly upweights this group, it could partially explain the higher ATE. The paper should explore whether the CF ATE is a weighted average of the GATEs and whether the weights differ from the 2SLS complier weights.
