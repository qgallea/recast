# Skill: Review Loop

Read this skill when executing the `/review` command.

## Guiding principles (from Berk, Harvey & Hirshleifer 2017)

The review process should **complete in one round** whenever possible. A second
round is justified only if: (a) the revision agent partially addressed an essential
issue, or (b) a code re-run introduced a genuinely new problem. Do not run multiple
rounds to achieve perfection — all papers have flaws.

**The implicit bargain:** When the synthesis says "revise," the contract is: if the
essential issues are addressed, the paper is accepted. Referees in round 2+ cannot
invent new essential issues that were visible in round 1.

## CRITICAL: Sub-agent isolation

Every step below (referees, synthesis, **revision**) MUST be a separate
sub-agent call with its own system prompt loaded from the skill file.
The revision agent is the ONLY step that edits `paper.tex`.

**If you collapse the loop into a single agent context, the revision will
fail silently — the agent will document issues without fixing them.**

## State detection
Before starting, check `paper/review_history/` to determine state:
- Count `round_*/` subdirectories → that is the last completed round
- If `round_N/changelog_N.md` exists → round N is complete
- Next round to run = N + 1
- If no rounds exist → start at round 1

## Loop logic (pseudocode)
```
for round in range(next_round, max_rounds + 1):
    create round_dir = paper/review_history/round_{round}/

    # Three referees — isolated, sequential
    for ref_id in [1, 2, 3]:
        report = spawn_referee(ref_id, round)  # isolated context
        save report → round_dir/ref{ref_id}.md

    # Synthesis — quality-controls the referees
    synthesis = spawn_synthesis_referee(round)
    save synthesis → round_dir/synthesis.md

    # Check for blocking or essential issues
    has_essential = synthesis has items in "Essential issues" or "Blocking issues"

    # Revision — MUST be a separate sub-agent call
    # The revision agent reads synthesis.md and EDITS paper.tex directly.
    # Spawn it with skills/revision_agent.md as its system prompt:
    #
    #   claude -p "$(cat skills/revision_agent.md)" \
    #     "Implement the synthesis report for round {round} at <project_path>.
    #      Read paper/review_history/round_{round}/synthesis.md.
    #      Read paper/paper.tex.
    #      You MUST edit paper/paper.tex for all essential issues.
    #      Address low-cost suggestions. Skip high-cost suggestions.
    #      Write changelog_{round}.md documenting every edit.
    #      End with RERUN_NEEDED: yes or RERUN_NEEDED: no."
    #
    changelog, needs_rerun = spawn_revision_agent(round, synthesis)
    save changelog → round_dir/changelog_{round}.md

    if needs_rerun:
        signal orchestrator → run /stage 4

    # Exit conditions (prefer exiting early)
    if not has_essential:
        print(f"✓ Round {round}: no essential issues — paper is ready")
        break

    if round == max_rounds:
        print(f"⚠ Max rounds ({max_rounds}) reached")
        break

    # If entering round 2+, remind referees of implicit bargain
    # (this is built into the synthesis_referee.md instructions)
```

## Referee isolation protocol
Each referee sub-agent call must:
1. Load ONLY its own skill file as system prompt
2. Read ONLY the files listed in that skill's "Files you read" section
3. Have NO access to the other referees' `ref*.md` outputs

The synthesis referee is the first agent in the chain that sees all three reports.

## Early termination
**Prefer fewer rounds.** If the synthesis verdict is "Accept" or "Minor revision"
with only suggestions (no essential issues), skip the revision step and exit
the loop immediately. The final referee will note the suggestions in the final report.

## Progress reporting
After each step, print a one-line status:
```
  ✓ Round 1 / Referee 1: Minor revision (1 essential, 2 suggestions)
  ✓ Round 1 / Referee 2: Accept (0 essential, 3 suggestions)
  ✓ Round 1 / Referee 3: Minor revision (0 essential, 4 suggestions)
  ✓ Round 1 / Synthesis: Minor revision — 1 essential, 6 suggestions, 0 blocking
  ✓ Round 1 / Revision: Complete (RERUN_NEEDED: no)
  → Round 1 complete. Essential issue resolved — paper ready.
```
