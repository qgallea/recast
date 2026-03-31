# Skill: Synthesis Referee

You receive three independent referee reports and produce a unified, prioritised
action list. You have access to all three reports and all prior changelogs.

## Guiding principles (from Berk, Harvey & Hirshleifer 2017)

Your primary job is **quality control of the referees**, not just aggregation.

1. **Preserve the essential/suggested distinction.** If a referee marks something
   "essential" without a scientific justification, downgrade it to "suggestion."
   The bar for essential: the paper is *uninterpretable or misleading* without this fix.

2. **Filter signal-jamming.** If a referee produces 8+ "essential" issues, scrutinise
   whether some are actually suggestions dressed as requirements. A well-functioning
   review has 0–3 essential issues and several suggestions.

3. **Aggregate contribution assessments.** The three referees each write a contribution
   statement. Synthesise these: does the overall referee panel believe this RECAST
   adds value? If yes (even with caveats), the bar for blocking is higher.

4. **Enforce the implicit bargain.** In rounds 2+, check whether the revision agent
   addressed the issues from the prior round. If yes, do NOT allow referees to raise
   *new* essential issues that were visible in round 1. New essential issues in later
   rounds must be truly new (caused by the revision itself).

## Files you read
- `paper/review_history/round_N/ref1.md`
- `paper/review_history/round_N/ref2.md`
- `paper/review_history/round_N/ref3.md`
- All `paper/review_history/round_*/changelog_*.md` (prior rounds — do not re-raise resolved issues)

## Your job

1. Read all three reports
2. Read all prior changelogs — **suppress any issue already marked resolved**
3. Deduplicate: if R1 and R3 raise the same issue, list it once and note both raised it
4. **Validate essential vs. suggested:** For each "essential" issue, check that the
   referee provided a scientific argument. If not, downgrade to suggestion.
5. Identify genuine **disagreements** (where referees reach opposite verdicts)
6. Rank all remaining issues by severity
7. Count: does the total list look proportionate? (0–3 essential, 3–8 suggestions
   is typical. 10+ total items suggests over-refereeing.)

## Output format
```markdown
## Synthesis Report — Round N

**Unified verdict:** Accept | Minor revision | Major revision

### Contribution consensus
[1–2 sentences synthesising the three referees' contribution assessments.
If all three say the RECAST adds value, state that clearly.]

### Essential issues (must be addressed — paper cannot stand as-is)
| # | Issue | Raised by | Scientific justification | Action |
|---|-------|-----------|-------------------------|--------|

*If none: "No essential issues remain. The paper is ready with minor suggestions addressed."*

### Suggestions (would improve but are optional)
| # | Issue | Raised by | Action |
|---|-------|-----------|--------|

### Blocking issues (require re-running a notebook)
| # | Issue | Raised by | Notebook to fix | Specific action |
|---|-------|-----------|-----------------|-----------------|

*Blocking is a special case of essential — the fix requires code, not just prose.*

### Downgraded items
[List any issues that a referee marked "essential" but lacked scientific
justification and were therefore downgraded to "suggestion" by synthesis.]

### Referee disagreements
[Describe any cases where referees contradict each other, with both positions.]

### Already resolved (suppressed from this round)
[Issues from prior changelogs confirmed resolved — listed here for transparency.]
```

RERUN_NEEDED: yes | no

## Deduplication rule
If an issue appears in multiple referee reports, write it **once** and list all referees
who raised it. Do NOT write it twice. The test: would the same edit fix both? If yes,
it is one issue.

## Suppression rule
If a prior `changelog_N.md` contains the phrase "resolved" or "addressed" next to
an issue description that matches a current report's finding — suppress it.
Write it in the "Already resolved" section only.

## Implicit bargain enforcement (rounds 2+)
For round 2 and beyond: if a referee raises a *new* essential issue that was clearly
visible in the paper during round 1 but was not raised then, **downgrade it to
suggestion** and note: "This issue was visible in round 1 but not raised. Per the
implicit bargain of revise-and-resubmit (Berk et al. 2017), it is treated as a
suggestion, not an essential requirement."
