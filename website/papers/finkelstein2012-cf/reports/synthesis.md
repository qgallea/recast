## Synthesis Report -- Round 1

**Unified verdict:** Minor revision

### Blocking issues (require re-running a notebook)

None.

### Major issues (prose or table edits only)

| # | Issue | Raised by | Action |
|---|-------|-----------|--------|
| 1 | CF standard errors are implausibly narrow (ATE SE = 0.00056 vs IV SE = 0.026; 46x ratio). The claim of "non-overlapping CIs" in Section 3 is driven by the artificially tight CF CI and is not well-founded inferentially. GATE SEs are similarly suspect. | R2 | Add a paragraph in Section 3 explicitly flagging the known SE limitation of EconML's CausalIVForest. Qualify the "non-overlapping CIs" claim. Note that the CI width in the forest plot reflects this limitation. |
| 2 | The CF estimand is labelled "ATE" but in an IV design it is a LATE (complier-weighted). This creates a false contrast with the original IV/LATE. | R1, R2 | Relabel "ATE" as "CF-LATE" or "IV-forest LATE" throughout Section 3, or add a clarifying sentence that the CausalIVForest identifies a complier-weighted estimand analogous to 2SLS LATE. |
| 3 | The 37% magnitude difference (0.182 vs 0.133) is attributed vaguely to "nonlinear effects or weighting." Discussion should be more concrete. | R2 | Expand Section 3 discussion: (a) the forest may upweight subgroups with larger effects (numhh=2 GATE = 0.248), (b) honest splitting imposes different functional form, (c) explore whether the CF ATE is a weighted average of GATEs with weights differing from 2SLS complier weights. |

### Minor issues

| # | Issue | Raised by | Action |
|---|-------|-----------|--------|
| 4 | Sample size discrepancy: paper says n=23,741 but replication uses n=23,361 (380 obs difference, 1.6%). Not explained. | R1, R3 | Add a sentence in Section 2 noting the discrepancy and likely cause (missing covariates or merge differences). |
| 5 | Feature importances dominated by design dummies (draw-wave x household-size FEs), not substantive moderators. Forest may be capturing design variation rather than genuine HTE. | R2 | Strengthen the caveats paragraph in Section 3.2 to explicitly note that splitting on FE dummies captures design variation, not substantive moderation. |
| 6 | Limited covariate set (only numhh_list + draw-wave dummies) constrains heterogeneity analysis. Null HTE result may reflect thin covariates rather than true homogeneity. | R2 | Add a sentence in Section 3.1 acknowledging that richer covariates (age, gender, baseline health) would be needed for substantive HTE analysis. |
| 7 | No robustness checks beyond main specification (no alternative outcomes, no subsample stability, no placebo tests). | R3 | Add a "Limitations" sentence in Section 5 noting that future work could extend to additional outcomes and placebo tests. |
| 8 | Forest plot: CF CI is invisible due to extreme narrowness, risking conveying false precision. | R3 | Add a footnote to Figure 1 noting that the CF CI width reflects the SE concern discussed in the text. |
| 9 | Exclusion restriction not stated explicitly in the introduction. | R1 | Add one sentence in Section 1 stating the exclusion restriction. |
| 10 | First-stage strength at the leaf level not discussed for the CF extension. | R1 | Add a brief remark in Section 3 about whether min_var_fraction_leaf or similar safeguards were applied. |
| 11 | Diagnostics table (line 196 of paper.tex) contains a possible encoding issue (garbled character). | R3 | Check compiled PDF; fix Unicode character if needed. |
| 12 | OLS estimate not reported for comparison to quantify endogeneity bias. | R3 | Optional: consider adding an OLS row to the comparison table in future iterations. |
| 13 | CATE significance rate (76.7%) may be overstated if individual CATE SEs are similarly deflated as the ATE SE. | R2 | Add a caveat sentence in Section 3.2 noting this possibility. |

### Referee disagreements

None. All three referees agree on the core findings: the replication is successful, the CF extension is correctly implemented in structure, and the main concerns are about SE estimation and estimand labelling. No referee contradicts another's verdict.

### Already resolved (suppressed from this round)

Not applicable -- this is Round 1 with no prior changelogs.
