## Referee 1 Report: Identification
**Round:** 1
**Overall verdict:** Minor revision

### Contribution assessment

This RECAST adds genuine value. The original Djankov et al. (2010) paper estimates the effect of corporate taxes on investment using OLS with 12 controls in a sample of roughly 60 countries --- a setting where p/N is large enough that OLS suffers from efficiency loss and overfitting bias. The DML extension relaxes the linear functional form assumption on the nuisance functions, allows data-driven variable selection across the 12-dimensional control set, and produces a debiased treatment effect estimate via cross-fitting. The result --- a Forest coefficient of -0.211 (p = 0.008) that closely matches the independent Baiardi & Naghi (2024) benchmark of -0.204 --- demonstrates that the original finding survives a substantially more flexible estimation approach and, indeed, gains statistical significance that OLS could not deliver.

### Essential issues (must be addressed --- paper is unpublishable without these)

None --- identification is sound.

The paper correctly identifies that the original study relies on selection-on-observables (OLS with controls) rather than an IV or quasi-experimental design. The DML PLR model preserves this identification assumption: it estimates the same linear treatment effect parameter theta under the same conditional independence condition, differing only in how the nuisance functions g(X) and m(X) are estimated. The estimand (the partial effect of the tax rate on the outcome, conditional on controls) is clearly defined and consistently targeted across OLS and DML. No identification logic is altered by the extension.

### Suggestions (would improve the paper, but optional)

1. **Acknowledge the selection-on-observables limitation explicitly in the conclusion.** The paper does a good job describing the original identification strategy in Section 2, but the conclusion (Section 5) could benefit from a single sentence noting that neither OLS nor DML resolves potential endogeneity from omitted confounders (e.g., political institutions that jointly determine tax policy and investment climate). The DML extension strengthens efficiency and relaxes functional form, but it does not substitute for exogenous variation. This is well understood by the target audience, but stating it prevents over-interpretation.

2. **Briefly discuss the nuisance model R-squared in the identification context.** The diagnostics table (Table 5) reports average nuisance R-squared values of -0.43 (outcome) and -0.18 (treatment). The paper correctly notes this reflects small-sample ML overfitting and that the best learner (Forest) achieves positive R-squared. From an identification standpoint, low R-squared in the treatment model m(X) means the controls explain little of the variation in tax rates --- which actually supports the plausibility of the partially linear model, since it implies the treatment has substantial residual variation not collinear with X. This could be mentioned as a minor point in the diagnostics discussion to reassure readers.

3. **Consider noting that the GATE gradient (Q1: -1.72 to Q5: +1.34) is descriptive, not causal at the subgroup level.** The BLP test and GATE analysis in Section 3.2 are informative, and the CLAN finding about trade freedom is suggestive. However, the GATE estimates are conditional on predicted CATEs from a first-stage model, and in N = 61 with 12 quintile bins of approximately 12 observations each, the extreme quintile estimates are necessarily imprecise (as the wide CIs confirm). The paper could add a sentence noting that the heterogeneity results should be interpreted as exploratory evidence of effect variation rather than as well-identified subgroup causal effects.

### Comments to the authors

This is a well-executed RECAST. The replication is essentially exact (0.69% worst deviation, all sample sizes matching), and the DML extension provides a meaningful robustness check that strengthens the original paper's conclusions. The close alignment with the independent Baiardi & Naghi (2024) Forest estimate (-0.211 vs. -0.204) is reassuring and suggests the pipeline is correctly implemented. The choice of PLR as the DML model is appropriate given that the original design uses OLS with a continuous treatment and no instruments.

The sign agreement across learners (5/6 negative) and the cross-fit stability (ratio = 0.21) both support the credibility of the main DML result. The neural network divergence is appropriately flagged and convincingly attributed to small-sample variance. The heterogeneous treatment effect analysis is a genuine contribution beyond what the original paper or Baiardi & Naghi (2024) provide, and the finding that trade openness moderates the tax-investment relationship is economically intuitive. Overall, the identification strategy is preserved and well-documented, and the paper should proceed with at most minor revisions.
