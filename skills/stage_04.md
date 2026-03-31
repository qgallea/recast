# Skill: Stage 04 — DoubleML Extension + Causal Forest

## References (read before writing the notebook)
- `skills/references/doubleml/basics.rst`        — DML framework, orthogonalization, regularization bias
- `skills/references/doubleml/model_plr.rst`     — PLR model equations
- `skills/references/doubleml/model_pliv.rst`    — PLIV model equations
- `skills/references/doubleml/model_irm.rst`     — IRM model equations (ATE/ATTE)
- `skills/references/doubleml/resampling.rst`    — cross-fitting parameters, K-fold and repeated cross-fitting
- `skills/references/doubleml/heterogeneity.rst` — GATE and CATE API (`.gate()`, `.cate()`, `.confint()`)
- `skills/references/econml/causal_forest_dml.md` — CausalForestDML: DML + causal forest second stage
- `skills/references/econml/causal_forest.md`     — CausalForest: direct forest estimation (no DML)
- `skills/references/econml/causal_iv_forest.md`  — CausalIVForest: forest-based IV estimation

## Your job
Estimate the causal effect using Double/Debiased Machine Learning and Causal
Forests. Replace the parametric first stage with cross-fitted ML models while
retaining the paper's causal identification argument. Then estimate
heterogeneous treatment effects using BLP, GATE, and CLAN.

This follows the methodology of Baiardi & Naghi (2024, Econometrics Journal),
which compares 7 ML methods, uses median aggregation across many sample splits,
and implements the full Chernozhukov et al. (2018) Generic ML framework.

## Files you read
- `data/dataset.parquet`
- `data/paper_spec.json` — identification type, variables, functional form
- `data/results/replication_results.json` — published coefficients to compare against
- `config.yaml` — ML methods, n_folds, n_rep, causal forest settings

## Files you write
- `data/results/dml_results.json` — DML estimates and diagnostics (all specs × all methods)
- `data/results/hte_results.json` — BLP, GATE, CATE, CLAN heterogeneous treatment effect estimates
- `data/results/causal_forest_results.json` — Causal forest ATE, CATE, and feature importances
- `paper/tables/table_dml.tex` — B&N-style comparison table: 7 methods + OLS
- `paper/tables/table_gate.tex` — GATE estimates by quintile
- `paper/tables/table_clan.tex` — CLAN classification analysis
- `paper/tables/table_cate.tex` — CATE summary from causal forest (if applicable)
- `paper/figures/forest_plot.pdf` — coefficient comparison plot (includes causal forest ATE)
- `paper/figures/gate_plot.pdf` — GATE estimates plot
- `paper/figures/cate_histogram.pdf` — distribution of individual-level CATE from causal forest
- `paper/figures/feature_importance.pdf` — causal forest heterogeneity drivers

## Model selection from `paper_spec.json`

| `identification.type` | DML model |
|----------------------|-----------|
| `OLS` | `DoubleMLPLR` (Partial Linear Regression) |
| `IV` | `DoubleMLPLIV` (Partial Linear IV) |
| `DID` | `DoubleMLIRM` (Interactive Regression Model) |

---

## What the notebook must do

### 1. Setup

```python
import doubleml as dml
import numpy as np, pandas as pd, json, yaml
from pathlib import Path
from sklearn.ensemble import (
    RandomForestRegressor, RandomForestClassifier,
    GradientBoostingRegressor, GradientBoostingClassifier
)
from sklearn.linear_model import LassoCV, ElasticNetCV
from sklearn.neural_network import MLPRegressor, MLPClassifier
from sklearn.tree import DecisionTreeRegressor, DecisionTreeClassifier
from sklearn.metrics import r2_score, mean_squared_error
from sklearn.preprocessing import PolynomialFeatures

# Causal forest imports (wrap in try/except — skip CF if unavailable)
try:
    from econml.dml import CausalForestDML
    from econml.grf import CausalForest, CausalIVForest
    ECONML_AVAILABLE = True
except ImportError:
    ECONML_AVAILABLE = False
```

### 2. Build the specification grid

Read `paper_spec.json` and `config.yaml`. Build the full set of outcome×treatment
specifications to estimate.

```python
spec = json.load(open("../data/paper_spec.json"))
config = yaml.safe_load(open("../config.yaml"))

# Primary specification
primary_outcome = spec["identification"]["outcome_variable"]
primary_treatment = spec["identification"]["treatment_variable"]
controls = spec["identification"]["controls"]

# Build specification grid: all outcome × treatment combinations
outcomes = [{"variable": primary_outcome, "label": spec["identification"].get("outcome_label", primary_outcome)}]
treatments = [{"variable": primary_treatment, "label": spec["identification"].get("treatment_label", primary_treatment)}]

# Add additional outcomes/treatments from paper_spec or config
for extra in spec["identification"].get("additional_outcomes", []):
    outcomes.append(extra)
for extra in spec["identification"].get("additional_treatments", []):
    treatments.append(extra)

specs = []
for o in outcomes:
    for t in treatments:
        specs.append({"outcome": o, "treatment": t, "controls": controls})
```

### 3. Adaptive cross-fitting parameters

**Critical rule:** Adjust K-folds based on sample size. B&N use K=2 for small
samples (N < 200). With K=5 on N=50, each fold has only 10 obs — too few
for ML learners to fit meaningful nuisance models.

```python
n_obs = len(df_clean)

# Adaptive K-folds (B&N use K=2 for their small-sample applications)
if config["dml"].get("n_folds") == "auto" or config["dml"].get("n_folds") is None:
    n_folds = 2 if n_obs < 200 else 5
else:
    n_folds = config["dml"]["n_folds"]

# Repetitions: default 20 (B&N use 100; 20 is a practical minimum)
n_rep = config["dml"].get("n_rep", 20)
```

### 4. Define 7 ML learners

Following Baiardi & Naghi (2024), use 7 diverse learners spanning linear,
tree-based, ensemble, and neural network approaches.

```python
def build_learners(n_obs, n_features, task="regression"):
    """Build learner dictionary. Hyperparameters adapt to sample size."""
    if task == "regression":
        learners = {
            "Lasso": LassoCV(cv=min(5, max(2, n_obs // 10))),
            "DecisionTree": DecisionTreeRegressor(
                ccp_alpha=0.01, max_depth=min(5, n_obs // 10)
            ),
            "Boosting": GradientBoostingRegressor(
                n_estimators=1000, learning_rate=0.01,
                max_depth=2, subsample=0.5,
                min_samples_leaf=max(1, n_obs // 20)
            ),
            "Forest": RandomForestRegressor(
                n_estimators=1000, min_samples_leaf=5,
                max_features="sqrt", n_jobs=-1
            ),
            "NeuralNet": MLPRegressor(
                hidden_layer_sizes=(100,), max_iter=1000,
                early_stopping=True, learning_rate_init=0.01
            ),
        }
    else:  # classification (for IRM propensity)
        learners = {
            "Lasso": LassoCV(cv=min(5, max(2, n_obs // 10))),
            "Forest": RandomForestClassifier(
                n_estimators=1000, min_samples_leaf=5, n_jobs=-1
            ),
        }
    return learners
```

**For linear methods (Lasso, ElasticNet):** auto-generate pairwise interaction
terms so they can capture nonlinearities that B&N highlight as a key DML advantage:
```python
poly = PolynomialFeatures(degree=2, interaction_only=True, include_bias=False)
X_interactions = poly.fit_transform(df_clean[controls])
# Use X_interactions for Lasso/ElasticNet; use raw X for tree-based methods
```

### 5. Run DML for each specification × each learner

For each specification in the grid, run DML with every learner independently.

```python
all_results = []

for spec_idx, s in enumerate(specs):
    y_col = s["outcome"]["variable"]
    d_col = s["treatment"]["variable"]

    # Listwise deletion for this specification
    cols_needed = [y_col, d_col] + controls
    df_spec = df_clean[cols_needed].dropna()
    n_spec = len(df_spec)

    # Adaptive K for this specific spec
    k_folds = 2 if n_spec < 200 else n_folds

    # Build DoubleML data object
    dml_data = dml.DoubleMLData(
        df_spec, y_col=y_col, d_cols=d_col,
        x_cols=controls
    )

    learner_results = {}
    learner_nuisance_mse = {}  # for Best/Ensemble selection

    for learner_name, ml_model in build_learners(n_spec, len(controls)).items():
        # Choose DML model class based on identification type
        if spec["identification"]["type"] == "IV":
            obj = dml.DoubleMLPLIV(dml_data, ml_l=ml_model, ml_m=ml_model,
                                    ml_r=ml_model, n_folds=k_folds, n_rep=n_rep)
        elif spec["identification"]["type"] == "DID":
            obj = dml.DoubleMLIRM(dml_data, ml_g=ml_model, ml_m=ml_model,
                                   n_folds=k_folds, n_rep=n_rep)
        else:  # OLS → PLR
            obj = dml.DoubleMLPLR(dml_data, ml_l=ml_model, ml_m=ml_model,
                                   n_folds=k_folds, n_rep=n_rep)

        obj.fit()

        # --- Extract per-rep estimates for median aggregation ---
        all_coefs = obj.all_coef.flatten()  # shape (n_rep,)
        all_ses = obj.all_se.flatten()      # shape (n_rep,)

        median_coef = float(np.median(all_coefs))
        # B&N adjusted SE: accounts for both within-split and across-split variation
        se_adj = float(np.median(np.sqrt(all_ses**2 + (all_coefs - median_coef)**2)))

        # --- Nuisance model quality (MSE and R²) ---
        preds_outcome = obj.predictions['ml_l'][:, 0, 0]
        preds_treatment = obj.predictions['ml_m'][:, 0, 0]
        r2_outcome = float(r2_score(df_spec[y_col], preds_outcome))
        r2_treatment = float(r2_score(df_spec[d_col], preds_treatment))
        mse_outcome = float(mean_squared_error(df_spec[y_col], preds_outcome))
        mse_treatment = float(mean_squared_error(df_spec[d_col], preds_treatment))

        learner_nuisance_mse[learner_name] = {
            "mse_outcome": mse_outcome,
            "mse_treatment": mse_treatment,
            "r2_outcome": r2_outcome,
            "r2_treatment": r2_treatment,
        }

        # --- Lasso coefficient diagnostics ---
        lasso_diag = None
        if learner_name == "Lasso":
            try:
                lasso_model_l = obj.models['ml_l']['ml_l'][0][0]
                coefs_l = pd.Series(lasso_model_l.coef_, index=controls)
                nonzero_l = coefs_l[coefs_l != 0].sort_values(key=abs, ascending=False)

                lasso_model_m = obj.models['ml_m']['ml_m'][0][0]
                coefs_m = pd.Series(lasso_model_m.coef_, index=controls)
                nonzero_m = coefs_m[coefs_m != 0].sort_values(key=abs, ascending=False)

                lasso_diag = {
                    "outcome_model": {
                        "n_nonzero": int(len(nonzero_l)),
                        "total_p": len(controls),
                        "top_variables": {k: round(v, 4) for k, v in nonzero_l.head(5).items()},
                    },
                    "treatment_model": {
                        "n_nonzero": int(len(nonzero_m)),
                        "total_p": len(controls),
                        "top_variables": {k: round(v, 4) for k, v in nonzero_m.head(5).items()},
                    },
                }
            except Exception:
                pass

        learner_results[learner_name] = {
            "coef": median_coef,
            "se": se_adj,
            "ci_lo": median_coef - 1.96 * se_adj,
            "ci_hi": median_coef + 1.96 * se_adj,
            "pval": float(2 * (1 - __import__('scipy').stats.norm.cdf(abs(median_coef / se_adj)))) if se_adj > 0 else 1.0,
            "per_rep_coefs": all_coefs.tolist(),
            "per_rep_ses": all_ses.tolist(),
            "nuisance": learner_nuisance_mse[learner_name],
            "lasso_diagnostics": lasso_diag,
        }

    # --- Ensemble: MSE-inverse-weighted combination ---
    # Following B&N: weight each method inversely by its nuisance MSE
    try:
        methods_for_ensemble = [k for k in learner_results if k not in ("Ensemble", "Best")]
        weights_outcome = {}
        for m in methods_for_ensemble:
            mse = learner_nuisance_mse[m]["mse_outcome"]
            weights_outcome[m] = 1.0 / max(mse, 1e-10)
        total_w = sum(weights_outcome.values())
        weights_outcome = {k: v / total_w for k, v in weights_outcome.items()}

        ensemble_coef = sum(weights_outcome[m] * learner_results[m]["coef"] for m in methods_for_ensemble)
        ensemble_se = sum(weights_outcome[m] * learner_results[m]["se"] for m in methods_for_ensemble)

        learner_results["Ensemble"] = {
            "coef": float(ensemble_coef),
            "se": float(ensemble_se),
            "ci_lo": float(ensemble_coef - 1.96 * ensemble_se),
            "ci_hi": float(ensemble_coef + 1.96 * ensemble_se),
            "pval": float(2 * (1 - __import__('scipy').stats.norm.cdf(abs(ensemble_coef / ensemble_se)))) if ensemble_se > 0 else 1.0,
            "weights": {k: round(v, 3) for k, v in weights_outcome.items()},
        }
    except Exception:
        pass

    # --- Best: method with lowest nuisance MSE ---
    # Following B&N: select best outcome-model method and best treatment-model method
    best_outcome_method = min(methods_for_ensemble, key=lambda m: learner_nuisance_mse[m]["mse_outcome"])
    best_treatment_method = min(methods_for_ensemble, key=lambda m: learner_nuisance_mse[m]["mse_treatment"])

    # Use the best-outcome method's estimate as the "Best" result
    learner_results["Best"] = {
        **learner_results[best_outcome_method],
        "best_outcome_method": best_outcome_method,
        "best_treatment_method": best_treatment_method,
        "selection_criterion": "lowest_nuisance_MSE",
    }

    # --- Determine sign change vs published ---
    published_coef = None
    for mr in spec.get("main_results", []):
        if mr.get("treatment") == d_col or mr.get("outcome") == y_col:
            published_coef = mr.get("coef")
            break

    sign_change = False
    if published_coef is not None and published_coef != 0:
        sign_change = (np.sign(learner_results["Best"]["coef"]) != np.sign(published_coef))

    all_results.append({
        "outcome": s["outcome"],
        "treatment": s["treatment"],
        "n_obs": n_spec,
        "n_folds": k_folds,
        "n_rep": n_rep,
        "learners": learner_results,
        "preferred_learner": "Best",
        "preferred_coef": learner_results["Best"]["coef"],
        "preferred_ci_lo": learner_results["Best"]["ci_lo"],
        "preferred_ci_hi": learner_results["Best"]["ci_hi"],
        "sign_change_vs_published": bool(sign_change),
    })
```

### 6. Write `dml_results.json`

```json
{
  "model_type": "PLR",
  "aggregation": "median_across_reps",
  "se_formula": "B&N adjusted: median(sqrt(SE_k^2 + (coef_k - median_coef)^2))",
  "specifications": [
    {
      "outcome": {"variable": "Investment2005", "label": "Investment/GDP"},
      "treatment": {"variable": "effective_5yr", "label": "5-yr effective rate"},
      "n_obs": 53,
      "n_folds": 2,
      "n_rep": 20,
      "learners": {
        "Lasso": {"coef": -0.178, "se": 0.096, "ci_lo": -0.366, "ci_hi": 0.010, "pval": 0.064, "nuisance": {"r2_outcome": 0.15, "r2_treatment": 0.12, "mse_outcome": 0.42, "mse_treatment": 0.38}, "lasso_diagnostics": {"outcome_model": {"n_nonzero": 5, "total_p": 12, "top_variables": {"other_taxes": 0.23}}, "treatment_model": {"n_nonzero": 3, "total_p": 12, "top_variables": {"propertyrights": -0.15}}}},
        "DecisionTree": {"coef": -0.15, "se": 0.11, "...": "..."},
        "Boosting": {"coef": -0.199, "se": 0.091, "...": "..."},
        "Forest": {"coef": -0.204, "se": 0.094, "...": "..."},
        "NeuralNet": {"coef": -0.218, "se": 0.101, "...": "..."},
        "Ensemble": {"coef": -0.193, "se": 0.089, "weights": {"Lasso": 0.25, "Forest": 0.35, "...": "..."}},
        "Best": {"coef": -0.204, "se": 0.094, "best_outcome_method": "Forest", "best_treatment_method": "Boosting", "selection_criterion": "lowest_nuisance_MSE"}
      },
      "preferred_learner": "Best",
      "preferred_coef": -0.204,
      "sign_change_vs_published": false
    }
  ]
}
```

### 7. Heterogeneous treatment effects: BLP + GATE + CLAN

Run this after fitting all learners. Use the **Best learner model object** for the
primary specification (first spec in the grid).

**Step 7a — BLP (Best Linear Predictor) — formal heterogeneity test**

Following Chernozhukov, Demirer, Duflo, Fernandez-Val (2018), the BLP tests
whether there is *any* systematic heterogeneity in the treatment effect.

```python
# S(X) = predicted CATE proxy. Use cross-fitted DML predictions:
# For PLR: S(X) ≈ residualized coefficient variation. Approximate with:
#   S_i = (Y_i - Y_hat_i) / (D_i - D_hat_i) for each observation
# Or use causal forest predictions if available.

# BLP regression:
# (Y - Y_hat) = β₁·(D - D_hat) + β₂·(D - D_hat)·(S(X) - mean(S(X))) + ε
# β₁ = ATE, β₂ = heterogeneity loading
# Test H₀: β₂ = 0 (no heterogeneity)

import statsmodels.api as sm

Y_res = df_spec[y_col].values - preds_outcome
D_res = df_spec[d_col].values - preds_treatment
S_centered = S_proxy - np.mean(S_proxy)

X_blp = np.column_stack([D_res, D_res * S_centered])
blp_model = sm.OLS(Y_res, X_blp).fit(cov_type='HC1')

blp_results = {
    "beta1_ate": float(blp_model.params[0]),
    "beta1_se": float(blp_model.bse[0]),
    "beta1_pval": float(blp_model.pvalues[0]),
    "beta2_het": float(blp_model.params[1]),
    "beta2_se": float(blp_model.bse[1]),
    "beta2_pval": float(blp_model.pvalues[1]),
    "heterogeneity_significant": bool(blp_model.pvalues[1] < 0.10),
}
```

**Step 7b — GATE (Group Average Treatment Effects) — 5 quintiles**

Use the predicted CATE proxy S(X) to define quintile groups, NOT an arbitrary
control variable. This follows B&N's approach of grouping by the ML-predicted
heterogeneity score.

```python
# Group by predicted CATE quintiles (not controls[0])
quintiles = pd.qcut(S_proxy, q=5, labels=["Q1 (low)", "Q2", "Q3", "Q4", "Q5 (high)"])
groups_df = pd.get_dummies(quintiles, prefix="group")

gate = obj_best.gate(groups=groups_df)
gate_ci = gate.confint(level=0.95, joint=True)  # jointly valid CIs
```

If causal forest is available, use its CATE predictions for S(X). Otherwise,
derive S(X) from the DML cross-fitted residuals.

**Step 7c — CLAN (Classification Analysis)**

For each control variable, compare means between most-affected (top quintile)
and least-affected (bottom quintile) groups. This reveals which observable
characteristics differentiate subpopulations with strong vs. weak treatment effects.

```python
top_q = S_proxy >= np.percentile(S_proxy, 80)  # top quintile
bot_q = S_proxy <= np.percentile(S_proxy, 20)  # bottom quintile

clan_results = []
for var in controls:
    mean_top = df_spec.loc[top_q, var].mean()
    mean_bot = df_spec.loc[bot_q, var].mean()
    diff = mean_top - mean_bot

    # t-test for difference
    from scipy.stats import ttest_ind
    t_stat, p_val = ttest_ind(
        df_spec.loc[top_q, var].dropna(),
        df_spec.loc[bot_q, var].dropna(),
        equal_var=False
    )

    clan_results.append({
        "variable": var,
        "mean_most_affected": float(mean_top),
        "mean_least_affected": float(mean_bot),
        "difference": float(diff),
        "pval": float(p_val),
        "significant_10pct": bool(p_val < 0.10),
    })
```

**Step 7d — Write `hte_results.json`**

```json
{
  "blp": {
    "beta1_ate": -0.13,
    "beta1_se": 0.04,
    "beta1_pval": 0.001,
    "beta2_het": 0.05,
    "beta2_se": 0.03,
    "beta2_pval": 0.08,
    "heterogeneity_significant": true
  },
  "gate": {
    "method": "GATE",
    "grouping_variable": "predicted_CATE_quintile",
    "n_groups": 5,
    "groups": [
      {"label": "Q1 (low)", "coef": -0.21, "ci_lo": -0.38, "ci_hi": -0.04},
      {"label": "Q2",       "coef": -0.17, "ci_lo": -0.31, "ci_hi": -0.03},
      {"label": "Q3",       "coef": -0.13, "ci_lo": -0.25, "ci_hi": -0.01},
      {"label": "Q4",       "coef": -0.09, "ci_lo": -0.20, "ci_hi":  0.02},
      {"label": "Q5 (high)","coef": -0.05, "ci_lo": -0.17, "ci_hi":  0.07}
    ],
    "heterogeneity_detected": true
  },
  "clan": [
    {"variable": "other_taxes", "mean_most_affected": 15.2, "mean_least_affected": 8.1, "difference": 7.1, "pval": 0.03, "significant_10pct": true},
    {"variable": "propertyrights", "mean_most_affected": 45.0, "mean_least_affected": 62.0, "difference": -17.0, "pval": 0.08, "significant_10pct": true}
  ],
  "cate_summary": {"mean": -0.13, "sd": 0.06, "min": -0.25, "max": -0.04}
}
```

`heterogeneity_detected = true` if **any two** GATE CIs do not overlap.
`cate_summary` is `null` for IRM models (CATE not computed).

**Step 7e — GATE plot**

Horizontal coefficient plot, quintile groups on y-axis, coefficient ± jointly valid CI on x-axis. Save as `paper/figures/gate_plot.pdf` and `.png`.

**Step 7f — GATE LaTeX table**

```latex
\begin{table}[h]
\centering
\caption{Group Average Treatment Effects (GATE)}
\begin{tabular}{lccc}
\toprule
Quintile & Coef. & 95\% CI (joint) \\
\midrule
Q1 (lowest predicted effect)  & -0.21 & [-0.38, -0.04] \\
Q2  & ... \\
Q3  & ... \\
Q4  & ... \\
Q5 (highest predicted effect) & -0.05 & [-0.17, 0.07] \\
\bottomrule
\end{tabular}
\end{table}
```

Save as `paper/tables/table_gate.tex`.

**Step 7g — CLAN LaTeX table**

```latex
\begin{table}[h]
\centering
\caption{Classification Analysis (CLAN): Characteristics of Most vs. Least Affected}
\begin{tabular}{lcccc}
\toprule
Variable & Most Affected & Least Affected & Difference & p-value \\
\midrule
other\_taxes & 15.2 & 8.1 & 7.1 & 0.03** \\
...
\bottomrule
\end{tabular}
\end{table}
```

Save as `paper/tables/table_clan.tex`.

### 8. Causal Forest estimation

Run this after the DoubleML estimation (steps 3–7). Read `config.yaml` to
determine which causal forest method to use. If `causal_forest.enabled` is
false, skip this section entirely. If `causal_forest` section is absent,
default is enabled.

If `econml` is not installed, print a warning and skip — do NOT fail the pipeline.

**Step 8a — Choose the causal forest method**

| `identification.type` | `config.causal_forest.method` | Class to use |
|----------------------|-------------------------------|-------------|
| `OLS` or `DID` | `CausalForestDML` (default) | `econml.dml.CausalForestDML` |
| `OLS` or `DID` | `CausalForest` | `econml.grf.CausalForest` |
| `IV` | `CausalForestDML` (default) | `econml.dml.CausalForestDML` (no IV in 1st stage — use controls only) |
| `IV` | `CausalIVForest` | `econml.grf.CausalIVForest` |

**Step 8b — CausalForestDML (recommended default)**

```python
from econml.dml import CausalForestDML

cf_dml = CausalForestDML(
    model_y=RandomForestRegressor(n_estimators=200, max_depth=5, random_state=42),
    model_t=RandomForestRegressor(n_estimators=200, max_depth=5, random_state=42),
    n_estimators=config.get("causal_forest", {}).get("n_estimators", 1000),
    min_samples_leaf=config.get("causal_forest", {}).get("min_samples_leaf", 5),
    max_depth=config.get("causal_forest", {}).get("max_depth", None),
    honest=True,
    inference=True,
    criterion=config.get("causal_forest", {}).get("criterion", "mse"),
    cv=config.get("causal_forest", {}).get("cv", 5),
    random_state=42,
)

# X = effect modifiers (controls), W = confounders (can overlap or be same as X)
X_cf = df[spec["identification"]["controls"]].values
Y_cf = df[spec["identification"]["outcome_variable"]].values
T_cf = df[spec["identification"]["treatment_variable"]].values

cf_dml.fit(Y_cf, T_cf, X=X_cf, W=X_cf)

# ATE with inference
ate_inf = cf_dml.ate_inference(X=X_cf)
cf_ate = float(ate_inf.point_estimate)
cf_ate_se = float(ate_inf.stderr)
cf_ate_ci = ate_inf.conf_int(alpha=0.05)

# CATE per observation
cate_pred = cf_dml.effect(X_cf)
cate_inf = cf_dml.effect_inference(X_cf)
cate_ci = cate_inf.conf_int(alpha=0.05)

# Feature importances
feat_imp = cf_dml.feature_importances_

# Above/below median ATE comparison (following B&N)
median_cate = np.median(cate_pred)
above_median = cate_pred >= median_cate
ate_above = cf_dml.ate_inference(X=X_cf[above_median])
ate_below = cf_dml.ate_inference(X=X_cf[~above_median])

# Calibration test: regress actual residuals on predicted CATEs
Y_res_cf = Y_cf - cf_dml.models_y[0][0].predict(X_cf)
T_res_cf = T_cf - cf_dml.models_t[0][0].predict(X_cf)
calib_model = sm.OLS(Y_res_cf, sm.add_constant(cate_pred * T_res_cf)).fit()
calibration_slope = float(calib_model.params[1])
calibration_pval = float(calib_model.pvalues[1])
```

**Step 8c — CausalIVForest (IV papers only)**

```python
from econml.grf import CausalIVForest

cf_iv = CausalIVForest(
    n_estimators=config.get("causal_forest", {}).get("n_estimators", 1000),
    min_samples_leaf=config.get("causal_forest", {}).get("min_samples_leaf", 5),
    max_depth=config.get("causal_forest", {}).get("max_depth", None),
    honest=True,
    inference=True,
    criterion=config.get("causal_forest", {}).get("criterion", "mse"),
    random_state=42,
)

X_cf = df[spec["identification"]["controls"]].values
T_cf = df[spec["identification"]["treatment_variable"]].values
Y_cf = df[spec["identification"]["outcome_variable"]].values
Z_cf = df[spec["identification"]["instrument"]].values

cf_iv.fit(X_cf, T_cf, Y_cf, Z=Z_cf)

# CATE per observation (LATE estimates)
cate_pred = cf_iv.predict(X_cf)
cate_ci_bounds = cf_iv.predict_interval(X_cf, alpha=0.05)

# ATE from prediction intervals (NOT naive std/sqrt(n))
cf_ate = float(np.mean(cate_pred))
cf_ate_ci_lo = float(np.mean(cate_ci_bounds[0]))
cf_ate_ci_hi = float(np.mean(cate_ci_bounds[1]))
cf_ate_se = (cf_ate_ci_hi - cf_ate_ci_lo) / (2 * 1.96)

# Feature importances
feat_imp = cf_iv.feature_importances(max_depth=4)
```

**Step 8d — Write `causal_forest_results.json`**

```json
{
  "method": "CausalForestDML",
  "n_obs": 145,
  "n_estimators": 1000,
  "honest": true,
  "ate": -0.128,
  "ate_se": 0.039,
  "ate_ci_lo": -0.204,
  "ate_ci_hi": -0.052,
  "ate_above_median": -0.08,
  "ate_below_median": -0.17,
  "calibration": {"slope": 0.95, "pval": 0.62, "well_calibrated": true},
  "cate_summary": {
    "mean": -0.128,
    "sd": 0.065,
    "min": -0.31,
    "max": 0.02,
    "pct_negative": 0.94,
    "pct_significant": 0.72
  },
  "feature_importances": {
    "ln_yst": 0.42,
    "latitude": 0.18,
    "africa": 0.15,
    "asia": 0.12,
    "other_control": 0.13
  },
  "sign_change_vs_published": false,
  "sign_change_vs_dml": false
}
```

`pct_negative` = fraction of observations with θ̂(x) < 0.
`pct_significant` = fraction where the individual 95% CI excludes zero.

**Step 8e — CATE histogram**

Plot the distribution of individual-level CATE estimates:
- Histogram with kernel density overlay
- Vertical dashed line at 0 and at ATE
- Title: "Distribution of Conditional Average Treatment Effects"
- Save as `paper/figures/cate_histogram.pdf` and `.png`

**Step 8f — Feature importance plot**

Horizontal bar chart of feature importances from the causal forest:
- Y-axis: variable names (from `spec["identification"]["controls"]`)
- X-axis: importance score
- Sorted descending
- Title: "Causal Forest: Heterogeneity Drivers"
- Save as `paper/figures/feature_importance.pdf` and `.png`

### 9. Forest plot

Create a coefficient comparison figure for the **primary specification**:
- Y-axis labels: "Lasso", "Dec. Tree", "Boosting", "Forest", "Neural Net", "Ensemble", "Best", "OLS", "Causal Forest" (if available)
- X-axis: coefficient estimate with 95% CI bars
- Vertical dashed line at 0
- Colour: grey for OLS, blue for DML methods, green for Causal Forest
- Include Causal Forest ATE only if `causal_forest_results.json` exists
- Save as `paper/figures/forest_plot.pdf` AND `paper/figures/forest_plot.png`

### 10. B&N-style LaTeX comparison table

Produce the table in Baiardi & Naghi's format (Table 1 in their paper).
This is the main results table.

**Columns:** Lasso | Dec. Tree | Boosting | Forest | NNet | Ensemble | Best | OLS

**Rows:** One panel per outcome variable. Within each panel, one row per treatment.
Each cell: coefficient with significance stars, SE in parentheses below.

```latex
\begin{table}[htbp]
\centering
\caption{The effect of corporate taxes on investment and entrepreneurship.}
\small
\begin{tabular}{lcccccccc}
\toprule
 & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\
 & Lasso & Tree & Boosting & Forest & NNet & Ensemble & Best & OLS \\
\midrule
\multicolumn{9}{l}{\textit{Panel A: Investment 2003--2005}} \\
Statutory rate     & ... & ... & ... & ... & ... & ... & ... & ... \\
                   & (...) & (...) & ... \\
Effective rate     & ... \\
Five-year eff.     & ... \\
Observations       & 61 \\
\midrule
\multicolumn{9}{l}{\textit{Panel B: FDI 2003--2005}} \\
...
\bottomrule
\end{tabular}
\end{table}
```

Save as `paper/tables/table_dml.tex`.

Also include at the bottom of each panel:
- N (observations)
- Number of controls

## SE sanity check (MANDATORY for causal forest)

After computing the causal forest ATE SE and CI, run this validation:

```python
ate_ci_width = cf_ate_ci_hi - cf_ate_ci_lo
mean_cate_ci_width = float(np.mean(cate_ci[:, 1] - cate_ci[:, 0]))
ratio = mean_cate_ci_width / ate_ci_width if ate_ci_width > 0 else float('inf')

if ratio > 10:
    raise ValueError(
        f'ATE CI is {ratio:.0f}x narrower than individual CATE CIs. '
        f'ATE SE was computed incorrectly. Use predict_interval() bounds.'
    )
```

**WARNING:** Do NOT use `np.std(cate_pred) / np.sqrt(n)` for the ATE SE — this
produces implausibly narrow CIs. Always derive the ATE CI from `predict_interval()`.

## Rules
- Run all outcome×treatment combinations from the specification grid, not just the primary
- Use 7 ML methods (Lasso, DecisionTree, Boosting, Forest, NeuralNet, Ensemble, Best)
- **Best learner selection:** lowest out-of-sample nuisance MSE. NEVER select by p-value or coefficient magnitude.
- **Ensemble:** MSE-inverse-weighted combination of individual methods
- **Median aggregation:** report median coefficient across `n_rep` repetitions, with B&N adjusted SE
- **K-folds:** use K=2 for n_obs < 200; K=5 for n_obs >= 200
- **n_rep:** minimum 20 (default), configurable
- Always run BLP before GATE as formal heterogeneity test
- GATE uses 5 quintiles of predicted CATE (not an arbitrary control variable)
- CLAN compares top vs bottom quintile characteristics
- Report both individual learner results AND Ensemble/Best
- If DML estimate has opposite sign to published, flag with `"sign_change_vs_published": true`
- Always run the causal forest if `config.yaml` has `causal_forest.enabled: true` (or if `causal_forest` section is absent — default is enabled). Skip gracefully if econml not installed.
- If causal forest ATE has opposite sign to DML Best learner, flag with `"sign_change_vs_dml": true`
- Feature importances must sum to ~1.0 (normalize if needed)
- Lasso coefficient diagnostics are mandatory — report which variables are selected
