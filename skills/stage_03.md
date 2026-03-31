# Skill: Stage 03 — Replication

## Your job
Reproduce the paper's main OLS/IV regressions coefficient by coefficient.
Flag any discrepancies and produce a structured JSON + LaTeX table.

## Files you read
- `data/dataset.parquet`
- `data/paper_spec.json` — specification details and target coefficients

## Files you write
- `data/results/replication_results.json` — full regression output
- `data/results/replication_check.json` — pass/fail match summary
- `paper/tables/table_replication.tex` — LaTeX regression table

## What the notebook must do

### 1. Load data and spec
```python
import pandas as pd, json
df = pd.read_parquet("../data/dataset.parquet")
spec = json.load(open("../data/paper_spec.json"))
```

### 2. Run replications
For each entry in `spec["main_results"]`:
- Run the appropriate estimator:
  - `type == "OLS"` → `statsmodels.OLS`
  - `type == "IV"` → `linearmodels.IV2SLS`
- Match controls, fixed effects, and SE type exactly
- For spatial/Conley SE: use `spreg` or equivalent

### 3. Compare to published results
For each spec:
```json
{
  "spec": "Table 1 col 1",
  "published_coef": -0.123,
  "replicated_coef": -0.121,
  "abs_diff": 0.002,
  "rel_diff_pct": 1.6,
  "published_se": 0.045,
  "replicated_se": 0.044,
  "match": true,
  "threshold_pct": 5.0
}
```
`match = true` if `rel_diff_pct < 5.0` for the key coefficient.

### 4. Write outputs
**`replication_results.json`**:
```json
{
  "specs": [...],
  "overall_pass": true,
  "n_specs": 3,
  "n_pass": 3
}
```

**`replication_check.json`**:
```json
{
  "pass": true,
  "summary": "3/3 specs replicated within 5%",
  "worst_rel_diff_pct": 1.6
}
```

**`table_replication.tex`**: Standard regression table with both published
and replicated coefficients side by side. Use `\begin{tabular}` format.

## Rules
- Never round intermediate results — store full precision in JSON
- If replication fails (>5% diff), still write all outputs but set `pass: false`
  with a `"failure_notes"` field explaining the discrepancy
- Spatial SE: use Conley (1999) if the paper uses spatial correction
- Fixed effects: use `within` transformation or dummy variables, matching paper
