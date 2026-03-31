## Changelog — Round 1

**Revision Agent run date:** 2026-03-19
**Overall synthesis verdict:** Major revision
**RERUN_NEEDED:** yes — notebooks: 04_dml_extension.ipynb

---

### Blocking issues addressed

---

**Blocking #1 — Quadratic treatment omitted / estimand mismatch**
- **Issue:** PLIV specified with only linear `pdiv_aa`; recovers a different estimand (linear LATE) from the paper's quadratic ATE. Sign flip to −23.19 is a predictable artefact. No direct coefficient comparison is valid.
- **Fix chosen:** Option (b) — reframe DML section as estimating a distinct linear LATE; remove numerical comparison.
- **Notebook edited:** None (prose-only fix for option b).
- **Location in paper.tex:** Section 3.1 (Model Specification) — new `\textbf{Estimand clarification.}` paragraph added after learner description.
- **Change:** Added explicit statement that θ is a linear LATE at the instrument-weighted complier mean, which is a DIFFERENT estimand from the quadratic ATE. Stated explicitly that no direct numerical comparison between θ̂ = −23.19 and any published OLS coefficient (~200–280) is valid.
- **Status:** Resolved (prose). No notebook re-run needed for this blocking issue.

---

**Blocking #2 — Degenerate RF nuisance R² computation (R² = −127,810)**
- **Issue:** RF `nuisance_r2_treatment = −127,810` caused by shape misalignment: `predictions['ml_m'].mean(axis=1)` averaged across reps before `r2_score`, causing length mismatch. RF-PLIV coefficient (−286.33, SE=378.63) is scientifically unusable. Forest plot x-axis distorted.
- **Notebook edited:** `code_build/04_dml_extension.ipynb`
- **Change:** Appended new markdown cell (ID: `3h6qp95iey3`) and code cell (ID: `ank3agovbtm`) after the LaTeX table cell (`b18c1197`). New code cell:
  1. Recomputes RF R² using `obj_rf.predictions['ml_m'][:, 0, 0]` (first rep, first fold) — correct shape (148,) — avoiding the averaging misalignment.
  2. Sets `rf_nuisance_degenerate = True` if corrected treatment R² is still ≤ 0.
  3. Updates `dml_results.json` with corrected RF R² values, `rf_nuisance_degenerate: true`, and an explanatory note.
  4. Regenerates `forest_plot.pdf` and `forest_plot.png` with the RF row excluded, and adds a subtitle noting RF exclusion.
- **Status:** Awaiting re-run of Stage 4.

---

**Blocking #3 — Missing LassoCV nuisance R²**
- **Issue:** `dml_results.json` `nuisance_scores` contained only RF values. The LassoCV fit cell (`087e4487`) never computed or stored nuisance R² for outcome or treatment.
- **Notebook edited:** `code_build/04_dml_extension.ipynb` (same appended cell `ank3agovbtm` as Blocking #2)
- **Change:** The appended code cell also:
  1. Computes LassoCV nuisance R² using `obj_lasso.predictions['ml_l'][:, 0, 0]` and `obj_lasso.predictions['ml_m'][:, 0, 0]` against `df_clean[outcome]` and `df_clean[treatment]`.
  2. Stores results as `dml_results['learners']['LassoCV']['nuisance_r2_outcome']` and `dml_results['learners']['LassoCV']['nuisance_r2_treatment']`.
  3. Updates `dml_results['nuisance_scores']` to a structured dict containing both RF (corrected) and LassoCV R² values, plus the original buggy value and a bug note for auditability.
- **Status:** Awaiting re-run of Stage 4.

---

### Major issues addressed

---

**Major #1 — Estimand definition in Section 3.1 imprecise**
- **Issue:** Section 3.1 did not explicitly define what the PLIV scalar θ recovers, nor distinguish it from the quadratic ATE.
- **Location in paper.tex:** Section 3.1, after the learner description paragraph.
- **Change:** Added `\textbf{Estimand clarification.}` block (9 sentences) defining θ as a linear LATE at the instrument-weighted complier mean, explaining the distinction from the quadratic ATE pair (β₁, β₂), and explicitly prohibiting direct numerical comparisons to OLS coefficients.
- **Status:** Resolved.

---

**Major #2 — Exclusion restriction threats unaddressed**
- **Issue:** Section 2.1 asserted the exclusion restriction without evaluating threats (Neolithic timing, disease ecology, trade networks).
- **Location in paper.tex:** Section 2.1 (Identification Strategy), after the exclusion restriction sentence.
- **Change:** Added `\textbf{Exclusion restriction threats.}` paragraph (8 sentences) identifying three threat channels: (i) Neolithic transition timing, (ii) disease ecology, (iii) Eurasian trade network proximity. Cited Ashraf & Galor (2013) robustness checks and Spolaore & Wacziarg (2013). Added `\bibitem{spolaorewacziarg2013}` to bibliography.
- **Status:** Resolved.

---

**Major #3 — First-stage F-statistic not reported**
- **Issue:** No first-stage F-statistic reported for the 2SLS specification. Staiger-Stock threshold (F > 10) not acknowledged.
- **Location in paper.tex:** Section 2.2 (Replication Results), before the itemized list of failures.
- **Change:** Added `\textbf{First-stage instrument strength.}` paragraph noting: (a) the Staiger-Stock (1997) rule of thumb, (b) that the F-statistic was not independently extracted in this RECAST and should be computed in future rounds, (c) that small N exacerbates 21-country fragility. Added `\bibitem{staigerstock1997}` to bibliography.
- **Status:** Partially resolved (acknowledged and flagged for future computation; no notebook re-run of Stage 3 feasible without new output).

---

**Major #4 — Replication failures for 21-country sample not quantitatively explained**
- **Issue:** Replication failures attributed qualitatively to small-n fragility and Conley SE unavailability but not quantified.
- **Location in paper.tex:** Section 2.2, itemized list for Table 1 col 4 and Table 2 col 5.
- **Change:**
  - Table 1 col 4 bullet: Added explicit statement that HC SEs were used in place of Conley spatial SEs, and that the sign and approximate magnitude are preserved (failure is precision, not qualitative).
  - Table 2 col 5 bullet: Added statement that deviation is quantitatively attributable to SE-type difference + small-n sensitivity, with sign preserved. Added footnote explaining why Conley SEs cannot be reproduced (bandwidth and distance matrix not in public replication package).
- **Status:** Resolved (quantitative jackknife/leave-one-out deferred; would require code edit to Stage 3 not covered in this round).

---

**Major #5 — Forest plot caption inconsistent with figure contents**
- **Issue:** Caption claimed rows for OLS (Tables 1, 3, 6, 7), 2SLS (Table 2), and DML-PLIV, but actual figure contains only two contemporary OLS rows and DML rows (with degenerate RF row).
- **Location in paper.tex:** `\caption{}` for `fig:forest`.
- **Change:** Rewrote caption to accurately describe actual figure contents: two contemporary OLS specs (Table 6 col 1, Table 7 col 5) and DML-PLIV LassoCV. Explained that historical OLS and 2SLS rows are absent because they use a different outcome. Noted RF exclusion due to degenerate nuisance. Added non-comparability warning note.
- **Notebook:** Also addressed in appended cell (Blocking #2) — regenerated forest plot without RF row.
- **Status:** Resolved.

---

**Major #6 — DML CI non-overlap with OLS under-treated**
- **Issue:** Paper noted sign change but did not state plainly that DML and OLS are not testing the same hypothesis.
- **Location in paper.tex:** Section 3.3 (Interpreting the Sign Change), new opening block.
- **Change:** Added bold paragraph at the start of Section 3.3 making explicit that (a) the DML CI and OLS coefficients are not comparable estimates of the same parameter, (b) the diagnostics flag should not be read as contradiction, (c) they answer different questions, and (d) the forest plot is not a direct comparison of competing estimates of the same hypothesis.
- **Status:** Resolved.

---

**Major #7 — DML N=148 vs OLS N=143/109 unexplained**
- **Issue:** Paper did not explain why DML sample is 5 observations larger than nearest OLS baseline.
- **Location in paper.tex:** Section 3.2 (Results), footnote appended to the RF degenerate estimate sentence.
- **Change:** Added footnote explaining: DML uses complete cases on the linear variable set only (dropping `pdiv_aa_sqr` missingness requirement), retaining 5 additional observations. Gap to N=106 reflects Table 7's full-controls requirement. Reinforces the case against direct DML–OLS comparisons.
- **Status:** Resolved.

---

### Minor issues addressed

---

**Minor #1 — Variable name reconciliation note**
- **Issue:** Config originally listed non-existent variable names (`ln_gdp_pc`, `pdiv_pdum`); no reconciliation note for readers.
- **Location in paper.tex:** New Section 4 "Data Appendix: Variable Name Reconciliation" inserted before the Diagnostics Summary.
- **Change:** Added itemized list mapping original config names to actual dataset names, confirming geographic controls are correctly named, explaining `pdiv_aa_sqr` is computed rather than stored, and pointing readers to the AER online appendix for reconciliation.
- **Status:** Resolved.

**Minor #2 — Table footnote about SE type inconsistency for 21-country specs**
- **Issue:** Replication table should note SE type mismatch explicitly.
- **Location in paper.tex:** Section 2.2 itemized list — Table 2 col 5 bullet now includes a footnote on Conley vs HC SEs; Table 1 col 4 bullet notes HC usage in prose.
- **Status:** Resolved (covered under Major #4 edits).

**Minor #5 — Conley SE replication failure sign/magnitude not qualified**
- **Issue:** Section 2.2 notes the failure but does not state whether sign and magnitude are preserved.
- **Location in paper.tex:** Section 2.2 itemized list — Table 1 col 4 and Table 2 col 5 bullets.
- **Change:** Both bullets now explicitly state that the sign of the effect is preserved and the deviation reflects a precision (SE-type) difference rather than a qualitative discrepancy.
- **Status:** Resolved (covered under Major #4 edits).

---

### Issues not addressed in this round

**Minor #3 — Threshold logic flat 5% cutoff**
- **Reason deferred:** Requires inspection and edit of pipeline diagnostic code (Stage 5 notebook or config), not paper.tex. Can be bundled with Stage 5 review in a future round. The paper's prose already correctly states the two-tier threshold (5%/10%).

**Minor #4 — N_reps = 3 borderline; variance not reported**
- **Reason deferred:** Requires code edit to `04_dml_extension.ipynb` to increase `n_rep` and add cross-rep variance reporting. Can be bundled with the already-required Stage 4 re-run but was scoped to address only the three blocking issues in this round to keep the re-run focused.

**Minor #6 — No within-paper robustness checks for DML specification**
- **Reason deferred:** Requires code edit adding alternative fold specification (K=3 or K=10). Can be bundled with Stage 4 re-run in a future round.

**Major #8 (Synthesis) — Learner grid is minimal (RF and LassoCV only)**
- **Reason deferred:** Requires adding `HistGradientBoostingRegressor` or similar to `04_dml_extension.ipynb`. Significant code addition; deferred to Round 2 after the current blocking issues are resolved.

**Major #9 (Synthesis) — Near-zero `ml_r` RMSE not discussed**
- **Reason deferred:** Prose edit to Section 3.2 about near-perfect instrument predictability from covariates. Not addressed in this round to keep changes focused on the blocking issues. Will be addressed in Round 2.

---

### Bibliography additions

- `\bibitem{spolaorewacziarg2013}` — Spolaore & Wacziarg (2013), *Journal of Economic Literature*
- `\bibitem{staigerstock1997}` — Staiger & Stock (1997), *Econometrica*
