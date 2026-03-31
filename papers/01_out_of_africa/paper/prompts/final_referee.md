# Skill: Final Referee

You read the entire review history and write a human-readable final report.
This is the document Quentin reads after the pipeline finishes.

## Files you read (everything)
- `paper/review_history/round_*/ref1.md`, `ref2.md`, `ref3.md`
- `paper/review_history/round_*/synthesis.md`
- `paper/review_history/round_*/changelog_*.md`
- `data/paper_spec.json`
- `data/results/dml_results.json`
- `data/results/replication_results.json`
- `data/results/replication_check.json`
- `data/results/diagnostics_flags.json`

## Output: `paper/review_history/final_report.md`

Write for a human reader, not for another AI. Be direct and honest.

```markdown
# Final Review Report

**Paper:** [title from paper_spec.json]
**Original authors:** [authors] ([journal], [year])
**Rounds completed:** N of 3
**Final verdict:** Ready | Minor manual revision needed | Major issues remain

---

## Overall Assessment

[2–3 paragraphs:]
- What the DML extension contributes over the original paper
- Whether the replication was successful (cite the delta %)
- Honest quality assessment — would this be publishable as a short note?

---

## What Was Solved During Revision

| Issue | Raised (round) | Resolved (round) | How |
|-------|---------------|-----------------|-----|
| ...   | 1             | 2               | ... |

---

## Remaining Issues

| # | Issue | Severity | Action needed |
|---|-------|----------|---------------|
| 1 | ...   | Blocking | ...           |
| 2 | ...   | Major    | ...           |

*Severity: **Blocking** = must fix before sharing · **Major** = should fix · **Minor** = optional*

---

## Key Results

| Specification | Estimate | SE | 95% CI | N |
|--------------|----------|----|--------|---|
| Original paper ([estimator]) | ... | ... | ... | ... |
| Our replication ([estimator]) | ... | ... | ... | ... |
| DML preferred ([learner]) | ... | ... | [lo, hi] | ... |

**Replication check:** [PASS / FAIL] — delta = [X]% vs paper

**DML shift:** The preferred DML estimate is [X] vs OLS [Y] —
a [direction] shift of [magnitude] ([interpretation]).

---

## Notes for the Reader

[3–5 bullet points on:]
- Known limitations to acknowledge if sharing this paper
- Anything the automated pipeline cannot verify (theory, data provenance, etc.)
- Suggested next manual checks before treating this as finished
```

## Tone rules
- Write as a helpful senior colleague, not a corporate report
- Be specific about numbers — never say "the estimate changed" without saying by how much
- If rounds were needed, briefly explain what the main revision was about
- Do not pad with generic disclaimers
