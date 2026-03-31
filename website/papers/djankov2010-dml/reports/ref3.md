## Referee 3 Report: Robustness and Replication
**Round:** 1
**Overall verdict:** Minor revision

### Replication assessment

The replication is a clear success. All four reference specifications (Investment, FDI, Business density, Entry rate regressed on the five-year effective tax rate with 12 controls) replicate within a 0.69% maximum deviation, with exact sample-size matches ($N = 61, 61, 60, 50$). All signs are correct. The 4/4 pass rate against the Baiardi & Naghi (2024) benchmarks leaves no doubt about the fidelity of the data processing and regression implementation.

### Essential issues

None --- replication is adequate and the core DML results are well-supported.

### Suggestions

1. **Lasso p-value rounding in FDI panel (Panel B).** The paper reports the FDI Lasso estimate as "$-0.148$, $p = 0.05$". The JSON records $p = 0.053$, which strictly rounds to $0.05$ only at one decimal place. Since the narrative frames Lasso as "significant at 5%," the authors should either report the p-value to two decimal places ($p = 0.05$, which is defensible) or explicitly note "marginally significant" to avoid any impression of cherry-picked rounding. This is cosmetic but worth fixing in one pass.

2. **Nuisance $R^2$ discussion could be tightened.** The diagnostics table correctly reports the FAIL flag (average $R^2_Y = -0.43$, $R^2_D = -0.18$) and the discussion paragraph provides a clear explanation: small-sample ML overfitting drives negative averages, while the best learner (Forest) achieves positive $R^2$. This is transparent and adequate. A small improvement would be to note explicitly that the B&N adjusted SE formula already penalises unstable nuisance estimates, so the FAIL flag does not mechanically invalidate the confidence intervals. One sentence would suffice.

3. **Neural network sign disagreement across panels.** The paper correctly highlights that NeuralNet diverges in the primary specification (Investment panel: $+0.063$, $p = 0.61$) and attributes this to small-sample instability. It is worth noting for completeness that the NeuralNet *agrees* on a negative sign in the other three panels (FDI: $-0.113$; Business density: $-0.048$; Entry rate: $-0.191$, $p < 0.01$). This strengthens the argument that the Investment-panel disagreement is noise rather than a systematic concern. A brief parenthetical would suffice.

4. **Forest plot inspection.** The forest plot displays all four panels (A--D) with OLS, six individual learners, Ensemble, and Best for the five-year effective rate. Visual inspection confirms: (a) all DML point estimates in Panels A, B, and D are left of OLS, consistent with the narrative that DML recovers larger effects; (b) confidence intervals for tree-based methods exclude zero in Panel A, matching the reported significance; (c) the NeuralNet estimate in Panel A is the only point clearly to the right of zero; (d) Panel D shows the tightest clustering of learners, consistent with the claim that all six are significant. The plot is accurate and well-constructed. One minor visual note: the Ensemble and Best markers use a different colour (green) which aids readability, but no legend explains the colour coding --- adding a legend entry would improve standalone interpretability.

### Comments to the authors

The replication component of this paper is exemplary. A 0.69% worst-case deviation across four specifications, with exact sample-size matches and correct signs throughout, sets a high standard for automated replication. The choice to benchmark against Baiardi & Naghi (2024) Table 1 provides a credible external reference, and the match between the pipeline's Forest estimate ($-0.211$) and the published Forest benchmark ($-0.204$) --- an 18.5% relative difference with CI overlap --- further validates the DML implementation.

The robustness picture is strong. Across the 12 outcome-treatment combinations, the DML estimates consistently recover larger negative coefficients than OLS, with several achieving significance where OLS does not. The cross-fit stability ratio of 0.21 (Forest, primary spec) indicates that the variation across repetitions is modest relative to sampling uncertainty, which is reassuring. The learner sign agreement (5/6 negative in the primary spec, 6/6 negative in the entry rate panel) provides a natural robustness check that the results do not depend on a single ML method. The sole diagnostic concern --- negative average nuisance $R^2$ --- is a known consequence of applying cross-validated ML to $N \approx 60$ with 12 controls, and the paper handles this transparently. The suggestions above are cosmetic improvements that would strengthen an already well-executed analysis; none rises to the level of an essential revision.
