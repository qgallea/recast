# /stage — Re-run From a Specific Notebook

Re-execute a notebook and all downstream notebooks, then re-enter the review loop.

## Usage
```
/stage <N> <project_path>
```

Examples:
```
/stage 4 ~/papers/acemoglu2001   ← re-run DML + diagnostics + report + review
/stage 2 ~/papers/acemoglu2001   ← re-run from data cleaning onwards
```

## What you do

1. Read `skills/notebook_runner.md`.

2. For each stage from N to 6, spawn a sub-agent:
   ```
   claude -p "$(cat skills/notebook_runner.md)" \
     "Execute notebook <stage> for project at <project_path>. \
      Read skills/stage_0<N>.md first."
   ```
   Stop if any stage fails.

3. After stage 6 completes successfully, run the Advisor Gate
   (same as in `/recast`).

4. If gate passes, run `/review <project_path>`.

## Stale marker
When you re-run stage N, add a comment to the top of each downstream
executed notebook in `code_run/` marking it as stale, so it's clear
that the output predates the current analysis.
