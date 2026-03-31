# /final — Run the Final Referee

Produce the human-readable final report from the full review history.

## Usage
```
/final <project_path>
```

## What you do

1. Read `skills/final_referee.md`.

2. Spawn a Final Referee sub-agent with the full review history:
   ```
   claude -p "$(cat skills/final_referee.md)" \
     "Write the final report for project at <project_path>. \
      Read the entire paper/review_history/ tree: all round_N/ folders, \
      all ref*.md, all synthesis.md, all changelog_N.md files. \
      Also read data/paper_spec.json, data/results/dml_results.json, \
      data/results/replication_results.json."
   ```

3. Save the output to `paper/review_history/final_report.md`.

4. Print the report to the terminal.

5. Print a final summary box:
```
╔══════════════════════════════════════════╗
║  Pipeline complete                       ║
║  Paper  : paper/paper.pdf                ║
║  Report : paper/review_history/          ║
║           final_report.md                ║
║  Forest : paper/figures/forest_plot.pdf  ║
╚══════════════════════════════════════════╝
```
