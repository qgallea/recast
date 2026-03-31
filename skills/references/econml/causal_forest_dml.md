# econml.dml.CausalForestDML — Reference

**Import:** `from econml.dml import CausalForestDML`

Combines DML-based cross-fitted residualization (first stage) with a causal
forest (second stage). This is the recommended class for most applied work
because it inherits Neyman-orthogonal debiasing from DML while estimating
heterogeneous treatment effects via an honest causal forest.

## How it works

1. **First stage (DML):** Cross-fit `model_y` for E[Y|X,W] and `model_t` for
   E[T|X,W]. Compute residuals Y_res = Y − Ê[Y|X,W] and T_res = T − Ê[T|X,W].
2. **Second stage (Causal Forest):** Fit an honest causal forest on the
   residuals, solving E[(Y_res − θ(x)·T_res − β(x))·(T_res; 1) | X=x] = 0.

## Constructor parameters

### DML-specific
- `model_y='auto'` — outcome nuisance model (any sklearn regressor/classifier)
- `model_t='auto'` — treatment nuisance model
- `discrete_treatment=False` — set True for binary/categorical treatment
- `cv=2` — cross-validation folds for first stage
- `mc_iters=None` — Monte Carlo iterations to reduce nuisance variance
- `mc_agg='mean'` — aggregation across MC iterations

### Forest parameters
- `n_estimators=100` — number of trees
- `criterion='mse'` — split criterion ('mse' or 'het')
- `max_depth=None`, `min_samples_split=10`, `min_samples_leaf=5`
- `min_var_fraction_leaf=None` — minimum treatment variance in leaves
- `max_features='auto'`, `max_samples=0.45`
- `honest=True` — train/val split within each tree for unbiased estimates
- `inference=True` — enables bootstrap-of-little-bags CIs
- `subforest_size=4` — trees per sub-forest for variance estimation
- `n_jobs=-1`, `random_state=None`

## fit() signature

```python
model.fit(Y, T, X=None, W=None, sample_weight=None)
```

- **Y** — outcome array (n,)
- **T** — treatment array (n,) or (n, d_t)
- **X** — effect modifiers (features for CATE heterogeneity)
- **W** — controls/confounders (used in first stage only, not in CATE)

**Important:** argument order is (Y, T, X, W) — not (X, T, y) like grf classes.

## Key methods

### Effect estimation
- `effect(X, T0=None, T1=None)` — CATE at points X
- `const_marginal_effect(X)` — constant marginal effect θ(X)
- `ate(X=None, T0=None, T1=None)` — average treatment effect

### Inference (returns objects with .point_estimate, .stderr, .conf_int(), .pvalue())
- `effect_inference(X, T0=None, T1=None)` — CATE with CIs
- `ate_inference(X=None, T0=None, T1=None)` — ATE with CIs
- `const_marginal_ate_inference(X=None)` — average marginal effect with CIs

### Other
- `summary()` — summary statistics
- `feature_importances_` — heterogeneity-based feature importance (attribute)

## Outputs

- **CATE** θ(x) for each observation
- **ATE** (scalar) with SE, CI, p-value
- **Feature importances** — which covariates drive heterogeneity
- **Confidence intervals** via bootstrap-of-little-bags (honest inference)

## IV support

**No.** CausalForestDML uses selection-on-observables identification. For IV
settings, use `CausalIVForest` from `econml.grf`.

## Comparison to standard DoubleML

| Feature | DoubleML (doubleml pkg) | CausalForestDML |
|---------|------------------------|-----------------|
| First stage | Cross-fitted ML nuisance | Cross-fitted ML nuisance |
| Second stage | Linear (PLR/PLIV) | Causal forest |
| Output | ATE only | ATE + CATE |
| Heterogeneity | Requires separate GATE/CATE step | Built-in |
| Feature importance | Not available | Built-in |
| IV support | Yes (PLIV) | No |
