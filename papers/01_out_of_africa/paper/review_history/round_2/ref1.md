## Referee 1 Report: Identification

**Round:** 2
**Overall verdict:** Minor concerns

---

### Blocking issues (re-analysis required)

- None

---

### Major issues (prose/table edits required)

- **First-stage F-statistic still uncomputed (Section 2.2).** Round 1 flagged the absence of first-stage F-statistics for both the 21-country and 145-country 2SLS specifications. The changelog documents that Round 1 addressed this only partially: prose was added acknowledging the Staiger-Stock (1997) threshold and noting that the F-statistic "was not independently extracted in this RECAST." This is insufficient. IV validity is a precondition for interpreting both the original paper's 2SLS estimates and the PLIV extension as causal. The replication data are available; Stage 3 must extract and report first-stage F for the 2SLS specification (Table 2, col 5) and, ideally, for the reduced-form counterpart. If the F-statistic is genuinely unextractable from the current pipeline without code changes, the paper must state explicitly that IV identification strength is unverified in this RECAST and that all 2SLS-dependent claims are conditional on the original paper's reported strength — which should be cited from the original publication.

- **DML sample size discrepancy unresolved at the identification level (Section 3.2).** The changelog records that a footnote was added to Section 3.2 explaining that the DML uses $N = 148$ versus $N = 143$/$109$ for OLS because the linear-only treatment vector drops a missingness requirement for `pdiv_aa_sqr`. However, the identification implication is deeper than a data footnote: if the five additional observations are countries that failed the `pdiv_aa_sqr` completeness check, they may be systematically different in ways correlated with the instrument. The complier population implicitly defined by the PLIV for $N = 148$ is therefore not the same complier population as that underlying the 2SLS with $N = 21$ or the OLS with $N = 109$. Section 3.1 must explicitly state this and note that the LATE recovered by the PLIV is defined over a complier population that cannot be directly mapped to any OLS or IV sub-sample in the original paper. This is a prose edit, not a re-analysis.

---

### Minor issues

- **Diagnostics table (Section 4) continues to label DML direction as "FAIL" without adequate qualification.** Table 4 (RECAST Diagnostic Checks) reports DML direction status as "FAIL" with value $-23.19$ and note "Sign change vs. OLS." The changelog records that Section 3.3 now opens with an explicit statement that the DML CI and OLS coefficients are not comparable estimates of the same parameter. However, the diagnostics table itself — which many readers will consult directly — still presents the sign change as a failure without pointing to the clarifying prose. The table note for "DML direction" should be updated to read something like: "Sign change vs. OLS — expected; DML estimates linear LATE at complier mean (see Section 3.3); not a contradiction of the hump-shaped story." This is consistent with what `diagnostics_flags.json` itself now records as the note for this check.

- **Deferred: near-zero `ml_r` RMSE not discussed (changelog item Major #9).** The changelog explicitly deferred this to Round 2. The instrument residual $Z - \hat{m}(X)$ having near-zero RMSE implies that the instrument is nearly fully predicted by the control set, which in a PLIV context means the effective first stage has little identifying variation remaining after ML partialling. This is an identification-adjacent concern: if $Z$ is nearly collinear with $X$ after ML adjustment, the PLIV coefficient $\hat{\theta}$ is identified off residual variation that may be negligibly small, inflating variance. Section 3.2 must include at least one sentence noting whether the LassoCV `ml_r` residual variance is non-degenerate and, if it is small, what this implies for the strength of the ML-based first stage. This is a prose edit only.

- **Round 1 Minor #3 (threshold logic) and Minor #4 ($n\_\text{rep} = 3$) remain deferred without a resolution timeline.** Both were explicitly deferred in the changelog. Minor #3 (flat 5% cutoff applied where a tiered 5%/10% rule is stated in prose) creates a mismatch between what the paper claims and what the pipeline computes. Minor #4 ($n\_\text{rep} = 3$ is on the low end for cross-fitting stability in small samples) is a methodological limitation that, if unaddressed, should at minimum appear in the paper's caveats section. The current caveats in the Conclusion (Section 5) mention modest sample size and degenerate RF nuisance but do not mention cross-fitting repetition count. One sentence should be added.

---

### Comments to the authors

**On the resolution of Round 1 blocking issues.** The two substantive identification concerns from Round 1 — the estimand mismatch between the linear PLIV and the quadratic ATE, and the degenerate RF nuisance $R^2$ — have been addressed at the prose level. The estimand clarification in Section 3.1 and the opening of Section 3.3 now correctly state that $\hat{\theta} = -23.19$ is a linear LATE at the instrument-weighted complier mean and that direct numerical comparison with the OLS coefficients ($\approx 200$--$280$) is not valid. This is the correct framing, and the paper is now internally consistent on this point. The RF degeneracy is acknowledged, the degenerate estimate is quarantined, and the preferred LassoCV result is correctly foregrounded. These changes resolve the blocking issues that prevented Round 1 acceptance.

**On the first-stage F-statistic.** This issue was flagged as Major in Round 1 and is still unresolved at the level required for an IV-based paper. The changelog records a prose acknowledgement that the F-statistic was not computed, which is honest but not sufficient. The original Ashraf and Galor (2013) paper reports first-stage results, and these figures are available from the published tables. At a minimum, the RECAST paper should cite the published F-statistic from the original paper (for the 21-country 2SLS) and note whether the replicated first-stage regression — even if the second-stage coefficient deviates by 33.5% — preserves a strong instrument. The identification claim of the PLIV extension rests on the same instrument; its strength in the PLIV context ($N = 148$, ML-partialled) is a distinct and currently uninvestigated question.

**On the exclusion restriction discussion (Round 1 Major #2, now resolved).** The addition in Section 2.1 of explicit threat channels — Neolithic timing, disease ecology, and Eurasian trade networks — together with the Spolaore and Wacziarg (2013) citation, adequately addresses what was requested. The paper now correctly frames the exclusion restriction as an untestable maintained assumption and points readers to the literature's responses. No further action is needed on this point.

**On the PLIV identification logic more broadly.** Having resolved the Round 1 blocking issues, the paper is now in a defensible position on the identification of the PLIV estimand: it correctly estimates a linear LATE for complier countries defined by instrument variation, uses the same pre-determined instrument as the original paper, and clearly labels what the estimand is and is not. The remaining concerns above are prose clarifications that strengthen the paper's credibility without requiring new analysis. The authors should prioritise the first-stage F-statistic gap and the `ml_r` residual discussion, as these are the two places where a methodologically informed reader would most naturally question whether the PLIV coefficient is identified off adequate variation.
