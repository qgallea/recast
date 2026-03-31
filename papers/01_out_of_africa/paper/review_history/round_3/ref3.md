## Referee 3 Report: Robustness and Replication Integrity
**Round:** 3
**Overall verdict:** Minor concerns

---

### Blocking issues

- None

---

### Major issues

- None

---

### Minor issues

- **Forest plot OLS Full Controls label shows n=106 (pipeline dropna count) rather than the original paper's n=109.** This is now documented in a footnote in Section 2.2, which adequately addresses the discrepancy for traceability purposes. The label itself on the figure has not been corrected to n=109, meaning a reader looking only at the figure sees a number that differs from `paper_spec.json`. This is acceptable given the footnote explanation, but worth noting for completeness.

- **No within-paper sensitivity analysis for the preferred DML estimate.** The conclusion (Section 5, caveat 4) now acknowledges that only n_rep=3 cross-fitting repetitions were used and that coefficient stability across repetitions was not formally verified. The robustness concern raised in Round 2 — absence of any fold-count or control-set sensitivity check — remains unresolved as an analysis gap. The paper appropriately flags this as future work; it does not rise to a blocking issue in Round 3 but should be retained in the caveats.

- **`replication_check.json` pass/fail summary ("4/6 specs replicated within 5%") is unchanged and still applies a flat 5% threshold.** The diagnostics table note now correctly explains that under the two-tier rule (5% OLS / 10% bootstrap/IV) the effective pass rate is 5/6 (83%). However, the JSON file itself (`replication_check.json`) still reads `"pass": false` and `"summary": "4/6 specs replicated within 5%"`. This is a minor internal inconsistency between the JSON artifact and the paper's prose; it does not affect any number visible to readers.

---

### Comments to the authors

**On number traceability — all blocking issues resolved.** The critical mismatch from Round 2 has been fully corrected. Every headline DML number in the paper is now traceable to `dml_results.json`: the abstract reports $\hat{\theta} = -25.47$ (95% CI: $[-36.53, -14.41]$, $p < 0.001$), matching `preferred_coef = -25.470501740757953`, `preferred_ci_lo = -36.53090237829629`, `preferred_ci_hi = -14.410101103219619`, and `pval = 6.376243002662435\times10^{-6}$. Section 3.2 reports SE = 5.64, matching `se = 5.64316524425008`. The RF degenerate estimate is now stated as $\hat{\theta} = -588.59$ (SE = 1,218.71), matching JSON exactly. The LassoCV outcome nuisance $R^2_Y = 0.41$ matches `nuisance_r2_outcome = 0.4093281020732962`. No stale numbers remain in the paper text, tables, or abstract. Traceability is complete.

**On the forest plot.** The figure is now internally consistent with its caption. The plot shows exactly three rows — OLS (Table 6, n=143), OLS Full Controls (Table 7, n=106), and DML-PLIV LassoCV (n=148) — and the caption correctly describes "OLS (Tables 6 and 7, contemporary specifications) and DML-PLIV (LassoCV)", adding an explicit parenthetical that historical OLS (Tables 1, 3) and 2SLS (Table 2) specifications use a different outcome variable and are reported in the replication table rather than plotted here. The Round 2 contradiction between caption and figure content is resolved. Visually, the RF estimate has been removed, the LassoCV CI is legible at the left of the x-axis ($-36.53$ to $-14.41$), and the two OLS rows display positive coefficients (approximately 203 and 265, consistent with `coef_linear` values from `paper_spec.json` of 203.443 and 281.173 respectively for Tables 6 and 7). The visual contrast between OLS and DML-PLIV is immediately apparent and correctly illustrates the sign-change argument in Section 3.3. The remaining minor issue — the plot label shows n=106 while `paper_spec.json` records n=109 — is now documented in a footnote in Section 2.2 and is not misleading given that explanation.

**On replication fidelity.** The two 21-country failures (Table 1 col 4 at 29.4% deviation; Table 2 col 5 at 33.5% deviation, per `replication_check.json` worst-case 33.46%) are now explained in Section 2.2 with specific reference to small-$n$ sensitivity, data-version differences, and the unavailability of Conley (1999) spatial standard errors. These are the scientifically correct explanations and they are substantive, not evasive. The four passing specifications span the 143-145 country samples for both historical and contemporary outcomes and adequately cover the paper's primary claims. The diagnostics table in Section 4 correctly records FAIL for replication pass with the 33.5% max deviation value, consistent with `diagnostics_flags.json` (`replication_pass.value = 33.46`). The table note clarifies that under the two-tier threshold the effective pass rate rises to 5/6 (83%), which is an important qualification for readers assessing replication success.

**On the diagnostics table.** All three internal inconsistencies flagged in Round 2 are resolved. The DML direction row now reads WARN rather than FAIL, with value $-25.47$ and a cross-reference to Section 3.3 where the sign change is explained. The nuisance quality row now reads WARN with the value described as "Degenerate (index artifact; excluded)", consistent with the `diagnostics_flags.json` language. The table notes block correctly reports LassoCV $R^2_Y = 0.41$ (not 0.50 as previously), flags the RF $R^2_D = -127{,}810$ as the original buggy value now superseded, and overall labels the pipeline status as WARN rather than FAIL. The paper is internally consistent across the JSON outputs, the diagnostics table, and the narrative prose. No further changes to the diagnostics section are required.
