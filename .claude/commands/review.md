# /review — Run the Review Loop

Run the referee review loop on the current state of `paper/paper.tex`.
Use this when the analysis notebooks have already been executed.

## Usage
```
/review <project_path>
```

## What you do

1. Read `skills/orchestrator.md` and `skills/review_loop.md`.

2. Determine current round number N by counting subdirectories in
   `<project_path>/paper/review_history/round_*/`.

3. **For each round (N = current+1 up to max_rounds):**

   a. Create `paper/review_history/round_N/`

   b. Spawn **three referee sub-agents in sequence** (isolated — no shared context):
      ```
      claude -p "$(cat skills/referee_1_identification.md)" \
        "Review the paper at <project_path>. \
         Read: paper/paper.tex, data/paper_spec.json, \
         data/results/replication_check.json, data/results/diagnostics_flags.json"
      ```
      Repeat for referee_2_dml_methods.md and referee_3_robustness.md.
      Save outputs to `round_N/ref1.md`, `ref2.md`, `ref3.md`.

   c. Spawn **Synthesis Referee**:
      ```
      claude -p "$(cat skills/synthesis_referee.md)" \
        "Synthesise the three referee reports in round_N/ for project <project_path>. \
         Also read all prior changelog_*.md files."
      ```
      Save output to `round_N/synthesis.md`.

   d. Spawn **Revision Agent** (MUST be a separate sub-agent call):
      ```
      claude -p "$(cat skills/revision_agent.md)" \
        "Implement the synthesis report for round N at <project_path>. \
         Read paper/review_history/round_N/synthesis.md and paper/paper.tex. \
         You MUST edit paper/paper.tex directly for all Major and Minor issues. \
         Write changelog_N.md documenting every edit with its location. \
         End with RERUN_NEEDED: yes or RERUN_NEEDED: no."
      ```
      Save changelog to `round_N/changelog_N.md`.
      **Verify:** If synthesis listed Major/Minor issues but changelog says
      "no edits applied", the revision failed — re-spawn the revision agent.

   e. If revision agent signals re-run needed:
      Run `/stage 4 <project_path>` (re-runs nb 4→6).

   f. **Exit loop if:** synthesis reports 0 blocking issues, or N == max_rounds.

4. After the loop exits, run `/final <project_path>`.

## Referee isolation rule
Each referee sub-agent call must have **only its own system prompt** plus the
artifact files it is allowed to read. Never pass one referee's output into
another referee's context.
