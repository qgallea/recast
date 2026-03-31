## Changelog — Round 3

### Blocking issues addressed

None. No blocking issues were raised in Round 3. No notebooks were edited.

---

### Major issues addressed

None. No major issues were raised in Round 3.

---

### Minor issues addressed

**m1 — Abstract pipeline status parenthetical**
- **Issue:** Abstract did not flag that the automated `replication_check.json` threshold check reports `pass: false` (driven by the two 21-country specs); the prose said "close agreement for four of them" without acknowledging the pipeline's overall FAIL status.
- **Synthesis item:** #1 (R1 Minor #1)
- **Location in paper.tex:** Abstract, sentence beginning "Using the RECAST pipeline, we reproduce six specifications..."
- **Change:** Added a parenthetical immediately after "for four of them" stating that the pipeline's automated flat-threshold check reports a FAIL status driven by the two 21-country specifications exceeding the 5% cutoff, and that applying the stated two-tier rule (5% OLS / 10% bootstrap-SE or IV) yields five of six specifications passing.
- **Status:** Resolved

**m2 — F-statistic source clarification in Section 2.2**
- **Issue:** The first-stage F-statistic cited in Section 2.2 is taken from the published Ashraf & Galor (2013) appendix and was not independently recomputed from the replication data; the paper did not make this explicit.
- **Synthesis item:** #2 (R1 Minor #2)
- **Location in paper.tex:** Section 2.2, paragraph beginning "Regarding instrument strength: Ashraf & Galor (2013) report a first-stage F-statistic..."
- **Change:** Added two sentences immediately after the existing F-statistic sentence, noting that the cited value is taken directly from the published appendix and was not independently recomputed in this RECAST, and that independent computation is deferred to future work.
- **Status:** Resolved

**m3 — Probable direction of bias for five extra PLIV observations (Section 3.1)**
- **Issue:** Section 3.1 documented that the five extra PLIV observations may differ systematically from the OLS sub-samples but did not characterise the probable direction.
- **Synthesis item:** #3 (R1 Minor #3)
- **Location in paper.tex:** Section 3.1 (Model Specification), paragraph beginning "These extra observations may be systematically different..."
- **Change:** Added one sentence after the existing complier-population sentence, stating that the probable direction is that the five additional observations are countries at the fringes of the diversity distribution (very high or very low `pdiv_aa`), where the quadratic term `pdiv_aa_sqr` induces missingness in the OLS sample but the PLIV model retains them.
- **Status:** Resolved

**m4 — LassoCV treatment nuisance R² claim softened (Section 3.2 footnote)**
- **Issue:** The footnote asserted that comparing the treatment nuisance RMSE (~5.73) to the SD of `pdiv_aa` "yields a conventional out-of-sample R² in the expected range." This implied R² value was not numerically computed or verified in the notebook or paper.
- **Synthesis item:** #4 (R2 Minor #1)
- **Location in paper.tex:** Section 3.2 footnote on the anomalous R²_D ≈ −97,090.
- **Change:** Replaced "yields a conventional out-of-sample R² in the expected range; the −97,090 figure should not be interpreted as indicating model failure" with a softened version that: (a) notes the implied R² has not been independently computed or verified in this RECAST, (b) flags the large RMSE relative to the scale of `pdiv_aa` as warranting further investigation and as an acknowledged limitation, (c) retains the statement that the −97,090 figure should not be interpreted as model failure but adds that the treatment nuisance quality cannot be positively confirmed from the available pipeline outputs.
- **Status:** Resolved

**m5 — Inter-repetition coefficient range disclosure (Section 3.2)**
- **Issue:** Inter-repetition coefficient variability across n_rep = 3 runs was not reported; `obj_lasso.all_coef` is available from DoubleML directly but was not extracted in the notebook.
- **Synthesis item:** #5 (R2 Minor #2)
- **Location in paper.tex:** Section 3.2, immediately after the sentence reporting the preferred LassoCV coefficient (−25.47).
- **Change:** Added two sentences stating that across the 3 cross-fitting repetitions the LassoCV coefficient was stable, with the range not formally reported, and deferring n_rep = 3 cross-fitting stability verification to future work. Exact text added: "Across the 3 cross-fitting repetitions, the LassoCV coefficient was stable (range not formally reported; n_rep = 3 cross-fitting stability is deferred to future work)." — as specified by the task instructions.
- **Note:** The notebook was not re-run; the `all_coef` range cannot be reported without re-execution. This is disclosed explicitly in the added sentence.
- **Status:** Partially resolved (disclosure added; numeric range deferred)

**m6 — Fifth caveat added to Section 5 (Conclusion) on near-zero ml_r RMSE**
- **Issue:** Near-zero `ml_r` RMSE (instrument residual after ML partialling, ~0.002–0.021) was discussed in Section 3.2 but was not listed as a named caveat in the Conclusion alongside the four existing caveats.
- **Synthesis item:** #6 (R2 Minor #4)
- **Location in paper.tex:** Section 5 (Conclusion), caveats list, immediately after the Fourth caveat.
- **Change:** Added a Fifth caveat stating that the near-zero `ml_r` RMSE (approximately 0.002–0.021 across folds) implies that most variation in the instrument is absorbed by the covariate set after ML partialling, meaning residual instrument variation available to identify the PLIV first stage may be severely limited. The caveat draws an analogy to weak instruments in classical IV and notes that the PLIV estimate may be imprecise or sensitive to specification choices even when the reported standard error appears moderate.
- **Status:** Resolved

---

### Issues not addressed (or deferred)

**Synthesis item #7 — `replication_check.json` internal inconsistency**
- **Issue:** The JSON file reads `"pass": false` and `"summary": "4/6 specs replicated within 5%"` while the paper's prose correctly applies the two-tier rule (5/6 at 83%); a minor internal inconsistency between the JSON artifact and the paper text.
- **Reason deferred:** The synthesis report explicitly states that no change to the JSON file is required, as it reflects the pipeline's conservative flat threshold. The existing diagnostics table notes in Section 4 already document the discrepancy. The abstract parenthetical added under m1 above further clarifies the two-tier vs. flat-threshold distinction at the reader-facing level. No additional change was made.
- **Status:** Acknowledged; no further action needed per synthesis instructions.

**Synthesis item #5 (numeric range of all_coef) — partial deferral**
- **Issue:** The inter-repetition coefficient range from `obj_lasso.all_coef` could not be extracted without re-running notebook 04.
- **Reason deferred:** No notebook re-run was requested or permitted in Round 3. The disclosure sentence (m5 above) acknowledges this gap explicitly.
- **Status:** Acknowledged limitation; deferred to future work.

---

`RERUN_NEEDED: no`
