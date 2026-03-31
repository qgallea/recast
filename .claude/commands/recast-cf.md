# /recast-cf — RECAST a Paper with Causal Forest

Launch the complete RECAST pipeline using **Causal Forest** as the extension
method instead of DoubleML. The causal forest estimates heterogeneous treatment
effects directly via honest forest estimation (EconML).

## Usage
```
/recast-cf <project_path>
```

## Difference from `/recast`

| Stage | `/recast` (DML) | `/recast-cf` (Causal Forest) |
|-------|-----------------|------------------------------|
| 1–3 | Same | Same |
| 4 | `04_dml_extension.ipynb` + `stage_04.md` | `04_causal_forest.ipynb` + `stage_04_cf.md` |
| 5–6 | Same | Same (stages detect which results exist) |
| Review | Same | Same |

## What you do

1. **Validate** the project folder has `.dml_project` marker and `config.yaml`.
   If not, tell the user to run `/init <project_path>` first.

2. **Read** `config.yaml` and `skills/orchestrator.md` before doing anything else.

3. **Run stages 1–3 sequentially** (paper intelligence, data, replication):
   ```
   For N in 1, 2, 3:
     spawn notebook_runner → code_build/0N_*.ipynb with skills/stage_0N.md
   ```
   Stop immediately if a stage fails.

4. **Run stage 4 — Causal Forest** (this is the key difference):
   ```
   spawn notebook_runner → code_build/04_causal_forest.ipynb with skills/stage_04_cf.md
   ```
   This notebook writes `causal_forest_results.json` as the primary extension output.
   It does NOT produce `dml_results.json`.

5. **Run stages 5–6** (diagnostics, report):
   ```
   For N in 5, 6:
     spawn notebook_runner → code_build/0N_*.ipynb with skills/stage_0N.md
   ```
   Stage 5 skips DML-specific checks (2–4) when `dml_results.json` is absent.
   Stage 6 uses the causal forest as the main extension method.

6. **Advisor Gate** — spawn three independent sub-agents in sequence:
   ```
   spawn advisor_gate → check 1, 2, 3 for project at <project_path>
   ```
   All three must return PASS.

7. **Review loop** — execute per `review.md` and `skills/review_loop.md`.
   Max rounds from `config.yaml > review > max_rounds` (default 3).
   Each round has THREE sub-steps that MUST each be **separate agent calls**:
   a. **Referees** (3 separate calls) → write ref1.md, ref2.md, ref3.md
   b. **Synthesis** (1 call) → write synthesis.md
   c. **Revision** (1 call, using `skills/revision_agent.md`) → **EDIT paper.tex**, write changelog_N.md
   The revision agent MUST edit paper.tex. If changelog says "no edits applied"
   but synthesis listed Major/Minor issues, the revision failed — re-run it.

8. **Final report** — run `/final <project_path>` logic (see final.md).

9. Print a summary: stages completed, rounds of review, final verdict, paths to outputs.

## Key rules
- Read the relevant skill file at the start of each sub-agent call
- Stage 4 MUST use `04_causal_forest.ipynb` and `skills/stage_04_cf.md` — not the DML notebook
- Never skip the Advisor Gate
- Always run the Final Referee even if the review loop exits cleanly
- `code_run/` receives executed notebook output — never edit it directly
- `data/paper_spec.json` is read-only after stage 1
