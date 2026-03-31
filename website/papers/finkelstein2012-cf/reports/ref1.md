## Referee 1 Report: Identification
**Round:** 1
**Overall verdict:** Minor concerns

### Blocking issues (re-analysis required)
- None

### Major issues (prose/table edits required)
- None

### Minor issues

1. **Estimand mismatch between IV/LATE and CF ATE (Section 3).** The original paper estimates a Local Average Treatment Effect (LATE) -- the effect on compliers, i.e., those induced to enrol by winning the lottery. The CausalIVForest estimator also uses the instrument, but the paper labels its output as "ATE" (e.g., "The estimated average treatment effect (ATE) is 0.182"). In an IV framework with one-sided non-compliance, the forest-based estimand is still a LATE (or a LATE-weighted average across leaves). Calling it "ATE" without qualification may mislead readers into thinking the estimate applies to the full population, not just compliers. The paper should either (a) relabel the CF estimate as "CF-LATE" or "IV-forest LATE," or (b) add an explicit sentence clarifying that the CausalIVForest identifies the same complier-weighted estimand as 2SLS.

2. **Sample size discrepancy (minor).** The paper_spec.json reports n = 23,741 for all three published specifications, but the replication notebooks report n = 23,361 (a difference of 380 observations, ~1.6%). The paper text states "23,741 individuals who responded to the 12-month survey" (Section 2) but the diagnostics report n = 23,361. This discrepancy is small and the replication still passes, but the paper should acknowledge the difference and explain the likely cause (e.g., missing values on covariates used in the regression, or differences in merge logic).

3. **Exclusion restriction discussion could be strengthened (Section 1).** The paper correctly notes the lottery-as-instrument design. However, the introduction does not explicitly state the exclusion restriction: that lottery selection affects self-reported health *only* through its effect on Medicaid enrolment. While this is well-established in the original paper and widely accepted, a one-sentence statement would strengthen the identification section, especially since the CF extension relies on the same exclusion restriction at the leaf level.

4. **First-stage strength at the leaf level (Section 3).** The overall first-stage F-statistic is very strong (>>500 per the paper_spec notes). However, the CausalIVForest partitions the sample into leaves, and within small leaves the instrument may be weaker. The paper does not discuss whether `min_var_fraction_leaf` or similar safeguards were applied to ensure the instrument retains sufficient variation within each leaf. This is not a flaw in the original identification, but a concern about how the extension preserves it. A brief remark would suffice.

### Comments to the authors

The identification strategy is strong and well-understood. The Oregon lottery provides one of the cleanest instruments in health economics, and the original paper's 2SLS design is faithfully replicated here. The first-stage coefficient of 0.293 (replicated) with an implied F-statistic far exceeding conventional thresholds leaves no concern about instrument relevance at the aggregate level.

My main suggestion concerns the labelling of the CausalIVForest estimand. In an IV design with heterogeneous treatment effects, both 2SLS and IV-forest estimators recover a LATE -- not an ATE in the usual sense. The paper currently contrasts "the published IV/LATE of 0.133" with "the estimated average treatment effect (ATE) of 0.182" as if these target different populations, when in fact both are complier-weighted quantities. The 37% magnitude difference between them is interesting and could reflect the forest's ability to capture nonlinear response surfaces or reweight compliers differently across leaves, but the discussion should be precise about what is being compared. Relabelling the CF estimate as a LATE or adding a clarifying footnote would resolve this.

The sample size difference (23,741 vs 23,361) is minor and does not threaten the replication verdict, but should be noted transparently. Readers checking the replication against the original tables will notice the discrepancy.
