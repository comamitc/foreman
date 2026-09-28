# Pack

One owner-only file per launch, `briefs/<brief stem>.pack.md`, written by the
coordinator. It is the candidate itself. A path list is
not a pack. Full form: seven headings in this order; a heading with nothing to
carry reads `none` plus the reason.

1. Header line: delivery, station and attempt, candidate identity (spec revision,
   plan comment URL and revision, or `BASE...HEAD` SHAs).
2. `## Acceptance criteria`: the applicable criteria quoted from the admitted spec.
3. `## Candidate`: the current plan text verbatim, or the saved `git diff BASE...HEAD`
   output verbatim under its exact command line.
4. `## Open findings`: rows in the `references/findings.md` obligation format.
   Implementing and review packs carry every planning finding with its proposed
   treatment or refutation and unfinished items; never prior essays.
5. `## Rules that apply`: sentences from repository instructions quoted with
   `path:line`. Never a whole file; never `CLAUDE.md`, the operating contract, or
   every caller pasted or pointed at for complete reading. For code review, include
   the effective policy, severity/confidence calibration, partition rules, review
   ratchet, counted round and remaining allowance from `references/review-convergence.md`.
6. `## Checks`: exact commands with cwd and expected exit. A code-review pack
   also carries, under this heading, each applicable red or fault-injection
   observation that implementing recorded, marked as carried evidence (command,
   head, exit, and failure signal) and not as a command to run;
   [references/review.md](review.md) owns the judgment.
   In verification-path adoption, it also carries the path's required state
   and allowed effects; [references/planning.md](planning.md) owns that mode.
7. `## Named files`: `path:line-range` plus reason, the only paths the worker may open.

Compact form, the exception for one Named files entry, one check, and no open
finding rows: nothing is written as `none`, no heading beyond Candidate appears,
and the read-station ceiling is 7 (1 + 1 + 5), an upper bound.

```
# Pack — owner/repo#N, implementing attempt 1, candidate: plan comment URL, revision R
## Candidate
<the one plan item, verbatim>
Criterion: AC 2 — "<quoted criterion>"
Rule: `CONTRIBUTING.md:14` — "<quoted sentence>"
Check: `make test` in WORKTREE, expected exit 0
Named file: `src/cli.py:40-58` — the option parser this item edits
```

The launch gate: if Candidate, Checks, or Open findings cannot be filled with
content or an explicit `none` with a reason, do not launch; observe under recovery.
Unknown is not `none`. A pre-merge
repair pack carries the conflict hunks or failing check log, that check as one row,
the failing gate, and both sides' files readable in full. Gap response, under
one-pass planning precedence:

| Station returning a pack gap | Coordinator response |
| --- | --- |
| initial planning, plan-review | amend the pack; relaunch the unfinished portion of the same step |
| single correction | pass consumed; amend the implementing pack and carry the gap as an unresolved obligation |
| implementing, review, fix, pre-merge repair | amend the pack; relaunch the unfinished portion in the same station |

For an implementing/fix brief carrying effective blocking findings, require one
red/green/bite closure row per finding using `references/findings.md`. Name the
exact reviewed head for red evidence and prohibit proxy checks that test a weaker
condition than the original scenario.
