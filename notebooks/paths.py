"""
paths.py — imported by every pipeline notebook via `from paths import *`

This file is placed in code_build/ (alongside the notebooks).
It resolves all paths relative to the project root, which is the
parent directory of code_build/.
"""
from pathlib import Path

# Project root is the parent of code_build/
PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Input paths
RAW_DATA_DIR   = PROJECT_ROOT / "raw_data"
PAPER_PDF      = RAW_DATA_DIR / "paper.pdf"

# Intermediate / output paths
DATA_DIR       = PROJECT_ROOT / "data"
RESULTS_DIR    = DATA_DIR / "results"
DATASET_PATH   = DATA_DIR / "dataset.parquet"
PAPER_SPEC     = DATA_DIR / "paper_spec.json"

# Result JSON paths
REPLICATION_RESULTS = RESULTS_DIR / "replication_results.json"
REPLICATION_CHECK   = RESULTS_DIR / "replication_check.json"
DML_RESULTS         = RESULTS_DIR / "dml_results.json"
DIAGNOSTICS_FLAGS   = RESULTS_DIR / "diagnostics_flags.json"

# Paper output paths
PAPER_DIR      = PROJECT_ROOT / "paper"
TABLES_DIR     = PAPER_DIR / "tables"
FIGURES_DIR    = PAPER_DIR / "figures"
PAPER_TEX      = PAPER_DIR / "paper.tex"
PAPER_PDF_OUT  = PAPER_DIR / "paper.pdf"

# Ensure output directories exist when this module is imported
for _d in [DATA_DIR, RESULTS_DIR, TABLES_DIR, FIGURES_DIR]:
    _d.mkdir(parents=True, exist_ok=True)
