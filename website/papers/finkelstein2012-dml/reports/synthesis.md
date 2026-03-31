## Synthesis Report -- Round 1

**Unified verdict:** Minor revision

### Blocking issues (require re-running a notebook)

None.

### Major issues (prose or table edits only)

| # | Issue | Raised by | Action |
|---|-------|-----------|--------|
| 1 | LATE estimand not explicitly restated in DML section -- reader may confuse LATE with ATE, especially given GATE heterogeneity evidence | R1 (M1) | Add a sentence in Section 3.1 clarifying that the PLIV model targets the same LATE (complier-specific) estimand as the original 2SLS. |
| 2 | Diagnostics table shows "FAIL" for nuisance quality without any in-table qualifier; misleading for table-only readers | R2 (M1), R3 | Add a footnote or in-table note to the diagnostics table (Section 4) explaining that the nuisance FAIL is expected for randomized experiments. |
| 3 | GATE CI labels say "joint" but are actually pointwise (separate subgroup fits) | R2 (m2) | Correct "joint CI" to "pointwise CI" in the GATE table caption (Table 3/tab:gate) and the gate_plot axis label. Paper text in Section 3.3 should also be corrected. |
| 4 | Magnitude difference reported as "24.1%" in text but diagnostics JSON says 23.9%; inconsistent | R3 (M1) | Harmonize to "approximately 24%" or use the precise "23.9%" throughout. |

### Minor issues

| # | Issue | Raised by | Action |
|---|-------|-----------|--------|
| 5 | Sample size discrepancy (23,741 published vs 23,361 DML) not mentioned in text | R1 (m2), R3 (m3) | Add a sentence in Section 3.1 or 3.2 noting the 380-observation difference due to missing covariate values. |
| 6 | GATE heterogeneity claim overstated -- driven by tiny numhh=3 group; numhh=1 and numhh=2 CIs overlap | R1 (m3) | Soften language in Section 3.3 to "suggestive evidence" rather than "meaningful heterogeneity." |
| 7 | First-stage F-statistic not reported for DML context | R1 (m1) | Add a note in Section 3.1 that the instrument remains strong in the DML framework. |
| 8 | Only two learners used (RF, Lasso); no boosting method | R2 (m1) | Note in Section 3.1 that results are robust across the two learners tested; acknowledge boosting as a potential extension. |
| 9 | No causal forest analysis -- should briefly explain why | R2 (m3) | Add a brief note explaining why causal forest was not used (PLIV design, categorical covariates). |
| 10 | Preferred learner selection criterion is ad hoc (RF r2 < 0.1 threshold) | R2 (m4) | Downplay "preferred" framing; emphasize robustness across both learners. |
| 11 | ITT and first-stage replication results not discussed in text, only in table | R3 (m1) | Add one sentence mentioning all three replicated specifications with their estimates. |
| 12 | Missing robustness checks (alternative outcomes, without weights, subsample) | R3 (m4) | Add a limitations sentence in the conclusion acknowledging untested robustness dimensions. |
| 13 | DML-IV magnitude difference (24%) larger than expected for randomized experiment; possible drivers not discussed | R3 | Add a sentence in Section 3.2 discussing possible drivers: sample difference, FE handling as covariates, cross-fitting. |

### Referee disagreements

None. All three referees converge on a "Minor concerns" verdict. The issues are complementary, not contradictory.

### Already resolved (suppressed from this round)

No prior rounds -- nothing to suppress.
