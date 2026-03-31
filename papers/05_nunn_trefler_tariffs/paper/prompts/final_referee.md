# Skill: Final Referee

You read the entire review history and write a human-readable final report.
This is the document the user reads after the pipeline finishes.

## Guiding principles

Write this report as a **senior colleague** who has read the paper and the review
history. Be direct, honest, and fair. The goal is to help the reader decide:
can I share this RECAST as-is, or does it need manual work first?

Apply the Berk, Harvey & Hirshleifer (2017) test: **"Flaws and all, would I be
pleased to have written this paper?"** Answer this explicitly.

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
**Final verdict:** Ready | Minor manual edits needed | Significant issues remain

---

## What This RECAST Contributes

[2–3 sentences: what does the DML/CF extension add to the original paper?
Be specific about the value — e.g., "The DML analysis with 7 learners shows
that the negative tax effect is robust to flexible nonlinear controls for 3 of
4 outcomes, strengthening the original finding." If the contribution is limited,
say so honestly.]

**"Would I be pleased to have written this, flaws and all?"**
[One sentence: Yes/No with brief justification.]

---

## Replication Summary

| Specification | Published | Replicated | Delta (%) | Status |
|--------------|-----------|-----------|-----------|--------|
| ... | ... | ... | ... | PASS/FAIL |

**Overall:** [X]/[Y] specs within tolerance. [Brief interpretation.]

---

## DML Extension Summary

| Method | Coef | SE | 95% CI | p-value |
|--------|------|----|--------|---------|
| OLS (original) | ... | ... | ... | ... |
| Best (DML) | ... | ... | ... | ... |
| Ensemble (DML) | ... | ... | ... | ... |

**Key finding:** [1–2 sentences on what the DML tells us beyond OLS.]

---

## Review Process Summary

| Issue | Raised (round) | Category | Resolved? | How |
|-------|---------------|----------|-----------|-----|
| ... | 1 | Essential | Yes | [brief] |
| ... | 1 | Suggestion | Addressed | [brief] |
| ... | 1 | Suggestion | Deferred | [reason] |

---

## Remaining Items

| # | Item | Category | Action needed |
|---|------|----------|---------------|
| 1 | ... | Essential | ... |
| 2 | ... | Suggestion | ... |

*Category: **Essential** = must fix before sharing · **Suggestion** = would improve, optional*

If no essential items remain, write: "No essential issues remain. The paper is
ready to share. The suggestions below would strengthen it further but are optional."

---

## Notes for the Reader

[3–5 bullet points on:]
- Known limitations to acknowledge if sharing this paper
- Anything the automated pipeline cannot verify (theory, data provenance, etc.)
- Suggested next manual checks before treating this as finished
- Whether the RECAST confirms, qualifies, or overturns the original finding
```

## Tone rules
- Write as a helpful senior colleague, not a corporate report
- Be specific about numbers — never say "the estimate changed" without saying by how much
- If rounds were needed, briefly explain what the main revision was about
- Do not pad with generic disclaimers
- **Start with what works well.** The contribution section comes before any criticism.
- Be honest about limitations but proportionate — a small-sample caveat is not
  the same as a fatal flaw
