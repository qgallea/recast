# econml.grf.CausalForest — Reference

**Import:** `from econml.grf import CausalForest`

A Generalized Random Forest that directly estimates heterogeneous treatment
effects without DML residualization. Solves the local moment equation
E[(Y − θ(x)·T − β(x))·(T; 1) | X=x] = 0 at each tree node.

## When to use

Use when you want direct forest-based CATE estimation without first-stage
residualization. All confounders must be included in X. No orthogonalization
protects against slow-converging nuisance estimation — use CausalForestDML
instead when confounding is a concern.

## Constructor parameters

- `n_estimators=100` — number of trees
- `criterion='mse'` — split criterion ('mse' or 'het' for heterogeneity maximization)
- `max_depth=None`, `min_samples_split=10`, `min_samples_leaf=5`
- `min_var_fraction_leaf=None` — ensures treatment variance within leaves
- `honest=True` — splits data into train/val for unbiased leaf values
- `inference=True` — enables bootstrap-of-little-bags CIs
- `fit_intercept=True` — includes nuisance intercept β(x)
- `subforest_size=4`, `n_jobs=-1`, `random_state=None`

## fit() signature

```python
model.fit(X, T, y, sample_weight=None)
```

- **X** — features/confounders (n, p)
- **T** — treatment (n,) or (n, d_t)
- **y** — outcome (n,)

**Note:** argument order is (X, T, y) — different from CausalForestDML's (Y, T, X, W).

## Key methods

- `predict(X, interval=False, alpha=0.05)` — CATE estimates, optionally with CIs
- `predict_interval(X, alpha=0.05)` — CI bounds directly
- `predict_var(X)` — covariance matrices
- `feature_importances(max_depth=4, depth_decay_exponent=2.0)` — heterogeneity importance

## Outputs

- CATE θ(x) per observation
- Confidence intervals (when `inference=True`)
- Feature importances

## IV support

**No.** For IV estimation use `CausalIVForest`.

## Limitations vs CausalForestDML

- No first-stage residualization → more sensitive to confounding
- No built-in `ate()` or `effect()` methods — use `predict()` and average
- No separate controls (W) vs effect modifiers (X) distinction
