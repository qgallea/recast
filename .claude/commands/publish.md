# /publish — Publish a Paper to the Website

Scaffold a website page for a completed pipeline project and populate it
from the pipeline's JSON outputs and review history.

## Usage
```
/publish <project_path>
```

Example:
```
/publish ~/papers/acemoglu2001
```

## What you do

1. Read `skills/publish_paper.md`.

2. Validate that:
   - `<project_path>/.dml_project` exists
   - `<project_path>/paper/review_history/final_report.md` exists
     (if not, tell the user to run `/final <project_path>` first)
   - `<project_path>/paper/figures/forest_plot.png` exists

3. Spawn a publish sub-agent:
   ```
   claude -p "$(cat skills/publish_paper.md)" \
     "Publish the paper at <project_path> to the website. \
      The website root is <framework_root>/website/."
   ```
   where `<framework_root>` is the directory containing `skills/`.

4. Print a summary box on completion:
   ```
   ╔══════════════════════════════════════════════════════════════╗
   ║  Published                                                   ║
   ║  Page   : website/papers/<slug>/index.qmd                   ║
   ║  Reports: website/papers/<slug>/reports/ (5 files)          ║
   ║  Image  : website/papers/<slug>/forest_plot.png             ║
   ║                                                              ║
   ║  Push to main to deploy → GitHub Pages rebuilds             ║
   ╚══════════════════════════════════════════════════════════════╝
   ```

## Key rules
- Never overwrite an existing `website/papers/<slug>/` unless the user
  explicitly confirms with `--force`
- The slug is derived from the paper: lowercase first author surname + year
  (e.g. "acemoglu2001"). Confirm with the user before creating if ambiguous.
- Do not copy `paper.pdf` — it may be large; remind the user to add it manually
  if they want a download link on the page
