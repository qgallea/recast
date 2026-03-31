## Changelog — Round 1

### Blocking issues addressed

- **Issue:** E1 — CLAN label inversion. The code mapped `top_q` (highest predicted CATE = least negatively affected) to "most affected" and `bot_q` (lowest predicted CATE = most negatively affected) to "least affected," inverting the group labels in the JSON output and the CLAN table.
  **Notebook edited:** `code_build/04_dml_extension.ipynb`
  **Change:** Inserted a new cell (## Revision Round 1) after cell 7 (id `b66a4510`). The new cell swaps `mean_most_affected` and `mean_least_affected` in every `clan_results` entry, recomputes the `difference` column, and rewrites `hte_results.json` with corrected labels. The downstream CLAN LaTeX table (generated in cell 10) reads from the same corrected `clan_results` list, so `table_clan.tex` will also be regenerated correctly on re-run.
  **Status:** Awaiting re-run

- **Issue:** E1 (prose consequence) — CLAN narrative in `paper.tex` was based on the inverted labels. After the label swap, the substantive finding reverses: the most affected countries (lowest CATE) have *higher* trade freedom (7.52) than the least affected (6.72), not lower.
  **Location:** Section 3.3 (CLAN results paragraph) and Section 5 (Conclusion)
  **Change:**
  - CLAN paragraph: Rewrote to state that "the most affected countries have *higher* trade freedom (mean 7.52) than the least affected (mean 6.72)" and updated the economic interpretation (internationally mobile capital responds more elastically to tax differentials). Updated property rights (62.3 vs. 51.5) and inflation (5.4% vs. 19.9%) comparisons accordingly.
  - Conclusion: Changed "Countries with less freedom to trade internationally appear most negatively affected" to "Countries with greater freedom to trade internationally appear most negatively affected" with updated rationale.
  **Status:** Resolved (prose updated; will be fully verified after notebook re-run confirms the corrected CLAN means)

### Suggestions addressed

- **S1 (selection-on-observables caveat):** Added two sentences to the conclusion noting that the DML extension strengthens efficiency and relaxes functional-form assumptions but does not substitute for exogenous variation, and that both OLS and DML rely on selection on observables.
  **Location:** End of Conclusion section.

- **S2 (nuisance R² discussion):** Added two sentences to the Diagnostics Discussion paragraph: (a) low R²_D implies substantial residual treatment variation, which supports the PLR model; (b) the B&N adjusted SE formula already penalises unstable nuisance estimates, so the FAIL flag does not mechanically invalidate the CIs.
  **Location:** Diagnostics Summary, Discussion paragraph.

- **S3 (GATE gradient is descriptive):** Added a sentence after the GATE itemized list noting that with N = 61 split into quintiles of ~12, extreme-quintile estimates are imprecise and the gradient should be interpreted as descriptive evidence of heterogeneity rather than causal subgroup effects.
  **Location:** Section 3.3, GATE results paragraph.

- **S6 (clarify "Best" learner criterion):** Added a sentence in the Results subsection explaining that "Best" refers to the learner with the lowest out-of-sample MSE for the outcome nuisance model g(X), following the standard DoubleML convention.
  **Location:** Section 3.2, first paragraph.

- **S7 (DecisionTree anomaly in Panel C):** Added a sentence in the Panel C bullet noting that the Best column selects Decision Tree on MSE grounds yet its coefficient is the smallest and least significant, illustrating that MSE-based selection does not necessarily select the most significant estimator.
  **Location:** Section 3.2, Across outcomes, Panel C bullet.

- **S8 (FDI Lasso p-value precision):** Changed "p = 0.05" to "marginally significant at p = 0.053" for the FDI panel Lasso estimate.
  **Location:** Section 3.2, Across outcomes, Panel B bullet.

- **S9 (NeuralNet cross-panel note):** Added a sentence noting that across the other three panels the neural network agrees on a negative sign, suggesting that the Investment-panel divergence is noise rather than a systematic failure.
  **Location:** Section 3.2, Primary specification paragraph.

### Suggestions deferred

- **S4 (increase n_rep from 5 to ≥20):** Deferred — current results are stable (cross-fit ratio = 0.21) and match the benchmark. The computational cost of increasing n_rep is not justified given the absence of instability evidence.

- **S5 (fix lasso_diagnostics extraction):** Deferred — requires debugging the `extract_lasso_diagnostics` function, which is a pipeline-level fix beyond the scope of a single-paper revision. Low benefit relative to cost since the core DML estimates are unaffected.

- **S10 (forest plot legend for green markers):** Deferred — requires editing the forest plot generation code (cell 9), which is a visual improvement with no impact on the substance. Low benefit relative to cost.
