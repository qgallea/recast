# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# RECAST — Replication and Extension with Causal AI Statistical Toolkit

Autonomous pipeline to replicate and extend empirical econometrics papers
using Double/Debiased Machine Learning (DoubleML).

The pipeline is implemented entirely as **Claude Code slash-command skills** — `.md` files that define agent roles, rules, and behavior. There are no Python entry-point scripts in this directory; the `.md` files *are* the code.

---

## Project name and terminology

The project is called **RECAST** — *Replication and Extension with Causal AI Statistical Toolkit*.

The name is also a verb. Use the following terminology consistently across all
skill files, website content, referee reports, and user-facing output:

| Term | Meaning |
|------|---------|
| **to RECAST** a paper | To run the full pipeline on a paper (replicate + extend + review) |
| **RECASTed** | A paper that has completed the full pipeline |
| **a RECAST** | The output package: replicated results, DML extension, and referee-reviewed report |
| **RECASTing** | The process of running the pipeline |
| **RECAST score** | *(future)* A summary quality metric for a RECASTed paper |

Examples of correct usage:
- "This paper has been RECASTed." (not "replicated and extended")
- "Run `/recast` to RECAST your paper."
- "Browse RECASTed papers in the Papers section."
- "The RECAST of Acemoglu (2001) finds..."

---

## Quick start

```
# 1. Scaffold a new project
/init ~/papers/acemoglu2001

# 2. Add your files
cp acemoglu2001.pdf ~/papers/acemoglu2001/raw_data/paper.pdf
cp replication_data.dta ~/papers/acemoglu2001/raw_data/

# 3. Edit config
nano ~/papers/acemoglu2001/config.yaml

# 4. Launch (DML or Causal Forest)
/recast ~/papers/acemoglu2001
# or: /recast-cf ~/papers/acemoglu2001

# 5. Generate shareable notebook (optional, after reviewing results)
/pedagogical-notebook ~/papers/acemoglu2001

# 6. Publish to website
/publish ~/papers/acemoglu2001
```

---

## Repository layout

```
causal_ml_extension/
├── CLAUDE.md
├── .claude/
│   └── commands/               ← user-invocable slash commands
│       ├── run.md
│       ├── init.md
│       ├── stage.md
│       ├── review.md
│       └── final.md
└── skills/                     ← internal sub-agent skill files (also invocable as slash commands)
    ├── orchestrator.md
    ├── notebook_runner.md
    ├── pedagogical_notebook.md  ← /pedagogical-notebook: generate shareable Jupyter notebook
    ├── advisor_gate.md
    ├── review_loop.md
    ├── revision_agent.md
    ├── referee_1_identification.md
    ├── referee_2_dml_methods.md
    ├── referee_3_robustness.md
    ├── synthesis_referee.md
    └── final_referee.md
```

## Slash commands (`.claude/commands/`)

| Command | File | What it does |
|---------|------|-------------|
| `/recast <project>` | `recast.md` | Full pipeline with **DoubleML** extension |
| `/recast-cf <project>` | `recast-cf.md` | Full pipeline with **Causal Forest** extension |
| `/run <project>` | `run.md` | Legacy alias for `/recast` |
| `/recast-cf <project>` | `recast-cf.md` | Full pipeline with **Causal Forest** instead of DoubleML at stage 4 |
| `/init <project>` | `init.md` | Scaffold a new project folder |
| `/stage N <project>` | `stage.md` | Re-run from stage N to 6, then review loop |
| `/review <project>` | `review.md` | Review loop only (analysis already done) |
| `/final <project>` | `final.md` | Final referee report only |
| `/pedagogical-notebook <project>` | `pedagogical_notebook.md` | Generate a shareable Jupyter notebook from completed RECAST |
| `/publish <project>` | `publish.md` | Publish a finished paper to the website |

Every slash command reads `skills/orchestrator.md` first before taking any action.

---

## Skill files (`skills/`)

| File | Role |
|------|------|
| `orchestrator.md` | Core execution rules; read at the start of every command |
| `notebook_runner.md` | Executes a single notebook via `nbconvert` (maps stage 4 OR 4cf) |
| `advisor_gate.md` | Three independent validation checks before the review loop |
| `review_loop.md` | Peer review loop logic (referees → synthesis → revision, up to 3 rounds) |
| `referee_1_identification.md` | Referee evaluating causal identification only |
| `referee_2_dml_methods.md` | Referee evaluating DoubleML implementation only |
| `referee_3_robustness.md` | Referee evaluating replication fidelity and robustness only |
| `synthesis_referee.md` | Deduplicates and prioritizes the three referee reports |
| `revision_agent.md` | Implements changes from synthesis; the only agent that writes to `paper.tex` and `code_build/` |
| `final_referee.md` | Writes `paper/review_history/final_report.md` |
| `publish_paper.md` | Reads pipeline JSON outputs and writes a populated `website/papers/<slug>/` page |

---

## Project layout (one folder per paper)

Created by `/init`. The marker file `.dml_project` identifies a valid project.

```
~/papers/acemoglu2001/
├── .dml_project             ← marker file (do not delete)
├── config.yaml              ← edit before running
│
├── raw_data/                ← DROP FILES HERE
│   ├── paper.pdf
│   └── *.dta / *.csv
│
├── data/
│   ├── paper_spec.json      ← READ-ONLY after stage 1
│   ├── dataset.parquet
│   └── results/             ← JSON outputs from each notebook
│
├── code_build/              ← SOURCE notebooks (edit here if needed)
│   ├── paths.py             ← imported by every notebook; resolves all paths
│   └── 0N_*.ipynb
│
├── code_run/                ← EXECUTED notebooks (never edit)
│
└── paper/
    ├── paper.tex / paper.pdf
    ├── tables/ figures/
    ├── prompts/             ← per-project copies of referee skill files
    └── review_history/
        ├── round_N/
        │   ├── ref1.md, ref2.md, ref3.md
        │   ├── synthesis.md
        │   └── changelog_N.md
        └── final_report.md  ← READ THIS
```

---

## Pipeline stages

| Stage | Notebook | Input | Output |
|-------|----------|-------|--------|
| 1 | 01_paper_intelligence | raw_data/paper.pdf | data/paper_spec.json |
| 2 | 02_data | raw_data/ | data/dataset.parquet |
| 3 | 03_replication | data/ | data/results/replication_*.json, paper/tables/table_replication.tex |
| 4 | 04_dml_extension | data/ | data/results/dml_results.json, paper/tables/table_dml.tex, paper/figures/forest_plot.pdf |
| 4cf | 04_causal_forest | data/ | data/results/causal_forest_results.json, paper/figures/forest_plot.pdf, paper/figures/cate_histogram.pdf |
| 5 | 05_diagnostics | data/results/ | data/results/diagnostics_flags.json |
| 6 | 06_report | data/ + paper/tables/ + paper/figures/ | paper/paper.tex + paper/paper.pdf |
| — | Advisor Gate | data/results/ | gate pass/fail (all 3 checks must pass) |
| — | Review loop (×3 max) | paper/paper.tex | paper/review_history/round_N/ |
| — | Final referee | review_history/ | paper/review_history/final_report.md |

---

## Notebook execution

The orchestrator runs notebooks with:

```bash
jupyter nbconvert --to notebook --execute --inplace \
  --ExecutePreprocessor.timeout=1800 \
  --output-dir <project>/code_run/ \
  <project>/code_build/0N_*.ipynb
```

Notebooks must be executed with `cwd = <project>/code_build/` because they import `from paths import *` to resolve all file paths.

---

## Key design rules

- **`code_build/` is source. `code_run/` is output.** Never edit files in `code_run/`.
- **`data/paper_spec.json` is read-only** after notebook 01 completes.
- **`paper/review_history/` is append-only.** Revision agent adds `changelog_N.md`; never overwrites.
- **Referee isolation:** each of the 3 referees is a separate agent call with its own system prompt (from `paper/prompts/`) and reads *only* the files listed in that skill's "Files you read" section — no access to the other referees' reports. Synthesis is the first agent that sees all three.
- **Revision appends, never overwrites:** when a notebook is patched during revision, a `## Revision Round N` section is appended at the bottom of the relevant cell; existing cells are never touched.
- **Blocking issues trigger a re-run:** if synthesis flags blocking issues, the revision agent edits `code_build/` and signals `RERUN_NEEDED: yes`, which causes the orchestrator to re-run `/stage 4`.
- **State is the filesystem:** agents communicate exclusively through files. Check file existence to determine pipeline state (e.g., `data/paper_spec.json` exists → stage 1 done).

---

## What to read after the pipeline runs

1. **`paper/review_history/final_report.md`** — human-readable summary: what was solved, what remains, severity table, key numbers comparison.
2. **`paper/paper.pdf`** — the compiled paper.
3. **`paper/figures/forest_plot.pdf`** — visual replication check + DML comparison in one plot.
4. **`paper/review_history/round_N/`** — full referee reports and changelogs for each round.
