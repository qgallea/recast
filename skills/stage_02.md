# Skill: Stage 02 — Data Preparation

## Your job
Load the raw replication data, merge datasets if needed, construct all variables
required by the replication and DML stages, and write a single clean parquet file.

## Files you read
- `data/paper_spec.json` — variable names, primary/secondary datasets, controls
- `raw_data/<primary_data_file>` — main analysis dataset
- `raw_data/<secondary_datasets>` — if listed in paper_spec.json

## Files you write
- `data/dataset.parquet` — clean, merged, analysis-ready dataset

## What the notebook must do

### 1. Load primary dataset
```python
import pyreadstat, pandas as pd
df, meta = pyreadstat.read_dta("raw_data/<primary_data_file>")
```
Print shape and first 5 rows. Print all column names with their Stata labels.

### 2. Merge secondary datasets (if any)
Join on the appropriate key (country code, ethnic group ID, etc.).
Document the merge key and any rows lost.

### 3. Construct variables
- Log-transform outcome if `paper_spec.json` outcome is in levels
- Create squared term if `functional_form == "quadratic"`
- Create any interaction terms mentioned in the paper
- Create continent dummies if `fixed_effects` includes `"continent"`

### 4. Validate
- Print missingness summary for all key variables
- Assert outcome, treatment, instrument have > 50 non-missing obs
- Print descriptive statistics table

### 5. Write output
```python
df.to_parquet("../data/dataset.parquet", index=False)
```

## Rules
- Never drop observations silently — log every row removed and why
- All constructed variables must be documented with a comment in the cell
- The parquet file must contain ALL original columns plus constructed ones
- Column names must exactly match what `paper_spec.json` specifies
