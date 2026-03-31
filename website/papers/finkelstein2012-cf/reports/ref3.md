## Referee 3 Report: Robustness and Replication
**Round:** 1
**Overall verdict:** Minor concerns

### Blocking issues
- None

### Major issues
- None

### Minor issues

1. **Sample size discrepancy not explained.** The paper states n = 23,741 (matching the published paper) but the replication results report n = 23,361 across all three specifications. This is a difference of 380 observations (1.6%). Despite this, the replication passes comfortably: IV/LATE replicates at 0.132 vs 0.133 (0.61% deviation), ITT at 0.039 vs 0.039 (0.78%), and first stage at 0.293 vs 0.289 (1.28%). The paper text should note the sample size difference and state the likely reason (e.g., missing covariates or different merge handling).

2. **Forest plot visual: CF CI is invisible.** The forest plot correctly shows three rows: Published IV (LATE), Replicated IV, and Causal Forest ATE. The published and replicated IV CIs are wide and clearly visible. However, the Causal Forest ATE CI is so narrow (width ~0.002) that it appears as a dot with no visible error bars. This accurately reflects the data but may mislead readers into thinking the CF estimate is known with near-certainty. A footnote or annotation on the figure explaining why the CF CI is so narrow (and flagging the SE concerns) would improve transparency. Alternatively, the plot could use a log-scale x-axis or an inset panel for the CF estimate.

3. **No robustness checks beyond the main specification.** The paper replicates three specifications from the original (IV/LATE, ITT, first stage) and runs a single CF specification. Standard robustness exercises are missing:
   - Alternative outcome definitions (e.g., self-reported health as ordinal, or other outcomes from the paper like financial strain or utilisation).
   - Subsample stability (e.g., by draw wave).
   - Placebo tests (e.g., using pre-lottery characteristics as outcomes).
   These are not blocking because the original paper's identification is well-established, but their absence limits the contribution of the extension.

4. **CF estimate not compared to OLS.** The diagnostics skip all DML-specific checks because this is a CF-only pipeline. However, the paper does not report a naive OLS estimate of the treatment effect (without instrumenting). Including an OLS estimate would help readers understand the magnitude of endogeneity bias -- the difference between the OLS and IV estimates is informative about selection into Medicaid.

5. **Numbers in LaTeX traceable to JSON.** I verified:
   - IV/LATE: paper says 0.133 (SE 0.026), paper_spec.json says 0.133 (SE 0.026), replication_results.json says 0.132 (SE 0.026) -- consistent.
   - CF ATE: paper says 0.182 (SE 0.001, CI [0.181, 0.183]), causal_forest_results.json says 0.182324 (SE 0.00056, CI [0.181227, 0.183421]) -- consistent (paper rounds SE up to 0.001, which is acceptable).
   - GATE values in Section 3.1 match hte_results.json -- consistent.
   - CATE summary statistics (mean 0.182, SD 0.086, range [0.062, 0.506], 76.7% significant) match causal_forest_results.json -- consistent.
   All numbers are traceable. No discrepancies found.

6. **Diagnostics table encoding issue.** The diagnostics table in paper.tex line 196 contains a malformed character: "all GATE CIs overlap -- homogeneous effect" appears to have a garbled character (possibly a Unicode arrow or dash that did not compile correctly). This should be checked in the compiled PDF.

### Comments to the authors

The replication is successful and well-executed. All three specifications replicate within 1.3% of the published values, comfortably below the 5% threshold. The replication_check.json confirms pass = true with worst_rel_diff_pct = 1.28. The close match despite a sample size difference of 380 observations suggests the core estimates are robust to minor data handling differences.

The forest plot is a useful visual summary. It clearly shows that the published and replicated IV estimates overlap almost perfectly, confirming replication success. The Causal Forest ATE is visibly to the right of the IV estimates, illustrating the 37% magnitude difference. However, the CF confidence interval is essentially invisible due to its extreme narrowness (width 0.002 vs ~0.10 for the IV CIs). This visual feature, while accurate, risks conveying false precision. A brief annotation noting that the CF SE may understate uncertainty would be appropriate.

The absence of robustness checks is the main gap. The original paper examines multiple outcome families (utilisation, financial strain, health), and extending the CF analysis to at least one additional outcome would strengthen the contribution. Similarly, a simple placebo test -- running the CF on a pre-treatment outcome -- would provide reassurance that the forest is not detecting spurious heterogeneity. These are suggestions for future work rather than blocking concerns, given that the replication itself is clean and the CF extension is honestly interpreted.

All numbers in the LaTeX tables are traceable to the underlying JSON result files. The paper does not introduce any numbers that cannot be verified from the pipeline outputs.
