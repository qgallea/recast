## Referee 1 Report: Identification
**Round:** 1
**Overall verdict:** Minor concerns

### Blocking issues (re-analysis required)
- None

### Major issues (prose/table edits required)
- **M1: Estimand inconsistency between paper text and DML section.** The introduction (Section 1) correctly states the estimand is the LATE. However, the DML extension section (Section 3) does not explicitly restate that the PLIV model targets the same LATE estimand. The paper should clarify that the PLIV model preserves the IV-based LATE interpretation, not an ATE. This is important because LATE and ATE coincide only under homogeneous treatment effects, and the GATE analysis in Section 3.3 suggests heterogeneity. A sentence clarifying that the DML-PLIV estimate is also a LATE (among compliers with the lottery instrument) would resolve this.

### Minor issues
- **m1: First-stage F-statistic not reported for DML.** The paper reports F >> 500 for the original 2SLS first stage (Section 2.1) but does not report any first-stage diagnostics for the DML-PLIV model. While the DML framework handles weak instruments differently (through the Neyman-orthogonal score), the paper should note that the instrument remains strong in the DML context, or explain why a separate F-statistic is not applicable.
- **m2: Sample size discrepancy between published paper and DML.** The published paper reports N=23,741 (paper_spec.json) but the DML analysis uses N=23,361 (dml_results.json). The difference of 380 observations (1.6%) is likely due to missing values in covariates used by the DML model. This should be explicitly acknowledged in the text with a brief explanation.
- **m3: GATE interpretation overstates heterogeneity finding.** Section 3.3 states "the results suggest meaningful heterogeneity" but the heterogeneity is driven entirely by the numhh=3 group (N=57), which the paper itself acknowledges is unreliable. Between numhh=1 (0.144) and numhh=2 (0.252), the confidence intervals overlap ([0.096, 0.191] vs [0.137, 0.367]). The paper should state more carefully that the heterogeneity finding is not robust and is driven by an implausibly small subgroup.

### Comments to the authors

The identification strategy is well-described and faithful to the original paper. The Oregon lottery provides one of the cleanest natural experiments in health economics, and the paper correctly identifies the LATE as the target estimand with lottery selection as the instrument for Medicaid enrollment. The first-stage strength (F >> 500) is exceptional and eliminates weak instrument concerns.

The DML-PLIV model is the correct choice for extending an IV design. The paper does a good job explaining why the Neyman-orthogonal score makes the DML estimates robust to poor nuisance model fit (Section 4), which is critical given the near-zero nuisance R-squared values. However, the paper should be more explicit that the DML-PLIV model targets the same LATE as the original 2SLS -- this is not merely a technical point, but affects how the 24.1% magnitude difference between the DML and published estimates should be interpreted.

The GATE analysis is a useful addition but the interpretation needs tightening. The only economically meaningful heterogeneity comparison is between numhh=1 and numhh=2, and those estimates have overlapping confidence intervals. The numhh=3 result is correctly flagged as unreliable, but the section's opening claim of "meaningful heterogeneity" overstates the evidence. A more accurate framing would be: "we find suggestive evidence that two-person households may benefit more from Medicaid, but we cannot reject equal treatment effects across the numhh=1 and numhh=2 subgroups."

The sample size discrepancy (23,741 vs 23,361) is minor but should be documented. If the 380 missing observations are due to listwise deletion on covariates, this is standard but should be stated.
