## Synthesis Report -- Round 1

**Unified verdict:** Minor revision

### Blocking issues (require re-running a notebook)
| # | Issue | Raised by | Notebook to fix | Specific action |
|---|-------|-----------|-----------------|-----------------|
| (none) | | | | |

### Major issues (prose or table edits only)
| # | Issue | Raised by | Action |
|---|-------|-----------|--------|
| 1 | CausalForestDML vs CausalIVForest justification missing | R1, R2 | Add a dedicated paragraph in Section 3.1 explicitly justifying the choice of CausalForestDML over CausalIVForest and discussing the identification trade-off. |
| 2 | Identification assumption shift needs stronger discussion | R1 | Expand the discussion of what is gained/lost by switching from IV to selection-on-observables. Mention that the near-zero ATE could reflect either hump-shape cancellation or attenuation bias from residual confounding. |

### Minor issues
| # | Issue | Raised by | Action |
|---|-------|-----------|--------|
| 3 | Variable name `ln_soilsuit` vs `ln_suitavg` (Section 2) | R1 | Replace "log soil suitability" with "log average soil suitability (`ln_suitavg`)" |
| 4 | Optimum diversity derivation missing | R1 | Add footnote computing pdiv_aa* = 203.443 / (2 * 142.663) = 0.713 |
| 5 | Unescaped underscores in variable names (Section 3.4, line 170-171) | R2 | Use `\texttt{ln\_abslat}` formatting for variable names |
| 6 | Forest plot scale mismatch | R1, R3 | Add annotation or stronger caption language about the different estimands |
| 7 | Replication SE discrepancy footnote | R3 | Add footnote about 4.1% SE difference likely from HC1/HC0 adjustment |
| 8 | N=145 vs N=143 sample size discrepancy | R3 | Note in text; the CF uses rows with non-missing key columns which yields 145 vs the `cleancomp` flagged 143 |
| 9 | 34% negative CATEs interpretation | R3 | Expand interpretation: maps to share of countries above the diversity optimum |

### Referee disagreements
None. All three referees agree the report is solid with minor revisions. R1 and R2 both flag the CausalForestDML vs CausalIVForest choice as a major methodological discussion point, though not a blocking issue.

### Already resolved (suppressed from this round)
(First round -- no prior changelogs.)
