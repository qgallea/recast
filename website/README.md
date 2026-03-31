# RECAST — Replication and Extension with Causal AI Statistical Toolkit

**[Live site: qgallea.github.io/recast-causal-ai](https://qgallea.github.io/recast-causal-ai)**

RECAST is an autonomous multi-agent pipeline that takes a published econometrics paper and its replication data, reproduces the original results, extends them with Double/Debiased Machine Learning and Causal Forests, puts the findings through a structured AI peer review, and publishes a report — end to end.

> *"This paper has been **RECASTed**."*

---

## What RECAST does

| Step | What happens |
|------|-------------|
| **Read** | Claude reads the paper PDF and extracts the identification strategy, specifications, and variable names |
| **Replicate** | OLS/IV regressions are reproduced and checked coefficient by coefficient against published tables |
| **Extend** | 7 ML methods (Lasso, Tree, Boosting, Forest, Neural Net, Ensemble, Best) via DoubleML, with BLP heterogeneity test, 5-quintile GATE, and CLAN classification. Optional Causal Forest for individual-level CATEs. |
| **Review** | Three isolated AI referees (identification, methods, robustness) following [Berk, Harvey & Hirshleifer (2017)](https://doi.org/10.1257/jep.31.1.231) principles: contribution first, essential vs. suggested, scientific justification required |

The DML methodology follows [Baiardi & Naghi (2024, *Econometrics Journal*)](https://doi.org/10.1093/ectj/utae004): adaptive K-fold cross-fitting (K=2 for small samples), 20+ repetitions with median aggregation, B&N adjusted standard errors, and Best learner selected by nuisance MSE.

## RECASTed papers

| Paper | Year | Method | Status |
|-------|------|--------|--------|
| [Ashraf & Galor](https://qgallea.github.io/recast-causal-ai/papers/ashraf2013-cf/) — Genetic diversity & development | 2013 | Causal Forest | PASS |
| [Finkelstein et al.](https://qgallea.github.io/recast-causal-ai/papers/finkelstein2012-dml/) — Oregon Health Insurance (DML) | 2012 | DoubleML | PASS |
| [Finkelstein et al.](https://qgallea.github.io/recast-causal-ai/papers/finkelstein2012-cf/) — Oregon Health Insurance (CF) | 2012 | Causal Forest | PASS |
| [Djankov et al.](https://qgallea.github.io/recast-causal-ai/papers/djankov2010-dml/) — Corporate taxes & investment | 2010 | DoubleML | PARTIAL |

## Quick start

```bash
# 1. Scaffold a new project
/init ~/papers/my_paper

# 2. Add your files
cp paper.pdf ~/papers/my_paper/raw_data/
cp data.dta  ~/papers/my_paper/raw_data/

# 3. Edit config
nano ~/papers/my_paper/config.yaml

# 4. RECAST it
/recast ~/papers/my_paper          # DoubleML extension
/recast-cf ~/papers/my_paper       # Causal Forest extension

# 5. Publish to website
/publish ~/papers/my_paper
```

## Pipeline architecture

```
Paper PDF + Data
       │
       ▼
┌──────────────┐    ┌──────────┐    ┌──────────────┐
│ 01 Paper     │───▶│ 02 Data  │───▶│ 03 Replicate │
│ Intelligence │    │ Cleaning │    │ OLS/IV       │
└──────────────┘    └──────────┘    └──────┬───────┘
                                          │
                    ┌─────────────────────┐│┌──────────────────┐
                    │ 04 DML Extension    │││ 04-CF Causal     │
                    │ 7 methods, BLP,     │◀┤│ Forest Extension │
                    │ GATE, CLAN          │ │└──────────────────┘
                    └─────────┬───────────┘ │
                              │             │
                    ┌─────────▼───────────┐ │
                    │ 05 Diagnostics      │◀┘
                    │ 12 automated checks │
                    └─────────┬───────────┘
                              │
                    ┌─────────▼───────────┐
                    │ 06 Report           │
                    │ LaTeX → PDF         │
                    └─────────┬───────────┘
                              │
                    ┌─────────▼───────────┐
                    │ Advisor Gate        │
                    │ 3 validation checks │
                    └─────────┬───────────┘
                              │
              ┌───────────────▼───────────────┐
              │         Review Loop           │
              │  3 isolated referees           │
              │  → Synthesis (quality control) │
              │  → Revision agent              │
              │  (max 3 rounds, target 1)      │
              └───────────────┬───────────────┘
                              │
                    ┌─────────▼───────────┐
                    │ Final Referee       │
                    │ "Would I be pleased │
                    │  to have written    │
                    │  this, flaws and    │
                    │  all?"              │
                    └─────────────────────┘
```

## Technology

- **Orchestration:** [Claude Code](https://claude.ai/code) (Anthropic) — all pipeline stages are Claude Code skill files (`.md`)
- **DML:** [DoubleML](https://docs.doubleml.org) (Python) — Chernozhukov et al. (2018) framework
- **Causal Forest:** [EconML](https://econml.azurewebsites.net/) (Microsoft) — CausalForestDML, CausalIVForest
- **Website:** [Quarto](https://quarto.org) — static site deployed to GitHub Pages
- **Methodology:** Baiardi & Naghi (2024) for DML, Berk et al. (2017) for peer review

## Status

This project is **under active development and testing**. Results have not been independently verified. Do not cite or rely on any output without manual review.

## Author

[Quentin Gallea, Ph.D.](https://thecausalmindset.com)

## License

MIT
