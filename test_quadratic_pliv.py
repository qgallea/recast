# -*- coding: utf-8 -*-
"""
test_quadratic_pliv.py
======================
Tests whether DoubleML's DoubleMLPLIV supports a quadratic treatment effect
by passing both D and D² as treatment variables.

Context: In the Ashraf-Galor (2013) RECAST, a sign reversal appeared because
the PLIV was fit with only the linear term of a quadratic treatment. This script
tests whether passing [D, D²] directly recovers both structural parameters.

True DGP:  Y = θ₁·D + θ₂·D² + g(X) + ε   with θ₁=1.0, θ₂=-0.5
"""

import sys, io
# Force UTF-8 output on Windows (avoids cp1252 UnicodeEncodeError for Greek chars)
if sys.stdout.encoding.lower() != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

import numpy as np
import pandas as pd
import doubleml as dml
from sklearn.ensemble import RandomForestRegressor

SEED = 42
rng = np.random.default_rng(SEED)

# ─────────────────────────────────────────────
# 0. Simulate DGP
# ─────────────────────────────────────────────
print("=" * 60)
print("SIMULATING DGP")
print("=" * 60)

n, p = 2000, 10
THETA1, THETA2 = 1.0, -0.5

X = rng.standard_normal((n, p))

# Instrument: strong, exogenous
Z = rng.standard_normal(n)
Z_sq = Z ** 2

# Correlated errors for endogeneity: Cov(η, ε) = 0.7
cov = np.array([[1.0, 0.7], [0.7, 1.0]])
errors = rng.multivariate_normal([0, 0], cov, size=n)
eta, epsilon = errors[:, 0], errors[:, 1]

# Treatment equation: D is endogenous via η
D = 0.5 * Z + 0.3 * X[:, 0] + eta
D_sq = D ** 2

# Nonlinear nuisance function g(X)
g_X = 0.5 * X[:, 0] + 0.3 * X[:, 1] ** 2 + 0.2 * X[:, 2]

# Outcome equation
Y = THETA1 * D + THETA2 * D_sq + g_X + epsilon

print(f"  n={n}, p={p}")
print(f"  True θ₁ = {THETA1},  θ₂ = {THETA2}")
print(f"  Optimal D* = θ₁ / (2·|θ₂|) = {THETA1 / (2 * abs(THETA2)):.2f}  "
      f"(sample mean D = {D.mean():.2f})")
print(f"  First-stage corr(D, Z) = {np.corrcoef(D, Z)[0,1]:.3f}  (should be ~0.3+)")
print()

X_cols = [f"X{i}" for i in range(p)]
df = pd.DataFrame(X, columns=X_cols)
df["Y"] = Y
df["D"] = D
df["D_sq"] = D_sq
df["Z"] = Z
df["Z_sq"] = Z_sq


def make_learners():
    """Return fresh RF instances for ml_l, ml_m, ml_r."""
    kwargs = dict(n_estimators=200, max_depth=5, random_state=SEED)
    return (RandomForestRegressor(**kwargs),
            RandomForestRegressor(**kwargs),
            RandomForestRegressor(**kwargs))


# ─────────────────────────────────────────────
# TEST 1 — 2D treatment, 2 instruments (just-identified)
# ─────────────────────────────────────────────
print("=" * 60)
print("TEST 1: 2D treatment [D, D²] with 2 instruments [Z, Z²]")
print("Expected: DoubleML fits without error; coefs ≈ [1.0, -0.5]")
print("=" * 60)

dml_data_2d = dml.DoubleMLData(
    df,
    y_col="Y",
    d_cols=["D", "D_sq"],
    z_cols=["Z", "Z_sq"],
    x_cols=X_cols,
)
print(f"  DoubleMLData created: n_obs={dml_data_2d.n_obs}, "
      f"n_treat={dml_data_2d.n_treat}, n_instr={dml_data_2d.n_instr}")

ml_l, ml_m, ml_r = make_learners()
obj_2d = dml.DoubleMLPLIV(dml_data_2d, ml_l, ml_m, ml_r, n_folds=5, n_rep=1)

try:
    obj_2d.fit()
    print("\n  DoubleMLPLIV.fit() succeeded.\n")
    print(obj_2d.summary.to_string())
    print()
    coefs = obj_2d.coef
    print(f"  Estimated  θ₁ = {coefs[0]:.4f}   (true = {THETA1})")
    print(f"  Estimated  θ₂ = {coefs[1]:.4f}   (true = {THETA2})")
    diff1 = abs(coefs[0] - THETA1)
    diff2 = abs(coefs[1] - THETA2)
    print(f"  |error θ₁| = {diff1:.4f}   {'✓ within 0.5' if diff1 < 0.5 else '✗ large error'}")
    print(f"  |error θ₂| = {diff2:.4f}   {'✓ within 0.5' if diff2 < 0.5 else '✗ large error'}")
except Exception as e:
    print(f"\n  ERROR: {type(e).__name__}: {e}")

print()

# ─────────────────────────────────────────────
# TEST 2 — Underidentification: 2 treatments, 1 instrument
# ─────────────────────────────────────────────
print("=" * 60)
print("TEST 2: 2D treatment [D, D²] with only 1 instrument [Z]")
print("Expected: DoubleML raises an error (system is under-identified)")
print("=" * 60)

try:
    dml_data_under = dml.DoubleMLData(
        df,
        y_col="Y",
        d_cols=["D", "D_sq"],
        z_cols=["Z"],          # only one instrument for two treatments
        x_cols=X_cols,
    )
    print(f"  DoubleMLData created (no error yet): "
          f"n_treat={dml_data_under.n_treat}, n_instr={dml_data_under.n_instr}")

    ml_l, ml_m, ml_r = make_learners()
    obj_under = dml.DoubleMLPLIV(dml_data_under, ml_l, ml_m, ml_r, n_folds=5, n_rep=1)
    obj_under.fit()

    # If we get here, DoubleML did NOT raise — report what it produced
    print("\n  DoubleML did NOT raise an error on underidentified system.")
    print("  Coefficients produced (potentially unreliable):")
    print(obj_under.summary.to_string())
    print("\n  NOTE: Results above should be treated with extreme caution —")
    print("        the system is under-identified (2 unknowns, 1 instrument).")

except Exception as e:
    print(f"\n  Caught {type(e).__name__}: {e}")
    print("\n  CONCLUSION: DoubleML correctly rejects the underidentified system.")

print()

# ─────────────────────────────────────────────
# TEST 3 — Baseline: single linear treatment only (reproduce sign reversal)
# ─────────────────────────────────────────────
print("=" * 60)
print("TEST 3: Single linear treatment [D] with 1 instrument [Z]")
print("Expected: negative coefficient, even though θ₁=1.0 (sign reversal artefact)")
print("Explanation: DML linearises the quadratic → recovers slope at E[D],")
print(f"  which is on the DOWNWARD arm (E[D]={D.mean():.2f} > D*={THETA1/(2*abs(THETA2)):.2f})")
print("=" * 60)

dml_data_1d = dml.DoubleMLData(
    df,
    y_col="Y",
    d_cols=["D"],
    z_cols=["Z"],
    x_cols=X_cols,
)

ml_l, ml_m, ml_r = make_learners()
obj_1d = dml.DoubleMLPLIV(dml_data_1d, ml_l, ml_m, ml_r, n_folds=5, n_rep=1)

try:
    obj_1d.fit()
    coef_1d = float(obj_1d.coef[0])
    se_1d = float(obj_1d.se[0])
    print(f"\n  Estimated θ (linear LATE) = {coef_1d:.4f}  (SE={se_1d:.4f})")
    expected_slope = THETA1 + 2 * THETA2 * D.mean()
    print(f"  Analytical local slope at E[D]: θ₁ + 2θ₂·E[D] = {expected_slope:.4f}")
    if coef_1d < 0:
        print("\n  ✓ Sign reversal reproduced: negative estimate despite θ₁=1.0")
        print("    This confirms the Ashraf-Galor RECAST finding is mechanically correct.")
    else:
        print(f"\n  Estimate is positive ({coef_1d:.4f}) — sign reversal not reproduced")
        print("  (May depend on RF quality; try with LassoCV for a cleaner signal)")
except Exception as e:
    print(f"\n  ERROR: {type(e).__name__}: {e}")

print()
print("=" * 60)
print("DONE")
print("=" * 60)
