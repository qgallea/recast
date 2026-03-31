## Changelog -- Round 1

### Blocking issues addressed

- **Issue E1:** n_rep = 5 override instead of config value (20)
  **Notebook edited:** code_build/04_dml_extension.ipynb, Cell 2 (id: 3d3fed3e)
  **Change:** Removed the hardcoded `n_rep = 5` override line. The cell now reads
  `n_rep` from `config['dml'].get('n_rep', 20)` without overriding, yielding
  n_rep = 20 as specified in config.yaml. Updated the print statement to remove the
  "for speed" qualifier. Added a `## Revision Round 1` comment block explaining the
  rationale (4 effective degrees of freedom was insufficient for stable inference
  near conventional significance thresholds).
  **Status:** Awaiting re-run

- **Issue E2:** Best learner copies Forest result wholesale instead of re-fitting with best-outcome and best-treatment learners
  **Notebook edited:** code_build/04_dml_extension.ipynb, Cell 3 (id: 1d01cedc)
  **Change:** Replaced the Best learner logic (which previously did
  `learner_results["Best"] = {**learner_results[best_outcome_method], ...}`) with a
  conditional: when `best_outcome_method == best_treatment_method`, the old copy
  approach is retained (correct in that case); when they differ, a new
  `DoubleMLPLR` is instantiated with `ml_l = clone(best_outcome_method)` and
  `ml_m = clone(best_treatment_method)`, fitted, and its median/adjusted-SE
  statistics stored as the Best result. Also stored the re-fitted Best object in
  `learner_objects` for downstream HTE use. Added a `## Revision Round 1` comment
  block explaining the fix.
  **Status:** Awaiting re-run

- **Issue E2 (downstream):** HTE cell used best_outcome_method for both ml_l and ml_m
  **Notebook edited:** code_build/04_dml_extension.ipynb, Cell 5 (id: 15c6f90c)
  **Change:** The HTE re-fit now reads both `best_outcome_method` and
  `best_treatment_method` from the Best learner result dict and uses them for
  `ml_l_hte` and `ml_m_hte` respectively, consistent with the corrected Cell 3
  logic. Added a `## Revision Round 1` comment block.
  **Status:** Awaiting re-run

### Suggestions addressed

- **Suggestion S1 (estimand clarification):** Added a paragraph in Section 3.1 of
  paper.tex formally defining theta as the partial linear marginal effect of a
  one-unit increase in D holding X fixed, distinguishing it from a binary-treatment
  ATE. Clarified that GATE estimates are group-specific marginal effects.

- **Suggestion S2 (nuisance R-squared discussion):** Added 2--3 sentences in the
  Diagnostics Discussion paragraph of paper.tex acknowledging that low R-squared_Y
  (0.094) limits the debiasing value of DML relative to OLS, and noting that the
  small fold size (N/K ~ 32) contributes to this limitation. Retained the existing
  B&N external-validation point as a mitigating factor.

- **Suggestion S4 (NeuralNet exclusion note):** Added a sentence and footnote in
  Section 3.1 of paper.tex explicitly noting that NeuralNet is included for
  transparency but excluded from Best learner selection due to catastrophic
  nuisance R-squared, with a footnote clarifying its negligible Ensemble weight.

### Suggestions deferred

- **S3 (Ensemble SE via delta method):** Requires implementing the stacking
  covariance matrix computation, which is a non-trivial methodological addition
  not currently in the pipeline. Low benefit relative to cost -- the Ensemble is
  not the preferred estimator.

- **S5 (cross-fitting stability reporting):** Requires adding per-repetition
  coefficient storage and summary statistics to the table/report infrastructure.
  The per_rep_coefs are already stored in dml_results.json; surfacing them in the
  paper requires table redesign. Deferred to a future round if needed.

- **S6 (bivariate OLS):** Requires adding a new regression to notebook 03 or 04
  and a new table column. Low benefit vs. cost for this round.

- **S7 (forest plot encoding artefact):** Will be fixed automatically on re-run
  if the encoding is a cell-output issue. If it persists, a targeted fix can be
  applied in Round 2.

- **S8 (replication SE type clarification):** Requires auditing the SE type in
  notebook 03. Low cost but not blocking; deferred.

- **S9 (CLAN power note):** The paper already notes "small sample" and
  "expected given the small sample." Adding the d~1.1 power calculation would
  require a new computation. Deferred.

- **S10 (BLP via DoubleML API):** The manual implementation is methodologically
  valid per the synthesis. Switching would be a refactor with no scientific gain.
  Deferred.

- **S11 (selection-on-observables discussion):** Would require a substantive
  paragraph on omitted variables (institutional quality, trade openness, colonial
  history). Deferred -- the original paper's identification strategy section
  already frames this as selection-on-observables.

- **S12 (K=2 fold size note):** Addressed implicitly in the enhanced nuisance
  R-squared discussion (S2), which now mentions the ~32 observations per fold.
