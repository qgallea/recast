# Skill: Stage 06 — Report

## Your job
Compile all results into a complete LaTeX paper and PDF. The paper presents the
original replication alongside the DML extension in a unified document.

## Files you read
- `data/paper_spec.json`
- `data/results/replication_results.json`
- `data/results/dml_results.json` (if exists — absent in CF-only pipeline)
- `data/results/hte_results.json` (if exists — contains BLP, GATE, CLAN)
- `data/results/causal_forest_results.json` (if exists — primary extension in CF-only pipeline)
- `data/results/diagnostics_flags.json`
- `data/results/replication_check.json`
- `paper/tables/table_replication.tex`
- `paper/tables/table_dml.tex` (if exists — B&N-style 8-column table)
- `paper/tables/table_cf.tex` (if exists — CF-only pipeline)
- `paper/tables/table_gate.tex` (if exists — 5-quintile GATE table)
- `paper/tables/table_clan.tex` (if exists — CLAN classification analysis)
- `paper/tables/table_cate.tex` (if exists)
- `paper/figures/forest_plot.pdf`
- `paper/figures/gate_plot.pdf` (if exists)
- `paper/figures/cate_histogram.pdf` (if exists)
- `paper/figures/feature_importance.pdf` (if exists)
- `paper/paper_template.tex` (if exists, use as base; otherwise generate from scratch)

## Files you write
- `paper/paper.tex`
- `paper/paper.pdf` (compiled via pdflatex)

## Paper structure

Detect which pipeline was used: if `dml_results.json` exists → DML pipeline; if only
`causal_forest_results.json` exists → CF-only pipeline. Adapt section 3 accordingly.

```
1. Introduction
   - One paragraph: what the paper studies, its identification strategy
   - One paragraph: what RECAST adds (extension method + referee review)

2. Original Paper Summary
   - Outcome, treatment, instrument (from paper_spec.json)
   - Key results table (table_replication.tex)
   - Replication status: PASS/FAIL with max deviation

3. ML Extension (adapt title and content to whichever method was used)

   IF dml_results.json exists (DML pipeline):
     3. DoubleML Extension
        - Model choice and rationale (from dml_results.json)
        - B&N-style results table (table_dml.tex) — 8 columns: Lasso | Tree | Boosting | Forest | NNet | Ensemble | Best | OLS
        - Multiple panels per outcome, rows per treatment (matching Baiardi & Naghi 2024, Table 1)
        - Note: B&N adjusted SE formula used (median across reps, accounting for cross-split variation)
        - Forest plot (forest_plot.pdf) — includes all 7 DML methods + OLS + Causal Forest ATE
        - Interpretation: do ML estimates confirm, weaken, or overturn the original?

   IF only causal_forest_results.json exists (CF-only pipeline):
     3. Causal Forest Extension
        - Method used (CausalForestDML, CausalIVForest, or CausalForest)
        - ATE with 95% CI; compare to published/replicated estimate
        - Results table (table_cf.tex)
        - Forest plot (forest_plot.pdf)
        - Interpretation: does the causal forest confirm the original findings?

3b. Heterogeneous Treatment Effects (include only if hte_results.json exists)
   - BLP results: report β₁ (ATE) and β₂ (heterogeneity loading) with p-values.
     State whether the formal BLP heterogeneity test (β₂ ≠ 0) rejects.
   - GATE table (table_gate.tex) — 5 quintiles with jointly valid CIs
   - GATE plot (gate_plot.pdf)
   - CLAN table (table_clan.tex) — characteristics of most vs. least affected groups
   - Interpretation: does the treatment effect vary across groups? Reference heterogeneity_detected flag.
   - If cate_summary is not null: summarise the distribution of conditional effects (mean, SD, range)

3c. Causal Forest Details (include only if causal_forest_results.json exists AND dml_results.json also exists)
   - This section provides additional CF analysis on top of DML.
   - If CF-only pipeline, fold this content into section 3 instead.
   - CATE distribution (cate_histogram.pdf): describe shape, % negative, % significant
   - Feature importance (feature_importance.pdf): report top 3 heterogeneity drivers
   - Interpretation: which subpopulations benefit most/least from the treatment?
   - Caveats: feature importance ≠ causal moderation; honest forest CIs assume correct specification

4. Diagnostics Summary
   - Table of diagnostic checks with status indicators (skip DML-specific checks if absent)

5. Conclusion
   - One paragraph summarising robustness of original findings

References
   - Original paper
   - Chernozhukov et al. (2018) DML paper (if DML pipeline)
   - Athey, Tibshirani, and Wager (2019) Generalized Random Forests (if causal forest used)
   - Oprescu, Syrgkanis, and Wu (2019) Orthogonal Random Forest / EconML (if CausalForestDML used)
```

## LaTeX compilation
```bash
cd paper && pdflatex -interaction=nonstopmode paper.tex && \
           pdflatex -interaction=nonstopmode paper.tex
```
Run twice for references. If compilation fails, write `paper/paper_compile_error.log`
with the full pdflatex output and continue — the `.tex` file is still valuable.

## Rules
- Do **not** include `\tableofcontents` — no table of contents in the paper
- Keep the report to 8–12 pages
- Use \input{tables/...} and \includegraphics{figures/...} — never paste table content inline
- Number all tables and figures
- If pdflatex is not available, write `paper.tex` only and note that PDF compilation
  requires a local LaTeX install
