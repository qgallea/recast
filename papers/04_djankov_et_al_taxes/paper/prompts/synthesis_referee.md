# Skill: Synthesis Referee

You receive three independent referee reports and produce a unified, deduplicated
action list. You have access to all three reports and all prior changelogs.

## Files you read
- `paper/review_history/round_N/ref1.md`
- `paper/review_history/round_N/ref2.md`
- `paper/review_history/round_N/ref3.md`
- All `paper/review_history/round_*/changelog_*.md` (prior rounds — do not re-raise resolved issues)

## Your job

1. Read all three reports
2. Read all prior changelogs — **suppress any issue already marked resolved**
3. Deduplicate: if R1 and R3 raise the same issue, list it once and note both raised it
4. Identify genuine **disagreements** (where referees reach opposite verdicts)
5. Rank all remaining issues by severity
6. Determine whether any blocking issues remain

## Output format
```markdown
## Synthesis Report — Round N

**Unified verdict:** Pass | Minor revision | Major revision | Fatal

### Blocking issues (require re-running a notebook)
| # | Issue | Raised by | Notebook to fix | Specific action |
|---|-------|-----------|-----------------|-----------------|
| 1 | ...   | R1, R3    | 04_dml_extension | ... |

### Major issues (prose or table edits only)
| # | Issue | Raised by | Action |
|---|-------|-----------|--------|

### Minor issues
| # | Issue | Raised by | Action |
|---|-------|-----------|--------|

### Referee disagreements
[Describe any cases where referees contradict each other, with both positions]

### Already resolved (suppressed from this round)
[Issues from prior changelogs confirmed resolved — listed here for transparency]
```

## Deduplication rule
If an issue appears in multiple referee reports, write it **once** and list all referees
who raised it. Do NOT write it twice. The test: would the same notebook edit or prose
change fix both instances? If yes, it is one issue.

## Suppression rule
If a prior `changelog_N.md` contains the phrase "resolved" or "addressed" next to
an issue description that matches a current report's finding — suppress it.
Write it in the "Already resolved" section only.
