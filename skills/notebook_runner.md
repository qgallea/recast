# Skill: Notebook Runner

You execute a single analysis notebook and report the result.

## Your job
1. Read the stage-specific skill file listed below before executing
2. Run the notebook via `jupyter nbconvert --execute`
3. Check for errors in the output
4. Report completion or failure with specific cell info

## Stage skill files to read first
| Stage | Notebook | Skill to read |
|-------|----------|---------------|
| 1 | 01_paper_intelligence.ipynb | skills/stage_01.md |
| 2 | 02_data.ipynb               | skills/stage_02.md |
| 3 | 03_replication.ipynb        | skills/stage_03.md |
| 4 | 04_dml_extension.ipynb      | skills/stage_04.md |
| 4cf | 04_causal_forest.ipynb    | skills/stage_04_cf.md |
| 5 | 05_diagnostics.ipynb        | skills/stage_05.md |
| 6 | 06_report.ipynb             | skills/stage_06.md |

**Note:** Stage `4cf` is used by `/recast-cf` instead of stage `4`.
The two are mutually exclusive — a project runs one or the other.

## Execution command
```bash
cd <project>/code_build && \
jupyter nbconvert \
  --to notebook \
  --execute \
  --inplace \
  --ExecutePreprocessor.timeout=1800 \
  --ExecutePreprocessor.kernel_name=python3 \
  --output-dir <project>/code_run/ \
  <notebook_name>.ipynb
```

## After execution
- Open the executed notebook in `code_run/` and check for error cells
- If clean: print `✓ Stage N complete` and list outputs written
- If error: print the cell source + error traceback, and stop

## What to print on success
```
✓ Stage N: <notebook_name>
  Outputs:
    data/paper_spec.json                   (stage 1)
    data/dataset.parquet                   (stage 2)
    data/results/replication_check.json    (stage 3)
    data/results/dml_results.json          (stage 4)
    data/results/causal_forest_results.json (stage 4cf)
    paper/figures/forest_plot.pdf          (stage 4 or 4cf)
    data/results/diagnostics_flags.json    (stage 5)
    paper/paper.tex + paper.pdf            (stage 6)
```
