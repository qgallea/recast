# /recast — RECAST a Paper

Launch the complete RECAST pipeline for a paper project folder:
replicate, extend with DoubleML, and publish a referee-reviewed report.

## Usage
```
/recast <project_path>
```

## What you do

1. **Validate** the project folder has `.dml_project` marker and `config.yaml`.
   If not, tell the user to run `/init <project_path>` first.

2. **Read** `config.yaml` and `skills/orchestrator.md` before doing anything else.

3. **Run stages 1–6 sequentially** by spawning a sub-agent for each notebook:
   ```
   claude -p "$(cat skills/notebook_runner.md)" \
     "Execute code_build/0N_*.ipynb for project at <project_path>. \
      Read skills/stage_0N.md first."
   ```
   Stop immediately if a stage fails. Report which cell failed and the error.

4. **Advisor Gate** — spawn three independent sub-agents in sequence:
   ```
   claude -p "$(cat skills/advisor_gate.md)" \
     "Run check <1|2|3> for project at <project_path>"
   ```
   All three must return PASS. If any fails, stop and report which check failed.

5. **Review loop** — execute per `review.md` and `skills/review_loop.md`.
   Max rounds from `config.yaml > review > max_rounds` (default 3).
   Each round has THREE sub-steps that MUST each be **separate agent calls**:
   a. **Referees** (3 separate calls) → write ref1.md, ref2.md, ref3.md
   b. **Synthesis** (1 call) → write synthesis.md
   c. **Revision** (1 call, using `skills/revision_agent.md`) → **EDIT paper.tex**, write changelog_N.md
   The revision agent MUST edit paper.tex. If changelog says "no edits applied"
   but synthesis listed Major/Minor issues, the revision failed — re-run it.

6. **Final report** — run `/final <project_path>` logic (see final.md).

7. Print a summary: stages completed, rounds of review, final verdict, paths to outputs.

## Key rules
- Read the relevant skill file at the start of each sub-agent call
- Never skip the Advisor Gate
- Always run the Final Referee even if the review loop exits cleanly
- `code_run/` receives executed notebook output — never edit it directly
- `data/paper_spec.json` is read-only after stage 1
