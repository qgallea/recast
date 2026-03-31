# RECAST — Replication and Extension with Causal AI Statistical Toolkit

**[Browse RECASTed papers](https://qgallea.github.io/recast-causal-ai)** | **[Website repo](https://github.com/qgallea/recast-causal-ai)**

RECAST is an autonomous multi-agent pipeline built on [Claude Code](https://claude.ai/code) that takes a published econometrics paper and its replication data, reproduces the original results, extends them with Double/Debiased Machine Learning and Causal Forests, puts the findings through a structured AI peer review, and publishes a report — end to end.

> *"This paper has been **RECASTed**."*

---

## How it works

There are no Python entry-point scripts in this repo. The `.md` files **are** the code — they define agent roles, rules, and behaviour that Claude Code executes.

```
/recast ~/papers/djankov2010          # Full pipeline: replicate + DML + review
/recast-cf ~/papers/djankov2010       # Same but with Causal Forest
/pedagogical-notebook ~/papers/...    # Generate shareable Jupyter notebook
/publish ~/papers/djankov2010         # Publish to website
```

### Pipeline

```
Paper PDF + Data
       │
   1. Paper Intelligence ─── Claude reads the PDF + replication code
       │
   2. Data ─────────────── Load, clean, verify variables
       │
   3. Replication ──────── OLS/IV reproduced, checked coefficient by coefficient
       │
   4. DML Extension ────── 7 ML methods (Lasso, Tree, Boosting, Forest,
       │                    NNet, Ensemble, Best) with BLP/GATE/CLAN
       │
   5. Diagnostics ──────── 12 automated checks
       │
   6. Report ───────────── LaTeX paper compiled to PDF
       │
   Advisor Gate ────────── 3 validation checks (all must pass)
       │
   Review Loop ─────────── 3 isolated AI referees → synthesis → revision
       │                    (Berk, Harvey & Hirshleifer 2017 principles)
       │
   Final Referee ───────── "Would I be pleased to have written this?"
```

---

## Repository structure

```
recast/
├── CLAUDE.md                    ← project instructions for Claude Code
│
├── .claude/
│   └── commands/                ← slash commands (user-invocable)
│       ├── init.md              ← /init — scaffold a new project
│       ├── run.md               ← /run — legacy alias for /recast
│       ├── recast.md            ← /recast — full DML pipeline
│       ├── recast-cf.md         ← /recast-cf — causal forest pipeline
│       ├── stage.md             ← /stage N — re-run from stage N
│       ├── review.md            ← /review — review loop only
│       ├── final.md             ← /final — final referee only
│       └── publish.md           ← /publish — publish to website
│
├── skills/                      ← agent skill files (internal instructions)
│   ├── orchestrator.md          ← core execution rules
│   ├── notebook_runner.md       ← runs notebooks via nbconvert
│   ├── stage_01.md → stage_06.md ← per-stage instructions
│   ├── stage_04_cf.md           ← causal forest stage
│   ├── advisor_gate.md          ← 3 validation checks
│   ├── review_loop.md           ← review loop logic
│   ├── referee_1_identification.md ← identification referee
│   ├── referee_2_dml_methods.md    ← DML/CF methods referee
│   ├── referee_3_robustness.md     ← robustness referee
│   ├── synthesis_referee.md     ← deduplicates + quality-controls referees
│   ├── revision_agent.md        ← implements fixes
│   ├── final_referee.md         ← writes human-readable final report
│   ├── pedagogical_notebook.md  ← /pedagogical-notebook — shareable notebook
│   ├── publish_paper.md         ← publish logic
│   └── references/              ← econml/doubleml API references
│
├── notebooks/                   ← template notebooks (copied to each project)
│   ├── 01_paper_intelligence.ipynb
│   ├── 02_data.ipynb
│   ├── 03_replication.ipynb
│   ├── 04_dml_extension.ipynb
│   ├── 04_causal_forest.ipynb
│   ├── 05_diagnostics.ipynb
│   ├── 06_report.ipynb
│   └── paths.py
│
├── templates/
│   └── config_template.yaml     ← default config for new projects
│
├── papers/                      ← one folder per RECASTed paper
│   ├── 04_djankov_et_al_taxes/  ← Djankov et al. (2010) — PASS
│   ├── 05_nunn_trefler_tariffs/ ← Nunn & Trefler (2010) — PASS
│   └── baiardi_naghi/           ← reference replication package
│
└── website/                     ← Quarto site (separate GitHub repo)
    └── (see qgallea/recast-causal-ai)
```

### Key concepts

- **`.claude/commands/`** — Slash commands you type (e.g., `/recast`). These are thin wrappers that validate inputs and delegate to skill files.
- **`skills/`** — Detailed agent instructions. Each skill defines what files to read, what to write, what rules to follow. Skills can also be invoked directly as slash commands (e.g., `/pedagogical-notebook`).
- **`notebooks/`** — Jupyter notebook templates. Claude agents fill these with working code during pipeline execution. Executed copies go to `code_run/`; source stays in `code_build/`.
- **`papers/`** — One folder per paper being RECASTed. Created by `/init`, populated by `/recast`.

---

## Quick start

```bash
# 1. Scaffold a new project
/init ~/papers/my_paper

# 2. Add your files
cp paper.pdf ~/papers/my_paper/raw_data/
cp data.dta  ~/papers/my_paper/raw_data/
# If you have replication code (.R, .do, .py), add it too — Stage 1 reads it

# 3. Edit config
nano ~/papers/my_paper/config.yaml

# 4. RECAST
/recast ~/papers/my_paper

# 5. Generate shareable notebook (optional)
/pedagogical-notebook ~/papers/my_paper

# 6. Publish to website
/publish ~/papers/my_paper
```

## Methodological foundations

- **DML methodology:** [Baiardi & Naghi (2024)](https://doi.org/10.1093/ectj/utae004), *Econometrics Journal*. 7 ML methods, adaptive K-fold cross-fitting, median aggregation, B&N adjusted SEs, BLP/GATE/CLAN.
- **Referee process:** [Berk, Harvey & Hirshleifer (2017)](https://doi.org/10.1257/jep.31.1.231), *Journal of Economic Perspectives*. Contribution first, essential vs. suggested, scientific justification required, implicit R&R bargain.

## RECASTed papers

| Paper | Year | Method | Replication | Key DML finding |
|-------|------|--------|-------------|----------------|
| [Djankov et al.](https://qgallea.github.io/recast-causal-ai/papers/djankov2010-dml/) | 2010 | DML | PASS (0.69%) | Tax effect significant with DML where OLS was not |
| [Nunn & Trefler](https://qgallea.github.io/recast-causal-ai/papers/nunntrefler2010-dml/) | 2010 | DML | PASS (5.11%) | Tariff effect 40-55% smaller, not robust to nonlinear controls |
| [Finkelstein et al.](https://qgallea.github.io/recast-causal-ai/papers/finkelstein2012-dml/) | 2012 | DML | PASS (1.28%) | Insurance effect 24% larger than published IV |
| [Finkelstein et al.](https://qgallea.github.io/recast-causal-ai/papers/finkelstein2012-cf/) | 2012 | CF | PASS (1.28%) | CF-LATE 37% larger, heterogeneity detected |
| [Ashraf & Galor](https://qgallea.github.io/recast-causal-ai/papers/ashraf2013-cf/) | 2013 | CF | PASS (0.71%) | Hump-shaped diversity-development relationship confirmed |

## Status

This project is **under active development and testing**. Results have not been independently verified. Do not cite or rely on any output without manual review.

## Author

[Quentin Gallea, Ph.D.](https://thecausalmindset.com)

## License

MIT
