# Pack

One owner-only file per launch, `briefs/<brief stem>.pack.md`, written by the
coordinator. It is the candidate itself. A path list is
not a pack. Full form: seven headings in this order; a heading with nothing to
carry reads `none` plus the reason.

1. Header line: delivery, station and attempt, candidate identity (spec revision,
   plan comment URL and revision, or `BASE...HEAD` SHAs).
2. `## Acceptance criteria`: the applicable criteria quoted from the admitted spec.
3. `## Candidate`: the candidate verbatim, by station.
   - Plan-review and single correction: the current plan text in full.
   - Implementing: the plan's identity lines (specification revision, observed
     head / base, planning step) and its `Ordered items`, `Documentation impact`,
     and `Final proof` sections verbatim. `Current behavior and data shape` and
     `Simplicity decision` stay out, except the specific passage a carried item
     cites, quoted alone. The finding handoff travels as rows under Open
     findings; no other plan or result section travels.
   - Code review and fix: the saved `git diff BASE...HEAD` output verbatim under
     its exact command line. A review or fix pack that carries plan text carries
     only the sections an implementing Candidate carries.
4. `## Open findings`: rows in the `references/findings.md` obligation format.
   Implementing and review packs carry every planning finding with its proposed
   treatment or refutation and unfinished items; never prior essays.
5. `## Rules that apply`: sentences from repository instructions quoted with
   `path:line`. Never a whole file; never `CLAUDE.md`, the operating contract, or
   every caller pasted or pointed at for complete reading.
   This is a content rule, not a reading ban; [references/harnesses/shared.md](harnesses/shared.md) ("A worker inherits its host's instructions") owns host instructions.
   Each quoted repository rule carries its policy row from `ledger.md` as
   carried evidence, not a verdict; [references/telemetry.md](telemetry.md) owns the policy row.
   For code review, include the effective policy, severity/confidence
   calibration, partition rules, review ratchet, counted round and remaining
   allowance from `references/review-convergence.md`.
6. `## Checks`: exact commands with cwd and expected exit. A code-review pack
   also carries, under this heading, each applicable red or fault-injection
   observation that implementing recorded, marked as carried evidence (command,
   head, exit, and failure signal) and not as a command to run;
   [references/review.md](review.md) owns the judgment.
   In verification-path adoption, it also carries the path's required state
   and allowed effects; [references/modes/verification-path.md](modes/verification-path.md) ("This file owns verification-path adoption") owns that mode.
7. `## Named files`: `path:line-range` plus reason, the only task files the worker may open; [references/harnesses/shared.md](harnesses/shared.md) ("A worker inherits its host's instructions") owns host instructions.

Compact form, the exception for one Named files entry, one check, and no open
finding rows: nothing is written as `none`, no heading beyond Candidate appears,
and the read-station ceiling is 7 (1 + 1 + 5), an upper bound.
A compact `Rule:` line carries its policy row from `ledger.md` as carried
evidence, not a verdict; [references/telemetry.md](telemetry.md) owns the policy row.

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
| any station reporting a defective evidence check | repair the check as the coordinator, record old and new in ledger.md, and repeat the bite; then continue by that station's row above, so after single correction the pass stays consumed and the repaired check is carried in the implementing pack |

An evidence check is bitten before the brief that depends on it launches, except for the deferred assertions named below.
A command the coordinator writes from plan text for a pack's `## Checks` is an evidence check even when the plan quotes it; a declared check is not an evidence check, and [references/toolchain.md](toolchain.md) owns its preflight.
The coordinator runs the evidence check against at least one known-good case, which it passes, and at least one planted defect, which it fails.
Plant at least one defect per evidence check and one per carried finding the check claims to close.
When no known-good candidate exists yet, the coordinator either bites the check on a synthetic fixture or names the assertions that cannot run until the candidate exists.
A synthetic fixture is a scratch copy with a representative edit built from the plan's text; it stays outside the product worktree, is a scratch git clone with a commit when the check inspects commits or diffs, and is never given to a worker.
Named deferred assertions are the only exception to the pre-launch bite; the coordinator bites them at the closure proof gate, before review starts.
The coordinator records a notes line in `ledger.md` naming each check's command, the known-good outcome, and each planted defect's outcome and exit.
Evidence scripts stay under the delivery's evidence root, outside the repository.
When a worker reports a defective evidence check, the worker does not repair it; the coordinator repairs it, records the old and new check in `ledger.md`, and repeats the bite.
The next review pack carries the change, and the reviewer judges whether it weakened the check.

For an implementing/fix brief carrying effective blocking findings, require one
red/green/bite closure row per finding using `references/findings.md`. Name the
exact reviewed head for red evidence and prohibit proxy checks that test a weaker
condition than the original scenario.
