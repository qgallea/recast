## Referee 1 Report: Identification
**Round:** 3
**Overall verdict:** Minor concerns

---

### Blocking issues (re-analysis required)
- None

---

### Major issues (prose/table edits required)
- None

---

### Minor issues

1. **Replication failure for 21-country specifications remains unresolved at the data level.** The replication_check.json records `pass: false` with a worst relative deviation of 33.5 %, driven by Table 1 col 4 (OLS, 21-country, 29.4 %) and Table 2 col 5 (2SLS IV, 21-country, 33.5 %). The paper's Section 2.2 now explains these failures credibly — small-sample fragility, cleanlim filter sensitivity, and IV amplification — and the four passing specs cover the primary 143–145-country claims. This explanation is acceptable for a final report. However, the abstract states "close agreement (within threshold) for four of them" without flagging the overall replication_check status as FAIL; a one-sentence acknowledgement in the abstract that the pipeline's automated threshold check does not pass (due to the 21-country specs) would be more transparent.

2. **First-stage F-statistic not quantified in the text.** Section 2.2 (lines 138–141) references the Ashraf & Galor (2013) appendix for instrument strength and correctly cites the Staiger & Stock threshold, but does not report an actual F-statistic value for the replicated 2SLS specification. Given that the 2SLS spec is one of the two failing replications, readers cannot assess whether the replication's own first stage clears the relevance threshold. This is a disclosure gap, not an identification failure, but it should be noted.

3. **PLIV sample discrepancy (N=148 vs. N=143/109) is disclosed but the direction of potential bias is not discussed.** Section 3.1 (lines 163–171) correctly documents that five additional observations enter the PLIV sample and that they may differ systematically. A sentence noting the probable direction — that these observations likely have less extreme diversity values (since the quadratic term is what triggers missingness in the OLS sample) — would sharpen the complier population characterisation.

---

### Comments to the authors

**On the estimand and identification strategy.** The RECAST document has addressed prior concerns about estimand clarity satisfactorily. Section 2.1 now correctly specifies the instrument (`mdist_addis`), the treatment (`pdiv_aa`, ancestry-adjusted predicted diversity), and the functional form (quadratic). The exclusion restriction narrative — that migratory distance affects contemporary income only through its effect on genetic diversity — is stated clearly. The paper acknowledges the main threats to this restriction (cultural diffusion, disease environment, institutional persistence) without claiming they are fully resolved, which is the honest position given that the original authors themselves acknowledge these limitations.

**On the DML sign change and estimand distinction.** The paper's explanation of the negative DML coefficient ($\hat{\theta} = -25.47$) is now satisfactory from an identification standpoint. Section 3.3 (or equivalent) explains that PLIV linearises the quadratic treatment and recovers a LATE weighted by the instrument at the instrument-relevant margin, while OLS recovers the full quadratic slope (ATE). The diagnostics_flags.json annotation — "DML estimates linear LATE at instrument-weighted mean; OLS estimates quadratic ATE. These are different estimands." — is correctly carried into the paper. Given that the instrument (migratory distance from Africa) primarily shifts diversity in the upper tail of the distribution (populations closer to Africa have higher diversity), a negative linear LATE is mechanically consistent with the downward-sloping right arm of the hump-shaped OLS curve. This is not an identification contradiction; it is a natural consequence of local linearisation at the instrument-driven margin.

**On sample restrictions and identification consistency.** The paper targets the 143–145 country samples for historical specifications and approximately 109 countries for the preferred contemporary specification (Table 7 col 5). These restrictions are driven by data availability on genetic diversity and controls, not by the identification argument, and the paper does not impose restrictions that would selectively exclude compliers or defiers. The minor footnote discrepancy between N=106 (pipeline dropna) and N=109 (paper_spec.json) is now documented in a footnote and is immaterial to the identification logic.

**On the 21-country replication failures.** From an identification perspective, the 21-country failures are a replication engineering issue, not a conceptual identification failure. The original paper's 21-country sample uses observed (not predicted) genetic diversity (variable `adiv`), making it the only truly direct test of the biological mechanism without the first-stage prediction step. That it is also the hardest to replicate numerically (Conley spatial SEs, cleanlim filter sensitivity) is an unfortunate coincidence. The paper's explanation in Section 2.2 is adequate. The authors should resist the temptation to interpret the large deviation as evidence that the original results are fragile; the four large-sample replications, which are the paper's primary evidentiary claims, pass cleanly.
