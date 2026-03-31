# Skill: Publish Paper

You create a complete, populated website page for a finished pipeline project.
You read the pipeline's JSON outputs and review history, then write structured
Quarto files into `website/papers/<slug>/`.

## Files you read

From `<project_path>/`:
- `data/paper_spec.json`              ← title, authors, year, journal, DOI,
                                         identification strategy, estimand
- `data/results/replication_check.json`  ← replication status, max delta %,
                                            per-spec table
- `data/results/replication_results.json` ← replicated coefficient table
- `data/results/dml_results.json`     ← estimates, CIs, preferred learner,
                                         cross-fit RMSEs per learner
- `data/results/diagnostics_flags.json`  ← any critical flags to note
- `paper/review_history/final_report.md` ← final verdict, rounds completed,
                                            key numbers table
- `paper/review_history/` — find the highest `round_N/` directory:
  - `round_N/ref1.md`
  - `round_N/ref2.md`
  - `round_N/ref3.md`
  - `round_N/synthesis.md`
- `paper/figures/forest_plot.png`
- `notebook/recast_<slug>.ipynb`        ← pedagogical notebook (if exists)
- `notebook/verification_report.json`   ← verification status (if exists)

## Files you write

Into `website/papers/<slug>/`:
- `index.qmd`          ← fully populated page (see template below)
- `forest_plot.png`    ← copied from `paper/figures/forest_plot.png`
- `reports/ref1.md`    ← copied from last round
- `reports/ref2.md`
- `reports/ref3.md`
- `reports/synthesis.md`
- `reports/final_report.md`  ← copied from `paper/review_history/final_report.md`
- `recast_<slug>.ipynb` ← copied from `notebook/` IF it exists AND verification passed

---

## Step 1 — Derive slug and validate

Slug = lowercase(first_author_surname) + year.
Examples: `acemoglu2001`, `card1994`, `angristkrueger1991`.

If the slug is ambiguous (two papers by the same author in the same year),
ask the user to confirm before proceeding.

Confirm the target directory does not already exist. If it does, stop and
tell the user to pass `--force` to overwrite.

---

## Step 2 — Read and extract

Read all files listed above. Extract the following values:

| Field | Source |
|-------|--------|
| `title` | `paper_spec.json > paper.title` |
| `author` | `paper_spec.json > paper.authors` (last names only, comma-separated) |
| `year` | `paper_spec.json > paper.year` |
| `journal` | `paper_spec.json > paper.journal` |
| `doi` | `paper_spec.json > paper.doi` (empty string if absent) |
| `id_strategy_short` | `paper_spec.json > identification.strategy_type` (e.g. `IV`, `RDD`, `DID`, `OLS`) |
| `id_description` | One sentence summarising instrument/design from `paper_spec.json` |
| `topic_tags` | Up to 3 topic tags from `paper_spec.json > paper.topics` |
| `replication_status` | `replication_check.json > status` → `PASS` or `FAIL` |
| `replication_delta_pct` | `replication_check.json > max_delta_pct` |
| `preferred_learner` | `dml_results.json > preferred_learner` |
| `dml_estimate` | `dml_results.json > results[preferred_learner].estimate` |
| `dml_ci_lo` | `dml_results.json > results[preferred_learner].ci_lo` |
| `dml_ci_hi` | `dml_results.json > results[preferred_learner].ci_hi` |
| `dml_shift` | Derived — see rule below |
| `rounds_completed` | Count `round_*/` dirs in `paper/review_history/` |
| `final_verdict` | Extracted from the "Final verdict" line of `final_report.md` |
| `original_estimate` | `replication_results.json > main_spec.original_estimate` |

**Deriving `dml_shift`:**
Compare `dml_estimate` to `original_estimate`:
- Signs differ → `sign-change`
- `|dml - original| / |original| < 0.10` → `negligible`
- `dml > original` → `upward`
- `dml < original` → `downward`

---

## Step 3 — Copy files

Copy `paper/figures/forest_plot.png` → `website/papers/<slug>/forest_plot.png`.

Copy each of the five `.md` files from the last round and the final report
into `website/papers/<slug>/reports/`. Do not modify their content.

---

## Step 4 — Write `index.qmd`

Write the complete file using the template below. Substitute all `{{ }}`
placeholders with the extracted values. Do not leave any placeholder unfilled —
if a value is missing from the JSON, use a sensible default and add an
HTML comment `<!-- TODO: fill in -->` so the user can find it.

```markdown
---
title: "{{ title }}"
author: "{{ author }}"
date: {{ year }}
date-format: "YYYY"
description: "{{ id_description }}"
categories:
  - {{ id_strategy_short }}
{{ topic_tags | each: "  - {{ tag }}" }}
  - "{{ year }}"
  - {{ replication_status }}
image: forest_plot.png

paper-journal: "{{ journal }}"
paper-doi: "{{ doi }}"

replication-status: {{ replication_status }}
replication-delta-pct: {{ replication_delta_pct }}

dml-estimate: {{ dml_estimate }}
dml-ci-lo: {{ dml_ci_lo }}
dml-ci-hi: {{ dml_ci_hi }}
dml-preferred-learner: "{{ preferred_learner }}"
dml-shift: "{{ dml_shift }}"

rounds-completed: {{ rounds_completed }}
final-verdict: "{{ final_verdict }}"
---

## Paper summary

**Citation:** {{ author }} ({{ year }}). *{{ title }}*. *{{ journal }}*.{{ doi | if: " [DOI](https://doi.org/{{ doi }})" }}

**Identification strategy:** {{ id_description_long }}

**Key original result:** [Extracted from `replication_results.json > main_spec` — fill in the main coefficient with standard error.]

---

## Replication results

The replication **{{ replication_status | lower }}ed**. Maximum coefficient
deviation from the published table: **{{ replication_delta_pct }}%**.

{{ replication_table }}

![Forest plot: original, replicated, and DML estimates](forest_plot.png)

---

## DML extension

{{ dml_model_description }}

{{ dml_table }}

**Preferred learner:** {{ preferred_learner }} (lowest cross-fit RMSE on nuisance functions).

**Interpretation:** The DML estimate ({{ dml_estimate }}, 95% CI:
[{{ dml_ci_lo }}, {{ dml_ci_hi }}]) is {{ dml_shift_prose }} the original
estimate, {{ dml_conclusion }}.

---

## Referee reports

::: {.panel-tabset}

## Identification

{{< include reports/ref1.md >}}

## DML Methods

{{< include reports/ref2.md >}}

## Robustness

{{< include reports/ref3.md >}}

## Synthesis

{{< include reports/synthesis.md >}}

## Final Report

{{< include reports/final_report.md >}}

:::
```

**Building the replication table** from `replication_results.json`:
Render a markdown table with columns: Specification | Original | Replicated | Δ (%).
Include all rows present in `replication_results.json > specs`.

**Building the DML table** from `dml_results.json > results`:
Render a markdown table with columns: Learner | Estimate | 95% CI | Cross-fit RMSE.
Bold the preferred learner row.

**`dml_shift_prose` mapping:**
- `negligible` → "negligibly different from"
- `upward` → "higher than"
- `downward` → "lower than"
- `sign-change` → "opposite in sign to"

**`dml_conclusion` mapping:**
- `negligible` or `upward` or `downward` → "supporting the original conclusion"
- `sign-change` → "qualifying the original conclusion — see the Final Report"

**`dml_model_description`:**
Derive from `paper_spec.json > identification.strategy_type`:
- `IV` → "The Partially Linear IV (PLIV) model was applied with 5-fold cross-fitting."
- `OLS` → "The Partially Linear Regression (PLR) model was applied with 5-fold cross-fitting."
- `DID` → "The Interactive Regression Model (IRM) was applied with 5-fold cross-fitting."
- other → "DoubleML was applied with 5-fold cross-fitting."

---

## Notebook integration

Check if `<project_path>/notebook/recast_<slug>.ipynb` exists:

- **If yes:** Read `notebook/verification_report.json`. If `status == "PASS"`:
  - Copy `notebook/recast_<slug>.ipynb` to `website/papers/<slug>/`
  - Add this section to `index.qmd` before the Referee Reports section:

  ```markdown
  ---

  ## Interactive Notebook

  ::: {.callout-tip}
  ## Explore the full analysis
  Download the self-contained Jupyter notebook to run the complete RECAST
  analysis yourself.

  [Download notebook (.ipynb)](recast_<slug>.ipynb){.btn .btn-primary}
  :::
  ```

  If verification FAILED or `verification_report.json` is missing, warn:
  "Notebook exists but verification did not pass. Skipping notebook from website."

- **If no:** Skip this section. No notebook on the website page.

## Rules

- Never modify the content of referee `.md` files — copy them verbatim.
- If `forest_plot.png` does not exist, write a placeholder `<img>` comment
  in `index.qmd` and warn the user.
- If any JSON field is missing, leave the value as `???` and add
  `<!-- TODO: fill in -->` so the user can find it easily.
- After writing all files, print a file manifest:
  ```
  Created:
    website/papers/<slug>/index.qmd
    website/papers/<slug>/forest_plot.png
    website/papers/<slug>/reports/ref1.md
    website/papers/<slug>/reports/ref2.md
    website/papers/<slug>/reports/ref3.md
    website/papers/<slug>/reports/synthesis.md
    website/papers/<slug>/reports/final_report.md
    website/papers/<slug>/recast_<slug>.ipynb  (if notebook verified)
  ```
