## Referee 2 Report: DML Methods & Causal Forest
**Round:** 1
**Overall verdict:** Minor concerns

### Blocking issues
- None

### Major issues
- **M1: Nuisance R-squared interpretation should distinguish between expected-by-design and problematic cases.** The paper correctly explains that low nuisance R-squared is expected in a randomized experiment (Section 4). However, the diagnostics table labels nuisance_quality as "FAIL" (red) without qualification. The paper text handles this well, but the table presentation creates an inconsistency. The paper should either (a) add a qualifier to the diagnostics table noting this is expected, or (b) add a footnote to the table explaining why FAIL is expected here. Currently a reader scanning the table without reading the text would conclude the analysis failed quality checks.

### Minor issues
- **m1: Learner grid is narrow.** Only two learners are used (RandomForest and LassoCV). The DML literature recommends spanning linear, tree-based, and ensemble methods. Adding at least one boosting method (e.g., XGBoost or GradientBoosting) would strengthen the robustness claim. However, given that both current learners produce nearly identical estimates (0.164 vs 0.165), this is unlikely to change the conclusions.
- **m2: GATE CIs labeled "joint" but computed pointwise.** The GATE table caption and the gate_plot.pdf axis label say "95% joint CI," but the GATEs were computed by fitting separate PLIV models on each subgroup (hte_results.json: "method": "GATE_subgroup"). These are pointwise CIs for each subgroup, not jointly valid confidence bands. The label should be corrected to "95% CI (pointwise)" to avoid overclaiming simultaneous coverage.
- **m3: No causal forest analysis.** The config disables causal forest (`causal_forest.enabled: false`). This is acceptable for a PLIV design where CausalIVForest would be needed, but the paper should briefly note why causal forest was not used (e.g., "CausalIVForest is not implemented in the current pipeline" or "the categorical nature of the available covariates limits the usefulness of a causal forest approach").
- **m4: Preferred learner selection criterion is ad hoc.** The notebook selects LassoCV as preferred when RF r2_outcome < 0.1. This threshold is arbitrary and not grounded in the DML literature. In this case both learners produce essentially identical estimates, so the choice is inconsequential. But the paper should note the selection criterion or simply state that results are robust across learners rather than emphasizing a "preferred" choice.

### Comments to the authors

The DoubleML implementation is methodologically sound. The choice of DoubleMLPLIV is correct for the IV design, and the cross-fitting procedure (K=5, N_rep=3) is adequate for the sample size (min fold size approximately 4,672, well above the K x min_fold_size > 30 threshold). The nuisance models use appropriate learners and the Neyman-orthogonal score ensures robustness to the poor nuisance fit.

The near-zero and negative nuisance R-squared values (outcome: 0.004, treatment: -0.280) are well-explained in the text as a feature of the randomized design rather than a bug. In a well-conducted lottery, treatment assignment is independent of covariates by construction, so the treatment model should perform no better than the unconditional mean. The negative R-squared for the treatment model simply means the ML predictions are worse than predicting the sample mean, which is expected when the covariates carry no information about treatment. The paper's argument that DML remains valid via the Neyman-orthogonal score is correct -- the key theoretical result in Chernozhukov et al. (2018) is that the score is insensitive to nuisance estimation error, including poor nuisance models.

The GATE analysis uses an appropriate workaround for the absence of a native `.gate()` method in DoubleMLPLIV. However, the confidence intervals from separate subgroup fits are pointwise, not jointly valid. This distinction matters if the reader wants to test the null of no heterogeneity across groups. The current labeling ("joint CI") should be corrected. The numhh=3 subgroup (N=57) is too small for reliable DML estimation -- the minimum recommended fold size for K=5 cross-fitting would be about 11 observations per fold, which is well below any reasonable threshold. The paper correctly flags this but should consider dropping this group from the GATE table entirely, or at minimum adding an explicit warning in the table itself.
