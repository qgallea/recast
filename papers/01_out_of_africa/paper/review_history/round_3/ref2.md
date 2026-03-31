## Referee 2 Report: DML Methods
**Round:** 3
**Overall verdict:** Minor concerns

---

### Blocking issues
- None

---

### Major issues
- None

---

### Minor issues

1. **LassoCV treatment nuisance R² artifact still present in dml_results.json (disclosure adequate, but fix remains open).** The stored value `nuisance_r2_treatment = -97,090.74` for LassoCV still reflects the same rep-averaging misalignment that was correctly diagnosed for the RF learner in Round 1. The Revision Round 1 code corrects RF by using `predictions['ml_m'][:, 0, 0]` (first rep, first fold), and the corrected RF value is properly flagged. An analogous correction for LassoCV (`lasso_r2_treatment = -97,090.74`) is computed in the same cell but the result is still highly negative, indicating either (a) the same indexing artifact persists for LassoCV or (b) the LassoCV treatment nuisance genuinely fails. The paper's footnote (Section 3.2) attributes the anomalous value solely to the DoubleML prediction-index aggregation artifact and states that "the RMSE is approximately 5.73 for ml\_m across repetitions." However, the RMSE values shown in the notebook output for LassoCV `ml_m` are 5.77, 5.71, and 5.76 — consistent with a standard deviation of `pdiv_aa` of approximately 0.05 (the variable is bounded ~0.6–0.8), which would imply an out-of-sample R² well below zero even without the artifact. This is distinct from, and potentially more serious than, the pure indexing artifact. The paper should clarify whether the RMSE-based implied R² is in an expected range, or whether LassoCV is also providing limited fit for the treatment nuisance beyond the artifact.

2. **n_rep = 3 caveat present but coefficient variability across repetitions not reported.** The Conclusion (Section 5, caveat 4) correctly flags that n_rep = 3 is modest and that the range or standard deviation of the coefficient across repetitions was not formally reported. This is an improvement over Rounds 1–2. However, the notebook does not extract and store the per-repetition coefficient estimates that DoubleML provides (e.g., `obj_lasso.all_coef`). With only 3 repetitions, the caveat adequately signals the limitation for a final round, but reporting the observed inter-repetition range of the coefficient (which DoubleML provides directly as `obj_lasso.all_coef`) would be a trivial addition and would materially strengthen the inferential credibility of the PLIV point estimate.

3. **Learner diversity: only two learners evaluated, no ensemble.** The paper now correctly designates LassoCV as the sole preferred learner and excludes the degenerate RF. However, the learner grid remains limited to one linear regularised estimator (LassoCV) and one tree-based ensemble (RF). The checklist criterion is that the grid should span linear, tree-based, and ensemble methods. With RF degenerate, only a single usable learner remains. The paper's Conclusion (caveat 1) recommends "ensemble learners" for future work, which appropriately acknowledges this gap. Given that this is Round 3, no blocking action is required, but this remains an open methodological limitation.

4. **First-stage strength under ML partialling not formally verified.** Section 3.2 correctly notes that the near-zero `ml_r` RMSE (approximately 0.02–0.003 across folds) implies limited identifying variation after partialling, and explicitly states "this has not been formally verified in this RECAST." The Conclusion's four caveats do not explicitly list weak first-stage strength under PLIV as a named caveat (caveat 2 addresses the exclusion restriction, not first-stage strength). This is a minor omission: the near-zero `ml_r` RMSE is arguably the most actionable diagnostic finding in the DML results, and a dedicated caveat alongside the n_rep caveat would be appropriate.

---

### Comments to the authors

**Number consistency between paper.tex and dml_results.json: resolved.** The key numbers verified against `dml_results.json` are consistent throughout the paper. The abstract reports $\hat{\theta} = -25.47$ (95% CI: $[-36.53, -14.41]$, $p < 0.001$), which matches `preferred_coef = -25.4705`, `preferred_ci_lo = -36.5309`, `preferred_ci_hi = -14.4101`, and `pval = 6.38 \times 10^{-6}` in the JSON to the stated precision. Section 3.2 and the Conclusion reproduce these figures identically. The diagnostics table (Section 4) correctly reports the DML direction check value as $-25.47$ and the CI coverage value as 225.44. This is a full resolution of the Round 2 blocking issue.

**Model class selection.** `DoubleMLPLIV` is the correct choice: the paper's identification is IV-based, and the notebook confirms `score function: partialling out`. The DoubleML `partialling out` score is the appropriate variant for the PLIV setting with a single continuous instrument. No concern here.

**Cross-fitting adequacy.** K = 5 folds with N = 148 implies minimum fold size of approximately 30, which is at the boundary of the rule of thumb (K × min_fold_size ≥ 30 requires min_fold_size ≥ 6; at K = 5 the constraint is effectively that N/K ≥ 6, satisfied with N = 148). The sample size diagnostic reports PASS. No concern.

**RF degeneracy and LassoCV treatment nuisance.** The RF treatment nuisance degeneracy is now correctly documented in `dml_results.json` (`rf_nuisance_degenerate: true`) and the paper explains the mechanism (near-zero treatment variance after partialling). The critical residual concern is the LassoCV treatment nuisance. The stored `nuisance_r2_treatment = -97,090.74` is attributed to an indexing artifact, but the per-repetition RMSE values for LassoCV `ml_m` (5.77, 5.71, 5.76) are large relative to the treatment variable's likely range. `pdiv_aa` varies roughly from 0.63 to 0.78 across the 148-country sample (range ≈ 0.15), making an RMSE of 5.7 implausible as genuine out-of-sample prediction error and suggesting the RMSE is also affected by unit or scaling issues. The paper's explanation — that "comparing this RMSE to the raw standard deviation of pdiv_aa yields a conventional out-of-sample R² in the expected range" — is asserted but not computed or reported. This assertion should either be verified numerically in the notebook or the claim should be softened. As it stands, the paper introduces an explanation that cannot be verified from the available outputs, which is a minor methodological transparency gap.

**Standard errors and CI computation.** CIs are correctly derived from DML asymptotic standard errors via `obj_lasso.confint()`, not from naive OLS SEs post-residualisation. The table notes confirm "95% CI computed from asymptotic normal approximation." No concern with the inference procedure.

**Overall assessment for Round 3.** The two blocking issues from prior rounds (number consistency and diagnostics table) are resolved. The remaining concerns are methodological caveats that are acknowledged in the paper's Conclusion: the n_rep = 3 limitation, the absence of inter-repetition coefficient variability, the single usable learner, and the unverified first-stage strength under PLIV. These do not individually rise to the level of blocking issues at this final round, but they collectively indicate that the DML extension should be interpreted as a preliminary application rather than a definitive causal estimate. The paper's framing is appropriately cautious in this regard. The report is ready to proceed to synthesis.
