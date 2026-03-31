# Skill: Stage 04-CF — Causal Forest Extension

## References (read before writing the notebook)
- `skills/references/econml/causal_forest_dml.md` — CausalForestDML: DML + causal forest second stage
- `skills/references/econml/causal_forest.md`     — CausalForest: direct forest estimation (no DML)
- `skills/references/econml/causal_iv_forest.md`  — CausalIVForest: forest-based IV estimation

## Your job
Estimate the causal effect and heterogeneous treatment effects using a
**Causal Forest** (EconML). This stage replaces the DoubleML extension —
it does NOT run DoubleML. The causal forest provides:
- An ATE estimate with honest inference
- Individual-level CATE estimates with confidence intervals
- Feature importances identifying heterogeneity drivers

## Files you read
- `data/dataset.parquet`
- `data/paper_spec.json` — identification type, variables, functional form
- `data/results/replication_results.json` — published coefficients to compare against
- `config.yaml` — causal forest hyperparameters

## Files you write
- `data/results/causal_forest_results.json` — ATE, CATE summary, feature importances
- `data/results/hte_results.json` — group-level heterogeneity (GATE-equivalent from CF)
- `paper/tables/table_cf.tex` — comparison table: OLS/IV vs Causal Forest
- `paper/tables/table_gate.tex` — group-level treatment effects
- `paper/figures/forest_plot.pdf` — coefficient comparison (published vs CF ATE)
- `paper/figures/cate_histogram.pdf` — distribution of individual CATEs
- `paper/figures/feature_importance.pdf` — heterogeneity drivers
- `paper/figures/gate_plot.pdf` — group-level treatment effects plot

## Files you do NOT write
- `data/results/dml_results.json` — this is a CF-only pipeline; no DML

## Method selection from `paper_spec.json`

| `identification.type` | `config.causal_forest.method` | Class to use |
|----------------------|-------------------------------|-------------|
| `OLS` or `DID` | `CausalForestDML` (default) | `econml.dml.CausalForestDML` |
| `OLS` or `DID` | `CausalForest` | `econml.grf.CausalForest` |
| `IV` | `CausalIVForest` (default for IV) | `econml.grf.CausalIVForest` |
| `IV` | `CausalForestDML` | `econml.dml.CausalForestDML` (no IV 1st stage) |

## What the notebook must do

### 1. Setup
```python
import numpy as np, pandas as pd, json, yaml, matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from pathlib import Path
from paths import *
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.linear_model import LassoCV

df   = pd.read_parquet(str(DATASET_PATH))
spec = json.loads(PAPER_SPEC.read_text())
rep  = json.loads(REPLICATION_RESULTS.read_text())
config = yaml.safe_load((PROJECT_ROOT / "config.yaml").read_text())

outcome    = spec['identification']['outcome_variable']
treatment  = spec['identification']['treatment_variable']
instrument = spec['identification'].get('instrument')
controls   = spec['identification']['controls']
id_type    = spec['identification']['type']

cf_config = config.get('causal_forest', {})
```

### 2. Prepare data
```python
key_cols = [outcome, treatment] + controls + ([instrument] if instrument else [])
df_clean = df[key_cols].dropna().reset_index(drop=True)

X_cf = df_clean[controls].values
Y_cf = df_clean[outcome].values
T_cf = df_clean[treatment].values
if instrument:
    Z_cf = df_clean[instrument].values
```

### 3a. CausalForestDML (default for OLS/DID, optional for IV)
```python
from econml.dml import CausalForestDML

cf_dml = CausalForestDML(
    model_y=RandomForestRegressor(n_estimators=200, max_depth=5, random_state=42),
    model_t=RandomForestRegressor(n_estimators=200, max_depth=5, random_state=42),
    n_estimators=cf_config.get("n_estimators", 1000),
    min_samples_leaf=cf_config.get("min_samples_leaf", 5),
    max_depth=cf_config.get("max_depth", None),
    honest=True,
    inference=True,
    criterion=cf_config.get("criterion", "mse"),
    cv=cf_config.get("cv", 5),
    random_state=42,
)
cf_dml.fit(Y_cf, T_cf, X=X_cf, W=X_cf)

ate_inf = cf_dml.ate_inference(X=X_cf)
cf_ate = float(ate_inf.point_estimate)
cf_ate_se = float(ate_inf.stderr)
cf_ate_ci = ate_inf.conf_int(alpha=0.05)

cate_pred = cf_dml.effect(X_cf)
cate_inf = cf_dml.effect_inference(X_cf)
cate_ci = cate_inf.conf_int(alpha=0.05)

feat_imp = cf_dml.feature_importances_
```

### 3b. CausalIVForest (default for IV)
```python
from econml.grf import CausalIVForest

cf_iv = CausalIVForest(
    n_estimators=cf_config.get("n_estimators", 1000),
    min_samples_leaf=cf_config.get("min_samples_leaf", 5),
    max_depth=cf_config.get("max_depth", None),
    honest=True,
    inference=True,
    criterion=cf_config.get("criterion", "mse"),
    random_state=42,
)
cf_iv.fit(X_cf, T_cf, Y_cf, Z=Z_cf)

cate_pred = cf_iv.predict(X_cf)
cate_ci_bounds = cf_iv.predict_interval(X_cf, alpha=0.05)

cf_ate = float(np.mean(cate_pred))

# ATE CI from honest forest prediction intervals (NOT naive std/sqrt(n))
cf_ate_ci_lo = float(np.mean(cate_ci_bounds[0]))
cf_ate_ci_hi = float(np.mean(cate_ci_bounds[1]))
cf_ate_se = (cf_ate_ci_hi - cf_ate_ci_lo) / (2 * 1.96)  # back out SE from CI

feat_imp = cf_iv.feature_importances(max_depth=4)
```

**WARNING:** Do NOT use `np.std(cate_pred) / np.sqrt(n)` for the ATE SE — this
treats individual CATEs as known values and produces implausibly narrow CIs.
Always derive the ATE CI from `predict_interval()` bounds.

### 3c. CausalForest (no DML, no IV)
```python
from econml.grf import CausalForest

cf = CausalForest(
    n_estimators=cf_config.get("n_estimators", 1000),
    min_samples_leaf=cf_config.get("min_samples_leaf", 5),
    max_depth=cf_config.get("max_depth", None),
    honest=True,
    inference=True,
    criterion=cf_config.get("criterion", "mse"),
    random_state=42,
)
cf.fit(X_cf, T_cf, Y_cf)

cate_pred = cf.predict(X_cf)
cate_ci_bounds = cf.predict_interval(X_cf, alpha=0.05)

cf_ate = float(np.mean(cate_pred))
cf_ate_ci_lo = float(np.mean(cate_ci_bounds[0]))
cf_ate_ci_hi = float(np.mean(cate_ci_bounds[1]))
cf_ate_se = (cf_ate_ci_hi - cf_ate_ci_lo) / (2 * 1.96)

feat_imp = cf.feature_importances(max_depth=4)
```

### 4. Write `causal_forest_results.json`
```json
{
  "method": "CausalIVForest",
  "n_obs": 12000,
  "n_estimators": 1000,
  "honest": true,
  "ate": -0.128,
  "ate_se": 0.039,
  "ate_ci_lo": -0.204,
  "ate_ci_hi": -0.052,
  "cate_summary": {
    "mean": -0.128,
    "sd": 0.065,
    "min": -0.31,
    "max": 0.02,
    "pct_negative": 0.94,
    "pct_significant": 0.72
  },
  "feature_importances": {
    "control1": 0.42,
    "control2": 0.18,
    "control3": 0.15
  },
  "sign_change_vs_published": false
}
```

### 5. Group-level heterogeneity (GATE-equivalent) — 5 quintiles

Compute group average treatment effects by **quintiles of predicted CATE**
(not an arbitrary control variable), using the individual CATE predictions
from the forest. This follows B&N's approach.

```python
# Group by predicted CATE quintiles
quintiles = pd.qcut(cate_pred, q=5, labels=["Q1 (low)", "Q2", "Q3", "Q4", "Q5 (high)"])

groups = []
for label in ["Q1 (low)", "Q2", "Q3", "Q4", "Q5 (high)"]:
    mask = (quintiles == label)
    group_cates = cate_pred[mask]
    group_ci_lo = cate_ci_bounds[0][mask] if isinstance(cate_ci_bounds, tuple) else cate_ci[mask, 0]
    group_ci_hi = cate_ci_bounds[1][mask] if isinstance(cate_ci_bounds, tuple) else cate_ci[mask, 1]
    groups.append({
        "label": label,
        "coef": float(np.mean(group_cates)),
        "ci_lo": float(np.mean(group_ci_lo)),
        "ci_hi": float(np.mean(group_ci_hi))
    })

heterogeneity_detected = any(
    g1["ci_hi"] < g2["ci_lo"] or g2["ci_hi"] < g1["ci_lo"]
    for i, g1 in enumerate(groups) for g2 in groups[i+1:]
)
```

### 5b. Above/below-median ATE comparison (B&N approach)

```python
median_cate = np.median(cate_pred)
above_median = cate_pred >= median_cate
ate_above = float(np.mean(cate_pred[above_median]))
ate_below = float(np.mean(cate_pred[~above_median]))
# Report in causal_forest_results.json as ate_above_median, ate_below_median
```

### 5c. Calibration test

```python
# Regress actual outcome residuals on predicted CATEs × treatment residuals
# Slope ≈ 1 means forest is well-calibrated
import statsmodels.api as sm
calib = sm.OLS(Y_res, sm.add_constant(cate_pred * T_res)).fit()
calibration_slope = float(calib.params[1])
calibration_pval = float(calib.pvalues[1])
# Report in causal_forest_results.json as calibration: {slope, pval, well_calibrated}
```

### 5d. CLAN (Classification Analysis)

Compare control variable means between top and bottom quintiles of predicted CATE:

```python
top_q = cate_pred >= np.percentile(cate_pred, 80)
bot_q = cate_pred <= np.percentile(cate_pred, 20)

clan_results = []
for var in controls:
    mean_top = df_clean.loc[top_q, var].mean()
    mean_bot = df_clean.loc[bot_q, var].mean()
    from scipy.stats import ttest_ind
    _, p_val = ttest_ind(df_clean.loc[top_q, var].dropna(), df_clean.loc[bot_q, var].dropna(), equal_var=False)
    clan_results.append({"variable": var, "mean_most_affected": float(mean_top),
                          "mean_least_affected": float(mean_bot),
                          "difference": float(mean_top - mean_bot), "pval": float(p_val)})
```

Write `hte_results.json`:
```json
{
  "method": "CausalForest-GATE",
  "grouping_variable": "predicted_CATE_quintile",
  "n_groups": 5,
  "groups": [
    {"label": "Q1 (low)", "coef": -0.21, "ci_lo": -0.38, "ci_hi": -0.04},
    {"label": "Q2",       "coef": -0.17, "ci_lo": -0.31, "ci_hi": -0.03},
    {"label": "Q3",       "coef": -0.13, "ci_lo": -0.25, "ci_hi": -0.01},
    {"label": "Q4",       "coef": -0.09, "ci_lo": -0.20, "ci_hi":  0.02},
    {"label": "Q5 (high)","coef": -0.05, "ci_lo": -0.17, "ci_hi":  0.07}
  ],
  "clan": [
    {"variable": "control1", "mean_most_affected": 15.2, "mean_least_affected": 8.1, "difference": 7.1, "pval": 0.03}
  ],
  "cate_summary": {"mean": -0.13, "sd": 0.06, "min": -0.25, "max": -0.04},
  "heterogeneity_detected": true
}
```

### 6. Forest plot
Coefficient comparison figure:
- Y-axis: "Published OLS", "Published IV" (if applicable), "Replicated", "Causal Forest ATE"
- X-axis: coefficient estimate with 95% CI bars
- Vertical dashed line at 0
- Colour: grey for OLS/IV, green for Causal Forest
- Save as `paper/figures/forest_plot.pdf` AND `.png`

### 7. CATE histogram
- Histogram of individual-level CATE estimates with kernel density overlay
- Vertical dashed line at 0 and at ATE
- Title: "Distribution of Conditional Average Treatment Effects"
- Save as `paper/figures/cate_histogram.pdf` and `.png`

### 8. Feature importance plot
- Horizontal bar chart, sorted descending
- Y-axis: variable names
- X-axis: importance score
- Title: "Causal Forest: Heterogeneity Drivers"
- Save as `paper/figures/feature_importance.pdf` and `.png`

### 9. GATE plot
- Horizontal coefficient plot, groups on y-axis, group-mean CATE ± CI on x-axis
- Dashed line at 0
- Save as `paper/figures/gate_plot.pdf` and `.png`

### 10. LaTeX comparison table
Side-by-side: published OLS, published IV (if applicable), replicated, Causal Forest ATE.
Rows: coefficient, SE, 95% CI, N.
Save as `paper/tables/table_cf.tex`.

### 11. GATE LaTeX table
Save as `paper/tables/table_gate.tex`.

## SE sanity check (MANDATORY)

After computing the ATE SE and CI, run this validation:

```python
# Sanity check: ATE CI width must be comparable to individual CATE CI widths
ate_ci_width = cf_ate_ci_hi - cf_ate_ci_lo
mean_cate_ci_width = float(np.mean(cate_ci_hi - cate_ci_lo))

ratio = mean_cate_ci_width / ate_ci_width if ate_ci_width > 0 else float('inf')
print(f'ATE CI width: {ate_ci_width:.4f}')
print(f'Mean CATE CI width: {mean_cate_ci_width:.4f}')
print(f'Ratio (CATE/ATE): {ratio:.1f}x')

if ratio > 10:
    raise ValueError(
        f'ATE CI is {ratio:.0f}x narrower than individual CATE CIs. '
        f'This indicates the ATE SE was computed incorrectly '
        f'(likely using std/sqrt(n) instead of predict_interval). '
        f'ATE CI width={ate_ci_width:.4f}, mean CATE CI width={mean_cate_ci_width:.4f}'
    )
```

The ATE aggregates individual CATEs, so its CI should be **comparable in width**
to individual CATE CIs (narrower due to averaging, but not by orders of magnitude).
If the ratio exceeds 10x, the SE is almost certainly wrong.

## Rules
- Always use `honest=True` for valid inference
- Always use `inference=True` for CIs
- Report the ATE and its SE — not just the mean of CATEs
- If CF ATE has opposite sign to published, flag with `"sign_change_vs_published": true`
- Feature importances must sum to ~1.0 (normalize if needed)
- For CausalIVForest: verify the instrument is binary or low-dimensional
- Do NOT write `dml_results.json` — this is a CF-only pipeline
