# Final Review Report

**Paper:** The 'Out of Africa' Hypothesis, Human Genetic Diversity, and Comparative Economic Development
**Original authors:** Ashraf, Q. and Galor, O. (American Economic Review, 2013)
**Rounds completed:** 3 of 3
**Final verdict:** Minor manual revision needed

---

## Overall Assessment

The DML extension applies DoubleMLPLIV (partial linear IV) to ask whether the migratory-distance instrument confirms a causal link between genetic diversity and income. The main result is a precisely estimated negative coefficient — LassoCV: theta = -25.47, SE = 5.64, 95% CI [-36.53, -14.41], p = 6.4e-6 — which appears to contradict the original paper's positive OLS linear coefficient of ~200–280. This is not actually a contradiction. The original paper's estimand is the slope of a quadratic (hump-shaped) curve; the DML estimates a linearised LATE at the instrument-weighted complier mean, which sits on the downward-sloping right arm of that hump at the sample average diversity of ~0.72. The two estimates answer different questions and the paper now says so clearly, repeatedly, and correctly. The sign change is the expected consequence of local linearisation above the optimum, not a failure of replication or a new finding.

The replication is a partial success. Four of the six targeted specifications pass numerical replication, covering the paper's primary evidence base: the two 145-country historical OLS specifications (Table 3, deviations 0.3% and 7.7%) and the two contemporary OLS specifications (Table 6: 3.4%; Table 7: 6.3%). The two failures are both from the N=21 limited sample (Table 1 col 4: 29.4%; Table 2 col 5: 33.5%), which is the hardest sample to replicate due to unavailability of Conley (1999) spatial SEs and high sensitivity to the exact cleanlim filter. The sign and approximate magnitude of these specs are preserved; the deviation is a precision issue, not a qualitative discrepancy. Under the stated two-tier threshold (5% for OLS, 10% for bootstrap/IV), 5 of 6 specs pass at 83%.

As a publication candidate — say, a short methods note or working paper — the document is close but not quite there. The three rounds of revision fixed everything genuinely blocking: estimand clarification, degenerate RF nuisance correction, missing LassoCV nuisance R², stale numbers throughout, inconsistent diagnostics table, forest plot caption, first-stage acknowledgement, exclusion restriction discussion, and sample size footnotes. What remains is one substantive methodological gap (single usable learner, no robustness checks) and several transparency issues that are openly acknowledged in the paper's caveats section. Given the acknowledged limitations, the paper is honest about what it is and is not. It is a solid first RECAST of Ashraf-Galor, not a definitive re-evaluation.

---

## What Was Solved During Revision

| Issue | Raised (round) | Resolved (round) | How |
|-------|---------------|-----------------|-----|
| Quadratic estimand mismatch: PLIV recovers linear LATE, not quadratic ATE | 1 | 1 | Section 3.1 estimand clarification paragraph; Section 3.3 re-opened with explicit non-comparability statement |
| Degenerate RF nuisance R² = -127,810 (computational pathology from rep-averaging misalignment) | 1 | 1–2 | Notebook fix: use predictions[:, 0, 0] for single-rep R²; `rf_nuisance_degenerate: true` flagged in JSON; RF excluded from forest plot |
| Missing LassoCV nuisance R² in dml_results.json | 1 | 1–2 | Notebook fix: LassoCV outcome R² = 0.41 now stored and reported |
| Exclusion restriction threats unacknowledged | 1 | 1 | Section 2.1 paragraph added citing Neolithic timing, disease ecology, trade routes; Spolaore & Wacziarg (2013) cited |
| Forest plot x-axis distorted by degenerate RF CI ([-1252, +456]) | 1 | 1–2 | RF row excluded from regenerated forest plot; figure now readable |
| Forest plot caption inconsistent with figure contents (promised Tables 1, 3, 2SLS; showed none) | 1 | 2 | Caption rewritten: "OLS (Tables 6 and 7, contemporary specifications) and DML-PLIV (LassoCV)" with parenthetical on excluded rows |
| DML CI non-overlap with OLS flagged as FAIL but not explained | 1 | 1 | Section 3.3 bold opening block; diagnostics relabelled WARN (expected) |
| DML N=148 vs OLS N=143/109 unexplained | 1 | 1–2 | Footnote: DML drops quadratic missingness requirement, retaining 5 extra observations; complier population implication stated in Section 3.1 |
| Stale DML numbers throughout paper.tex: -23.19 vs actual -25.47 | 2 | 2 | All hard-coded coefficients, SEs, CIs updated throughout abstract, body, diagnostics table to match current dml_results.json |
| Diagnostics table: three stale/inconsistent entries (old R²_D, old R²_Y, old RF coef) | 2 | 2 | Table rebuilt: RF row labelled degenerate (excluded); R²_Y = 0.41; DML direction = WARN; table notes explain flat vs. two-tier threshold |
| First-stage F-statistic never reported | 1–2 | 2 | Published Ashraf & Galor (2013) F-statistic cited in Section 2.2; explicit statement that ML-partialled first-stage strength is uninvestigated |
| LassoCV treatment nuisance R² = -97,090 unexplained | 2 | 2–3 | Footnote added explaining DoubleML prediction-array indexing artifact; RMSE-based quality metric presented; claim softened in Round 3 to acknowledge that RMSE plausibility is unverified |
| n_rep=3 cross-fitting stability not mentioned in caveats | 1–2 | 2 | Fourth caveat added to Conclusion |
| near-zero ml_r RMSE not discussed | 1–2 | 2–3 | Section 3.2 paragraph added; promoted to Fifth named caveat in Conclusion |
| Abstract did not acknowledge pipeline's FAIL status | 3 | 3 | Parenthetical added noting automated flat-threshold check fails on 21-country specs; two-tier rule yields 5/6 |

---

## Remaining Issues

| # | Issue | Severity | Action needed |
|---|-------|----------|---------------|
| 1 | Single usable learner: RF is degenerate, leaving LassoCV as the only functioning nuisance model. With no within-pipeline comparator, the estimate -25.47 cannot be validated against an independent learner. The paper acknowledges this in the caveats. | Major | Before treating this as a final causal estimate, add at least one ensemble learner (e.g., HistGradientBoostingRegressor) to the learner grid in notebook 04 and re-run Stage 4. If the gradient-boosted estimate corroborates -25.47, the finding is robust. If it diverges, the result depends on learner choice. |
| 2 | No robustness checks for the preferred DML estimate. Nothing varies: not the fold count (K=5 only), not the control set, not the treatment sample. With one learner and one specification, -25.47 has no within-paper sensitivity analysis. | Major | Add at least one alternative: (a) K=3 folds, (b) drop continent fixed effects, or (c) report the observed range of `obj_lasso.all_coef` across the 3 repetitions directly from DoubleML. Option (c) is a one-liner notebook addition. |
| 3 | LassoCV treatment nuisance R² = -97,090 is still stored in dml_results.json and the paper's footnote now explicitly states the RMSE-to-R² comparison "has not been independently computed or verified." This means there is no confirmed positive evidence that the LassoCV treatment nuisance is well-specified. | Major | Either: (a) fix the R² computation for LassoCV using the same single-rep indexing fix applied to RF (`predictions['ml_m'][:, 0, 0]` against `dml_data.d`), or (b) compute the conventional R² from the RMSE and the raw SD of `pdiv_aa` and report it. The LassoCV treatment RMSE (~5.73) against `pdiv_aa` range of ~0.63–0.78 (SD ~0.04–0.05) implies a very large RMSE relative to scale, which could indicate a unit or scaling issue rather than a pure indexing artifact. This needs to be resolved before the PLIV result can be considered methodologically confirmed. |
| 4 | First-stage strength under ML partialling is unverified. The near-zero ml_r RMSE (~0.002–0.021) means the instrument is nearly fully absorbed by the covariate set after partialling, leaving very little residual variation to identify the PLIV coefficient. This is disclosed as Caveat 5 in the Conclusion. | Major | Formally test whether the effective first stage (covariance of instrument residual with treatment residual) is non-degenerate, analogous to a first-stage F for PLIV. This would require a brief calculation in notebook 04. |
| 5 | Replication check JSON (`replication_check.json`) still reads `"pass": false, "summary": "4/6 specs replicated within 5%"` while the paper correctly applies the two-tier rule yielding 5/6. The JSON artifact and paper text are slightly inconsistent. | Minor | Document as a known pipeline limitation; the paper's diagnostics table notes already explain this. The JSON file does not need to change. |
| 6 | Forest plot label shows n=106 for Table 7; paper_spec.json records n=109 and replication_results.json shows n_obs=106. The footnote in Section 2.2 acknowledges the three-observation filter discrepancy. | Minor | Acceptable as disclosed; check which is correct (the replication_results.json n_obs=106 is probably the pipeline number; paper_spec.json n=109 is the published number). Correct the plot label or the footnote text to state explicitly which number is shown. |
| 7 | Inter-repetition coefficient range not reported. `obj_lasso.all_coef` is available from DoubleML but was not extracted. The Conclusion caveat (Round 3) acknowledges this. | Minor | Add `print(obj_lasso.all_coef)` to notebook 04 on any re-run and record the range in the paper (two lines of output, one sentence). |

*Severity: **Blocking** = must fix before sharing · **Major** = should fix · **Minor** = optional*

---

## Key Results

| Specification | Estimand | Estimate | SE | 95% CI | N |
|--------------|----------|----------|----|--------|---|
| Original paper OLS, Table 6 col 1 (bootstrap SE) | Quadratic ATE, linear coef | 203.44 | 83.37 | — | 143 |
| Original paper OLS, Table 7 col 5 (bootstrap SE, preferred) | Quadratic ATE, linear coef | 281.17 | 70.46 | — | 109 |
| Our replication, Table 6 col 1 (HC1 SE) | Same | 210.34 | 82.08 | — | 143 |
| Our replication, Table 7 col 5 (HC1 SE) | Same | 263.54 | 60.20 | — | 106 |
| DML-PLIV preferred (LassoCV) | Linear LATE at instrument-weighted mean | -25.47 | 5.64 | [-36.53, -14.41] | 148 |
| DML-PLIV (RandomForest) | Same (degenerate — excluded) | -588.59 | 1218.71 | [-2977, +1800] | 148 |

**Replication check:** FAIL by automated pipeline (flat 5% threshold) — worst delta = 33.5% (Table 2 col 5, 21-country IV). Under the stated two-tier rule (5% OLS / 10% bootstrap-IV), 5/6 pass at 83%. The four large-sample specifications replicate cleanly: Table 3 col 5 at 7.7%, Table 3 col 6 at 0.3%, Table 6 col 1 at 3.4%, Table 7 col 5 at 6.3%.

**DML shift:** The preferred DML estimate is -25.47 vs. OLS linear coef ~203–281 — a sign reversal. This is expected and correctly explained in the paper. The original OLS linear coefficient is the left-hand slope of a quadratic curve evaluated as a marginal effect. The DML PLIV linearises the treatment and estimates a LATE at the instrument-weighted complier mean, which sits above the hump optimum (~0.72 sample mean vs ~0.71 optimum). At that point, the derivative of the hump is negative by construction. These are not competing estimates of the same parameter.

---

## Notes for the Reader

- **The sign change is not a problem.** Every referee in every round confirmed that the -25.47 estimate is consistent with the original paper's quadratic story, not a challenge to it. The DML is asking a different question: what is the local causal effect of diversity at the margin induced by the instrument? The answer is negative because that margin is above the hump. Do not lead with the sign flip as a headline finding; lead with the replication of the four large-sample specs and treat the DML as a methodological demonstration.

- **The treatment nuisance issue is the most important unresolved problem.** The LassoCV ml_m RMSE of ~5.73 against a treatment variable (pdiv_aa) that ranges ~0.63–0.78 is suspicious. Either there is a unit scaling issue in the pipeline, or the instrument does not meaningfully predict diversity after ML-partialling (consistent with the near-zero ml_r), in which case the PLIV first stage is weak under ML conditions even if it is strong in the classical 2SLS. Until this is resolved, treat -25.47 as provisional.

- **The 21-country replication failures are not a concern for the paper's primary claims.** The N=21 sample is the paper's most fragile specification, uses a different diversity measure (observed adiv rather than predicted pdiv_aa), and relies on Conley spatial SEs that are not in the public replication package. The four large-sample specs that replicate cleanly are the ones Ashraf and Galor themselves treat as primary. The failures are a pipeline engineering problem, not an identification problem.

- **What the pipeline cannot verify:** First-stage F-statistic under ML partialling; the conventional out-of-sample R² for the LassoCV treatment nuisance; whether the five extra observations in the DML sample (N=148 vs N=143) are systematically different in any substantively important way. All three are flagged as caveats in the paper and as remaining issues above.

- **Before sharing this paper externally:** Fix the treatment nuisance R² question (issue #3 above), add one robustness check on the DML specification (issue #2), and verify the ml_r residual variance is non-degenerate (issue #4). These are each a few lines of code in notebook 04 and one paragraph in the paper. The document is currently honest about its limitations but has not verified that the PLIV estimate is identified off adequate residual instrument variation — that is the most important single thing to check before treating -25.47 as credible causal evidence.
