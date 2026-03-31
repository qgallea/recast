## Referee 2 Report: DML Methods & Causal Forest
**Round:** 1
**Overall verdict:** Minor revision

---

### Methodological contribution

The DML extension is well-suited to Djankov et al. (2010). The original setting -- cross-country OLS with a continuous treatment (corporate tax rates) and 12 controls in a sample of N=50--61 -- is exactly the regime where DML offers value: p/N is large (~0.2), OLS with many controls is inefficient, and the PLR model cleanly nests the original specification. Comparing six ML learners across all 12 specifications provides genuine evidence about the robustness of the original result and aligns well with the Baiardi & Naghi (2024) benchmark. The systematic finding that DML recovers larger and more significant negative coefficients than OLS, particularly for Investment and FDI, is the central value added.

---

### DML checklist

| # | Item | Verdict | Notes |
|---|------|---------|-------|
| 1 | Model class (PLR) correct | **PASS** | PLR is correct for continuous treatment with no instruments. |
| 2 | K-fold adaptive to N | **PASS** | K=2 for N<200. All specifications use N=50--61, so K=2 is appropriate. |
| 3 | n_rep >= 20, median aggregation, adjusted SE | **SUGGESTION** (S1) | n_rep=5 with median aggregation and B&N adjusted SE formula. See S1 below. |
| 4 | "Best" selected by lowest nuisance MSE | **PASS** | Code confirms: `best_method = min(methods_ok, key=lambda m: learner_nuisance_mse[m]['mse_outcome'])`. Selection is by outcome nuisance MSE, not p-value. |
| 5 | >= 5 method classes present | **PASS** | 6 learners (Lasso, ElasticNet, DecisionTree, Boosting, Forest, NeuralNet) + Ensemble + Best = 8 columns. |
| 6 | Nuisance R^2 reported and honestly interpreted | **PASS** | Paper Table 4 discusses negative average R^2 and reports Forest best R^2_Y=0.051, R^2_D=0.090. Diagnostics section acknowledges this is a small-sample limitation. |
| 7 | Score function appropriate | **PASS** | Default DoubleML PLR score (partialling out) is used, which is correct. |
| 8 | CIs from DML SEs (not naive OLS post-residualisation) | **PASS** | CIs are computed as `median_coef +/- 1.96 * SE_adj` using the B&N adjusted formula. |
| 9 | Lasso coefficient diagnostics reported | **SUGGESTION** (S2) | `lasso_diagnostics: null` for all specifications in the JSON. The `extract_lasso_diagnostics` function exists in the code but appears to have failed silently (likely a key-format issue across DoubleML versions). |
| 10 | BLP heterogeneity test reported before GATE | **PASS** | BLP beta_2 = 1.039, p < 0.001. Correctly reported before GATE analysis. |
| 11 | GATE groups based on predicted CATE quintiles | **PASS** | Code uses `pd.qcut(S_proxy, q=5)` on predicted CATE from the Best learner. |
| 12 | Jointly valid CIs for GATE | **PASS** | Code confirms `gate_obj.confint(level=0.95, joint=True)`. |
| 13 | CLAN included | **PASS** | CLAN is reported in the paper (Table 5) and JSON (12 control variables compared). See E1 below for a labeling concern. |

---

### Essential issues

**E1. CLAN labeling inversion: "most affected" and "least affected" groups appear swapped.**

The CLAN code defines `top_q = S_proxy >= np.percentile(S_proxy, 80)` -- that is, the top quintile of the predicted CATE distribution. Since the overall treatment effect is negative (taxes reduce investment), a *high* predicted CATE means the country is *least* negatively affected (near-zero or positive CATE), while a *low* predicted CATE means the country is *most* negatively affected. However, the code labels the top-CATE group as "Most" (mapped to `mean_most_affected` in the JSON) and the bottom-CATE group as "Least" (mapped to `mean_least_affected`).

This means the paper's CLAN discussion has the group labels inverted: when it states "the most affected countries have lower trade freedom (mean 6.72) than the least affected (mean 7.52)," it is actually describing the *least* harmed countries (Q5, positive CATE) as "most affected" and the *most* harmed countries (Q1, negative CATE) as "least affected."

**Scientific justification:** This does not change any computed values (the t-test and means are correct), but it inverts the substantive interpretation of which country characteristics predict larger or smaller treatment effects. The CLAN paragraph in the paper draws a causal-intuition narrative ("countries with less open economies suffer more from corporate tax increases") that is backwards relative to the actual GATE gradient. Without correction, readers will draw the wrong policy conclusion from the CLAN table.

**Fix:** Swap the labels so that `bot_q` (lowest predicted CATE = most negative effect = most harmed) is "most affected" and `top_q` (highest predicted CATE = least negative effect) is "least affected." Update the CLAN discussion in the paper accordingly.

---

### Suggestions

**S1. Consider increasing n_rep from 5 to at least 20.**

The current n_rep=5 is below the standard recommendation of n_rep >= 20 (Chernozhukov et al., 2018). The B&N adjusted SE formula is designed to account for cross-split variation, but with only 5 repetitions the median estimate may have non-trivial sampling noise. The cross-fit stability diagnostic (SD across reps = 0.016, ratio = 0.21 for Forest) is reassuring for the primary specification, so this is not blocking. However, increasing to n_rep=20 would better justify the asymptotic validity of the adjusted SE. This is a suggestion because the current results are stable and match the B&N benchmark, so there is no evidence of bias from low n_rep.

**S2. Report Lasso variable selection diagnostics.**

The `lasso_diagnostics` field is `null` for every specification, meaning Lasso/ElasticNet coefficient counts and top selected variables are not reported. The `extract_lasso_diagnostics` function exists but apparently fails due to a key-format mismatch across DoubleML versions. Reporting which controls Lasso retains (and which it zeros out) would help readers understand why DML recovers larger coefficients than OLS -- the standard interpretation is that OLS is inefficient because it tries to estimate all 12 control coefficients, while Lasso shrinks irrelevant ones. This is informative but not essential.

**S3. Discuss the "Best" learner selection criterion more transparently.**

The "Best" learner is selected by lowest *outcome* nuisance MSE (`mse_outcome`), but the best method for the treatment nuisance can differ. For the primary specification (Investment ~ 5yr effective rate), Best selects Forest (R^2_Y = 0.051) for the outcome equation but the JSON records `best_treatment_method: ElasticNet`. The paper and diagnostics table do not explain this asymmetry. A brief note clarifying that "Best" refers to the learner with the lowest outcome MSE (and why this is the standard choice) would improve transparency.

**S4. Note the DecisionTree anomaly in some specifications.**

In Panel C (Business density ~ statutory), the Best learner is DecisionTree with R^2_Y = 0.115 and coefficient -0.037 (p = 0.70). In the same panel, Forest yields -0.089 (p = 0.11) and Lasso yields -0.115 (p = 0.04). DecisionTree is selected as "Best" on MSE grounds, but its coefficient is the smallest and least significant. This is not wrong -- MSE-based selection is methodologically correct -- but it highlights that "Best" does not always mean "most significant" or "most informative." A sentence acknowledging this would prevent misunderstanding.

---

### Comments to the authors

The DML implementation is methodologically sound. The use of PLR, K=2 folds for N < 200, median aggregation with B&N adjusted SEs, and "Best" selection by nuisance MSE all follow the Baiardi & Naghi (2024) protocol. The close match between the pipeline's Forest estimate (-0.211, SE=0.079) and the B&N benchmark (-0.204, SE=0.094) for the primary specification is striking and lends credibility to the entire analysis. The finding that 5/6 learners agree on a negative sign, with only the neural network diverging (as expected in N=61), is exactly the kind of robustness evidence that DML is designed to provide. The nuisance model quality issue (average R^2 < 0) is an inherent limitation of ML in small cross-country samples and is honestly discussed; the Forest's positive R^2 (0.051 for outcome, 0.090 for treatment) is modest but sufficient for valid DML inference, as confirmed by the low cross-fit ratio (0.21).

The heterogeneous treatment effect analysis is well-executed. The BLP test correctly rejects constant effects (beta_2 = 1.04, p < 0.001), and the GATE gradient from -1.72 (Q1) to +1.34 (Q5) with jointly valid CIs is a valuable finding that goes beyond the original paper. The one essential issue (E1) concerns the CLAN labeling, which should be corrected to avoid misleading substantive interpretation. The re-fitting with n_rep=1 for GATE compatibility is a reasonable workaround for the DoubleML API constraint.
