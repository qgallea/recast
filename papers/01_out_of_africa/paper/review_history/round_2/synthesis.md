## Synthesis Report — Round 2

**Unified verdict:** Major revision

**RERUN_NEEDED:** no — all required fixes are prose and table edits to `paper.tex`; no notebook re-execution is necessary.

---

### Blocking issues (require re-running a notebook)

None. The Round 1 blocking issues (degenerate RF nuisance R² computation, missing LassoCV nuisance R², and forest plot distortion) were resolved by the Stage 4 re-run between rounds. R2 and R3 confirm that `dml_results.json` now contains the corrected values (`coef = -25.471`, `rf_nuisance_degenerate: true`, `lasso_r2_outcome = 0.409`). No further notebook re-run is required this round.

---

### Major issues (prose or table edits only)

| # | Issue | Raised by | Action |
|---|-------|-----------|--------|
| M1 | **Stale DML numbers throughout `paper.tex`.** The abstract (line 32), Section 3.2 (line 166), and Section 3.3 (line 192) still quote the pre-revision LassoCV estimate of θ̂ = −23.19 (SE = 5.65, 95% CI [−34.27, −12.11], p < 0.001). The current `dml_results.json` records `coef = −25.471`, `se = 5.643`, `ci_lo = −36.531`, `ci_hi = −14.410`. The discrepancy is ~10% on the point estimate. Every hard-coded coefficient, standard error, and confidence bound in the paper must be updated to match the current JSON output. | R2 (Major #1), R3 (Blocking #1) | Update all quoted DML numbers in `paper.tex` to match current `dml_results.json`. Also update the DML direction row value in the diagnostics table (currently −23.19; must become −25.47). |
| M2 | **Diagnostics table contains stale and internally inconsistent values.** Table 3 (Diagnostic Checks) reports `R²_D = −127,810` — the value documented in `dml_results.json` as `original_rf_r2_treatment_buggy`. It also reports `R²_Y = 0.50` while the current `lasso_r2_outcome = 0.409`. The RF degenerate coefficient is described as θ̂ = −286.33, SE = 378.63 in the body text, while `dml_results.json` now records `coef = −588.594`, `se = 1218.712`. Three distinct stale entries must all be corrected. | R2 (Major #2), R3 (Major, diagnostics table) | Replace `R²_D = −127,810` with documentation that RF treatment nuisance is degenerate (excluded); update `R²_Y` to `0.409`; update the RF degenerate coefficient figures to those in the current JSON; relabel the DML direction check from `FAIL` to `WARN (expected)` consistent with `diagnostics_flags.json` language. |
| M3 | **Forest plot caption still misrepresents figure content.** The caption (line 183) states "OLS (Tables 1, 3, 6, 7), 2SLS (Table 2), and DML-PLIV (LassoCV)" but the regenerated forest plot shows only two rows: OLS (Table 6, n = 143; Table 7, n ≈ 106–109) and DML-PLIV LassoCV. Tables 1, 3, and the 2SLS row are absent. This was listed as resolved in Round 1 (Major #5), but R2 and R3 both confirm it remains incorrect in the compiled paper. The caption must be corrected now. | R2 (Minor #4), R3 (Major, forest plot caption) | Update `\caption{}` for `fig:forest` to: "OLS (Tables 6, 7) and DML-PLIV (LassoCV)." Add a parenthetical noting that historical OLS and 2SLS specifications use a different outcome variable and are reported in paper tables but omitted from this plot. |
| M4 | **First-stage F-statistic gap remains inadequately resolved.** Round 1 (Major #3) added prose acknowledging that the F-statistic "was not independently extracted in this RECAST." R1 in this round judges this insufficient: IV validity is a precondition for interpreting both the original 2SLS estimates and the PLIV extension as causal. The original Ashraf & Galor (2013) paper reports first-stage F-statistics in its published tables. At minimum, the RECAST paper must (a) cite the published F-statistic from the original paper for the 21-country 2SLS and confirm whether the instrument is strong by Staiger-Stock (1997) criteria, and (b) explicitly state that instrument strength in the PLIV context (N = 148, ML-partialled) is a separate, currently uninvestigated question. | R1 (Major) | Add a sentence in Section 2.2 citing the published F-statistic from Ashraf & Galor (2013). Add a sentence in Section 3.2 noting that first-stage strength under ML partialling is distinct from the original IV and remains unverified in this RECAST. |
| M5 | **LassoCV treatment nuisance R² (−97,090) is unexplained in the paper.** `dml_results.json` carries an explanatory note identifying this as a DoubleML prediction-array indexing artifact, not a model failure. However, the paper text offers no explanation. A reader cannot independently evaluate whether LassoCV is a valid preferred learner given this figure. The paper must explain that (a) this extreme negative value is a known artifact of how cross-fitted predictions are aggregated before calling `r2_score`, (b) the correct quality metric for `ml_m` is the DoubleML-reported RMSE (~5.73 across reps), and (c) this RMSE can be compared to the raw standard deviation of `pdiv_aa` to yield a conventional out-of-sample R². The artifactual −97,090 figure should be relegated to a footnote or appendix. | R2 (Major #3) | Add a paragraph or footnote in Section 3.2 or the diagnostics section explaining the LassoCV treatment nuisance R² artifact, presenting the RMSE-based quality metric, and retiring the −97,090 as a primary reported result. |

---

### Minor issues

| # | Issue | Raised by | Action |
|---|-------|-----------|--------|
| m1 | **`ml_r` near-zero RMSE not discussed (deferred from Round 1, Major #9).** The instrument residual Z − m̂(X) having near-zero RMSE implies the instrument is nearly fully predicted by the control set. In a PLIV context this means the effective first stage has little identifying variation remaining after ML partialling, potentially inflating variance. One sentence in Section 3.2 must address whether the LassoCV `ml_r` residual variance is non-degenerate and, if small, what this implies for first-stage strength. | R1 (Minor, deferred from Round 1) | Add one sentence in Section 3.2 noting the `ml_r` RMSE and its implications for the strength of the ML-based first stage. |
| m2 | **PLIV complier population for N = 148 cannot be mapped to the OLS or IV sub-samples (identification implication of sample gap).** The footnote added in Round 1 (Major #7) explains why N = 148 > 143/109 mechanically. R1 raises the deeper identification point: the five additional observations may be systematically different from those dropped in the quadratic OLS, meaning the LATE recovered by the PLIV is defined over a different complier population from the 2SLS or OLS estimands. Section 3.1 must state this explicitly. | R1 (Major), R3 (Minor) | Add one or two sentences in Section 3.1 noting that the PLIV complier population (N = 148) is not identical to the OLS (N = 143/109) or 2SLS (N = 21) sub-samples, and that the LATE is defined over this distinct complier set. |
| m3 | **Forest plot Table 7 label shows n = 106; inconsistent with paper text and `paper_spec.json` (n = 109).** The paper abstract states N = 106 in one place but `paper_spec.json` records `"n_obs": 109` for Table 7 col 5. The discrepancy is unexplained and undermines numerical traceability. | R3 (Major, sample size mismatch) | Verify whether the replication filter produces n = 106 or n = 109 for Table 7. Correct the forest plot label and all paper text references to agree with the verified count. Document any filter difference. |
| m4 | **Diagnostics table labels DML direction check as `FAIL` without adequate qualification.** Even after updating the stale coefficient value (addressed under M2 above), the table note should direct readers to the clarifying prose in Section 3.3. `diagnostics_flags.json` already records a note explaining why the sign change is expected. | R1 (Minor) | Covered in part by M2 action (relabel to `WARN (expected)`); also add a table note pointing to Section 3.3. |
| m5 | **Round 1 deferred minor: flat 5% threshold in pipeline inconsistent with two-tier prose rule.** `replication_check.json` applies a flat 5% threshold; the paper states 5%/10% for OLS vs. bootstrap/IV specs. The diagnostics table note should clarify that the pipeline check uses a conservative flat 5% and that the two bootstrap-SE specifications may pass under the stated 10% rule. | R1 (Minor #3, deferred Round 1), R3 (Minor) | Add a table note or footnote in the Diagnostics section clarifying the flat 5% vs. stated two-tier threshold, and noting how many specs pass under each rule. |
| m6 | **Round 1 deferred minor: n_rep = 3 cross-fitting stability not reported and not mentioned in caveats.** The paper does not report the range or standard deviation of the coefficient across 3 repetitions, and the caveats section does not mention cross-fitting repetition count as a limitation. | R1 (Minor #4, deferred Round 1), R2 (Minor #2) | Add one sentence to the Conclusion/caveats section noting that N_rep = 3 is modest and that rep-to-rep coefficient stability was not reported; acknowledge as a limitation. |

---

### Referee disagreements

**R3 classified the stale DML coefficient (M1) as a blocking issue; R2 classified it as Major.** The synthesis resolves this by treating it as Major (not blocking), because the fix requires only text edits to `paper.tex` — no notebook re-execution. The JSON output is already correct; the paper was simply not recompiled from the updated JSON after the Round 1 revision. There is no scientific or computational dispute between the referees on this point, only a classification difference. RERUN_NEEDED is therefore `no`.

**R1 did not independently flag the stale DML numbers,** focusing instead on the F-statistic gap and complier-population identification issues. This is consistent with R1's mandate (identification only) and does not represent a substantive disagreement.

**On the forest plot caption (M3):** R3 treated this as a Major issue noting it was unresolved from Round 1; R2 listed it as a Minor issue. The synthesis treats it as Major given that the Round 1 changelog explicitly marked it as resolved (Major #5) and it reappears unresolved — a regression from the prior revision's stated fixes is a more serious concern than a first-time minor finding.

---

### Already resolved (suppressed from this round)

The following issues appeared in Round 1 referee reports and are confirmed resolved in `changelog_1.md`. They are suppressed from Round 2 action items.

- **Round 1 Blocking #1 — Quadratic treatment omitted / estimand mismatch:** Section 3.1 now contains an explicit estimand clarification paragraph. Resolved.
- **Round 1 Blocking #2 — Degenerate RF nuisance R² (−127,810):** Notebook re-run corrected the shape misalignment; `dml_results.json` now flags `rf_nuisance_degenerate: true`. Resolved at the computation level (stale paper table values addressed under M2 above).
- **Round 1 Blocking #3 — Missing LassoCV nuisance R²:** LassoCV nuisance R² now computed and stored in `dml_results.json`. Resolved at the computation level.
- **Round 1 Major #1 — Estimand definition imprecise:** Section 3.1 estimand clarification block added. Resolved.
- **Round 1 Major #2 — Exclusion restriction threats unaddressed:** Section 2.1 exclusion restriction threats paragraph added with Spolaore & Wacziarg (2013) citation. Resolved (confirmed by R1 Round 2).
- **Round 1 Major #4 — Replication failures for 21-country sample:** Bullets in Section 2.2 now state sign preservation and attribute deviation to SE-type difference. Resolved.
- **Round 1 Major #6 — DML CI non-overlap under-treated:** Section 3.3 now opens with bold paragraph on non-comparability. Resolved.
- **Round 1 Major #7 — DML N = 148 vs OLS N = 143/109 unexplained:** Footnote added in Section 3.2. Partially resolved at the mechanical level; identification implication carried forward as m2 above.
- **Round 1 Minor #1 — Variable name reconciliation note:** Section 4 Data Appendix added. Resolved.
- **Round 1 Minor #2 — Table footnote SE type inconsistency:** Addressed under Major #4 edits. Resolved.
- **Round 1 Minor #5 — Conley SE failure sign/magnitude not qualified:** Addressed under Major #4 edits. Resolved.

---

### Summary for the revision agent

Five major issues (M1–M5) and six minor issues (m1–m6) require attention. All are prose or table edits to `paper.tex`; no notebook re-execution is needed. The priority order is:

1. **M1 first** — update all hard-coded DML numbers to match `dml_results.json` (−25.471, SE 5.643, CI [−36.531, −14.410]).
2. **M2** — correct all three stale entries in the diagnostics table; relabel DML direction as `WARN (expected)`.
3. **M3** — fix forest plot caption to "OLS (Tables 6, 7) and DML-PLIV (LassoCV)."
4. **M4** — cite the published Ashraf & Galor (2013) F-statistic and note that ML-partialled first-stage strength is unverified.
5. **M5** — explain the LassoCV treatment nuisance R² artifact (−97,090) and present the RMSE-based quality metric instead.
6. **m1–m6** — prose additions for complier population, n = 106/109 discrepancy, `ml_r` RMSE discussion, threshold logic note, and caveats-section additions.
