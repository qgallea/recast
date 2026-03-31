## Synthesis Report — Round 1

**Unified verdict:** Minor revision

### Contribution consensus

All three referees agree that this RECAST adds genuine value. The original Djankov et al. (2010) setting -- cross-country OLS with a continuous treatment, 12 controls, and N approximately 60 -- is exactly the regime where DML offers efficiency gains. The close match between the pipeline's Forest estimate (-0.211) and the independent Baiardi & Naghi (2024) benchmark (-0.204) validates the implementation. The heterogeneous treatment effect analysis (BLP test, GATE, CLAN) extends the original paper in a direction neither Djankov et al. nor Baiardi & Naghi pursued, providing novel evidence that the tax-investment relationship varies systematically across countries. The contribution bar is met; the bar for blocking is correspondingly higher.

### Essential issues (must be addressed — paper cannot stand as-is)

| # | Issue | Raised by | Scientific justification | Action |
|---|-------|-----------|-------------------------|--------|
| E1 | CLAN labeling inversion: the code maps `top_q` (highest predicted CATE = least negatively affected) to "most affected" and `bot_q` (lowest predicted CATE = most negatively affected) to "least affected," inverting the group labels in the JSON output. | R2 | The paper's CLAN narrative draws a substantive conclusion ("countries with less open economies suffer more from corporate tax increases") that may be backwards relative to the actual GATE gradient if the means are assigned to the wrong groups. Without correction, readers draw the wrong policy implication from the CLAN table. The paper text correctly defines Q1 as "most affected" and Q5 as "least affected" (line 229), but the underlying data feeding those means may be swapped in the code. | Fix the CLAN label assignment in `code_build/04_dml_extension.ipynb` so that `bot_q` (lowest CATE = most harmed) maps to "most affected" and `top_q` (highest CATE = least harmed) maps to "least affected." Re-run the notebook and verify that the CLAN means in the JSON match the corrected labels. Update the paper text only if the reported means change. |

### Suggestions (would improve but are optional)

| # | Issue | Raised by | Action |
|---|-------|-----------|--------|
| S1 | Acknowledge the selection-on-observables limitation in the conclusion. Neither OLS nor DML resolves potential endogeneity from omitted confounders. | R1 | Add one sentence to the conclusion noting that the DML extension strengthens efficiency and relaxes functional form but does not substitute for exogenous variation. |
| S2 | Tighten the nuisance R-squared discussion. (a) In the identification context, note that low R-squared in the treatment model m(X) implies substantial residual treatment variation, which supports the PLR model. (b) Note that the B&N adjusted SE formula already penalises unstable nuisance estimates, so the FAIL flag does not mechanically invalidate the CIs. | R1, R3 | Add one to two sentences to the diagnostics discussion combining both points. |
| S3 | Note that the GATE gradient is descriptive, not causal at the subgroup level. With N = 61 split into quintiles of ~12 observations, extreme-quintile estimates are imprecise. | R1 | Add a sentence to the GATE discussion noting the exploratory nature of the heterogeneity results. |
| S4 | Consider increasing n_rep from 5 to at least 20 for better asymptotic justification of the adjusted SE. | R2 | Optional. Current results are stable (cross-fit ratio = 0.21) and match the benchmark, so there is no evidence of bias. If computationally feasible, increase; otherwise, add a sentence justifying n_rep = 5 given the small sample. |
| S5 | Report Lasso variable selection diagnostics. The `lasso_diagnostics` field is null due to a likely key-format issue. | R2 | Fix the `extract_lasso_diagnostics` function if possible. If not feasible, add a footnote noting the limitation. |
| S6 | Clarify the "Best" learner selection criterion. Best is selected by lowest outcome nuisance MSE, but the best treatment-model learner can differ. | R2 | Add a brief note in the methods section explaining that "Best" refers to the learner with the lowest outcome MSE and why this is the standard choice. |
| S7 | Note the DecisionTree anomaly in Panel C: Best selects DecisionTree on MSE grounds, but its coefficient is smallest and least significant. | R2 | Add one sentence acknowledging that MSE-based selection does not always select the most significant learner. |
| S8 | Report FDI Lasso p-value more precisely. JSON records p = 0.053; paper says p = 0.05. | R3 | Either report to two decimal places (p = 0.05) with a note, or say "marginally significant (p = 0.053)." |
| S9 | Note that NeuralNet agrees on a negative sign in three of four panels, strengthening the argument that the Investment-panel divergence is noise. | R3 | Add a parenthetical to the neural network discussion. |
| S10 | Add a legend entry to the forest plot explaining the green colour for Ensemble and Best markers. | R3 | Minor visual improvement to Figure 1. |

### Blocking issues (require re-running a notebook)

| # | Issue | Raised by | Notebook to fix | Specific action |
|---|-------|-----------|-----------------|-----------------|
| E1 | CLAN label inversion | R2 | `code_build/04_dml_extension.ipynb` | Swap the mapping so `bot_q` (lowest CATE) = "most affected" and `top_q` (highest CATE) = "least affected." Re-run the notebook, verify corrected JSON, and update paper text if the reported CLAN means change. |

### Downgraded items

None. R2's E1 is the only issue marked essential across all three reports, and it has clear scientific justification (inverted substantive interpretation). No items were downgraded.

### Referee disagreements

None. All three referees reach the same verdict (minor revision) and agree on the core assessment: replication is successful, the DML extension is well-implemented, and the paper adds genuine value. No referee contradicts another's findings.

### Already resolved (suppressed from this round)

Not applicable — this is Round 1 with no prior changelogs.

---

RERUN_NEEDED: yes
