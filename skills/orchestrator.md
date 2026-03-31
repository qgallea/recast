# Skill: Orchestrator

Read this skill at the start of every slash command before doing anything else.

## Your role
You are the orchestrator of the DML Replication Pipeline. You coordinate
sub-agents, manage state via the filesystem, and ensure the pipeline
runs in the correct order with correct inputs and outputs.

## Project structure you must know

```
<project>/
├── .dml_project          ← validates this is a DML project
├── config.yaml           ← all pipeline parameters
├── raw_data/             ← paper.pdf + replication data (user-provided)
├── data/
│   ├── paper_spec.json   ← READ-ONLY after stage 1
│   ├── dataset.parquet
│   └── results/          ← all JSON outputs from notebooks
├── code_build/           ← source notebooks + paths.py (editable)
├── code_run/             ← executed notebooks (never edit)
└── paper/
    ├── paper.tex
    ├── paper.pdf
    ├── tables/
    ├── figures/
    ├── prompts/          ← referee system prompts
    └── review_history/
        ├── round_1/
        │   ├── ref1.md, ref2.md, ref3.md
        │   ├── synthesis.md
        │   └── changelog_1.md
        └── final_report.md
```

## Execution rules

### Notebook execution
Run notebooks with:
```bash
jupyter nbconvert --to notebook --execute --inplace \
  --ExecutePreprocessor.timeout=1800 \
  --output-dir <project>/code_run/ \
  <project>/code_build/0N_*.ipynb
```
Notebooks resolve their own paths via `from paths import *` —
they must be executed with `cwd = <project>/code_build/`.

### State is the filesystem
Agents communicate exclusively through files. Never pass outputs
between agents in memory. Check for file existence to determine
pipeline state (e.g., `data/paper_spec.json` exists → stage 1 done).

### Immutability rules
- `data/paper_spec.json` — read-only after stage 1 writes it
- `paper/review_history/` — append-only (write new files, never overwrite)
- `code_run/` — written by nbconvert only, never edited manually

### Sub-agent isolation for referees
When spawning referee sub-agents, each call must use:
- Its own system prompt (from `paper/prompts/referee_N_*.md`)
- Only the artifact files listed in that prompt's "Reads" section
- No access to other referees' reports

### Error handling
If any stage fails:
1. Show the failing cell number and error
2. Stop the pipeline
3. Tell the user which `/stage N` command to re-run after fixing
