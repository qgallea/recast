# econml.grf.CausalIVForest — Reference

**Import:** `from econml.grf import CausalIVForest`

An instrumental variable variant of CausalForest. Handles endogenous treatment
by using instruments Z within the forest's moment conditions. Estimates
heterogeneous LATE (Local Average Treatment Effects).

## When to use

Use for IV settings where you want forest-based heterogeneous LATE estimation.
The IV relationship is handled entirely within the forest — no separate first
stage residualization.

## Constructor parameters

Same as CausalForest, plus:
- `n_estimators=100`, `criterion='mse'`, `max_depth=None`
- `min_samples_split=10`, `min_samples_leaf=5`
- `min_var_fraction_leaf=None` — constrains treatment-instrument covariance
  within leaves (avoids weak-instrument problems at the leaf level)
- `honest=True`, `inference=True`, `fit_intercept=True`
- `subforest_size=4`, `n_jobs=-1`, `random_state=None`

## fit() signature

```python
model.fit(X, T, y, Z=instruments, sample_weight=None)
```

- **X** — features/confounders (n, p)
- **T** — endogenous treatment (n,)
- **y** — outcome (n,)
- **Z** — instruments (n, d_z) — **required**

## Key methods

- `predict(X, interval=False, alpha=0.05)` — heterogeneous LATE estimates
- `predict_interval(X, alpha=0.05)` — CI bounds
- `predict_var(X)` — covariance matrices
- `feature_importances(max_depth=4, depth_decay_exponent=2.0)`

## Outputs

- Heterogeneous LATE per observation
- Confidence intervals (when `inference=True`)
- Feature importances

## IV support

**Yes** — this is the IV estimator. The `fit()` method requires a `Z` argument.

## Key differences from CausalForest

- `fit()` requires instruments `Z`
- `min_var_fraction_leaf` constrains treatment-instrument covariance (not just
  treatment variance) to prevent weak-instrument problems at the leaf level
- Estimates LATE, not ATE

## Key differences from DoubleML PLIV

| Feature | DoubleML PLIV | CausalIVForest |
|---------|--------------|----------------|
| First stage | Cross-fitted ML | None (within-forest) |
| Second stage | Linear IV | Forest-based IV |
| Output | ATE (scalar) | Heterogeneous LATE |
| Orthogonalization | Yes (Neyman-orthogonal) | No |
| Heterogeneity | Requires separate GATE step | Built-in |
