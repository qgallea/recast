# /init — Scaffold a New Paper Project

Create the standard folder structure for a new paper replication.

## Usage
```
/init <project_path>
```

## What you do

1. Read `skills/orchestrator.md` first.

2. Create this exact folder structure at `<project_path>`:
```
<project_path>/
├── .dml_project          ← marker file, write: "framework: <path to this framework>"
├── config.yaml           ← copy from templates/config_template.yaml
├── raw_data/             ← user drops paper.pdf and data here
├── data/
│   └── results/
├── code_build/           ← copy all notebooks/ + paths.py here
├── code_run/             ← empty, filled by pipeline
├── notebook/             ← empty, filled by /pedagogical-notebook
└── paper/
    ├── tables/
    ├── figures/
    ├── review_history/
    ├── prompts/          ← copy referee_*.md, synthesis_referee.md, final_referee.md, revision_agent.md from skills/
    ├── paper_template.tex  ← copy from templates/
    └── paper_spec_schema.json ← copy from templates/
```

3. After scaffolding, print:
```
✓ Project ready: <project_path>

Next steps:
  1. Copy paper PDF    → <project_path>/raw_data/paper.pdf
  2. Copy data files   → <project_path>/raw_data/
  3. Edit              → <project_path>/config.yaml
  4. Launch pipeline   → /recast <project_path>  (DML)
                       → /recast-cf <project_path>  (Causal Forest)
```

## Rules
- If the folder already exists and contains files, ask before overwriting
- Never overwrite an existing config.yaml or .dml_project
- The `.dml_project` marker is what `/recast` and `/recast-cf` use to validate the folder
