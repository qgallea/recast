# Skill: Stage 01 — Paper Intelligence

## Your job
Read the paper PDF and replication data, then write a structured `paper_spec.json`
that all downstream stages use. This is the only stage that reads human-written
source material; everything after relies on your output.

## Files you read (in priority order)
1. **Replication code** — `raw_data/*.R`, `raw_data/*.do`, `raw_data/*.py`, `raw_data/*.ipynb`,
   or any code files in the replication package. **These are the ground truth for variable
   names, functional form, data subsetting, and control sets.** Read them FIRST.
2. `raw_data/paper.pdf` — the published paper
3. `raw_data/*.dta` or `raw_data/*.csv` — to verify variable names exist in the data
4. `config.yaml` — for author/title/year hints

## Files you write
- `data/paper_spec.json` — **READ-ONLY for all subsequent stages**

## What to extract and write

### `paper_spec.json` schema
```json
{
  "title": "Full paper title",
  "authors": ["Last, F.", "Last, F."],
  "year": 2013,
  "journal": "American Economic Review",
  "slug": "ashrafgalor2013",

  "identification": {
    "type": "IV",
    "narrative": "One paragraph describing the causal claim and strategy",
    "outcome_variable": "exact_column_name",
    "outcome_label": "Human-readable label",
    "treatment_variable": "exact_column_name",
    "treatment_label": "Human-readable label",
    "instrument": "exact_column_name",
    "instrument_label": "Human-readable label",
    "functional_form": "quadratic",
    "controls": ["var1", "var2"],
    "fixed_effects": ["continent"],
    "cluster_se": "country_code",
    "primary_data_file": "country.dta",
    "secondary_datasets": ["ethnic.dta", "ethnicpair.dta"]
  },

  "main_results": [
    {
      "table": "Table 1",
      "spec": "OLS baseline",
      "coef": 0.0,
      "se": 0.0,
      "ci_lo": 0.0,
      "ci_hi": 0.0,
      "n_obs": 0,
      "notes": "Spatial Conley SE"
    }
  ],

  "dml": {
    "model_type": "PLIV",
    "rationale": "Why PLIV/PLR/IRM — one sentence"
  }
}
```

## Rules

### Variable extraction priority (CRITICAL)
1. **If replication code exists in `raw_data/`, extract variable names from the code.**
   The code is the authoritative source — it defines exactly which variables enter
   each regression, what transformations are applied (log, squared, interactions),
   and how observations are subsetted. Do NOT guess variable names from data column
   headers alone. Common pitfalls this prevents:
   - Data has both `payments2004` and `lnpayments2004` — the code specifies which one
   - Data has variables (`legalform`, `avinformal3`) that are in the data but NOT
     used in the analysis — include only what the code actually uses
   - The code may construct derived variables (interactions, dummies) not in the raw data

2. **After extracting from code, verify each variable exists in the data.**
   Load the `.dta` or `.csv` and check that every control, outcome, treatment, and
   instrument name from the code is a valid column. If a variable from the code
   does not exist, check for common transformations: `ln_`, `log_`, `_sq`, `d_`,
   `l.`, `D.` and map accordingly.

3. **If no replication code is available**, then (and only then) inspect column names
   in the data and cross-reference with the paper's variable descriptions.

### Other rules
- If a variable name in `config.yaml` doesn't match the data or code, use the correct
  name from the code/data and add a `"config_mismatch"` note in the JSON.
- Extract at least 3 main result rows (the key coefficients authors highlight).
- If the PDF is scanned or unreadable, fill what you can and mark missing fields
  with `null` plus a comment field `"_note": "could not extract from PDF"`.
- Write the file atomically — write to `data/paper_spec.json.tmp` then rename.
