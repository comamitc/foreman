# Pack

One owner-only file per launch, `briefs/<brief stem>.pack.md`, written by the
coordinator. It is the candidate itself. A path list is
not a pack. Full form: seven headings in this order; a heading with nothing to
carry reads `none` plus the reason.

1. Header line: delivery, station and attempt, candidate identity (spec revision,
   plan comment URL and revision, or `BASE...HEAD` SHAs).
2. `## Acceptance criteria`: the applicable criteria quoted from the admitted spec.
3. `## Candidate`: the candidate verbatim, by station.
   - Initial planning: [planning](planning.md) ("runs the history sweep once") owns its history lines.
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
   Review and fix packs for round 2 and later also carry every open prior code-review finding as a row in that format, with its disposition and, in a review pack, the primary's proposed disposition; never implementing narratives.
   [Finding resolution](findings.md) ("Only independently verified dispositions close obligations") and [code-review convergence](review-convergence.md) ("An operator disposition must come from the explicit invocation") own when a prior code-review finding is closed; a closed prior code-review finding is not carried.
5. `## Rules that apply`: sentences from repository instructions quoted with
   `path:line`. Never a whole file; never `CLAUDE.md`, the operating contract, or
   every caller pasted or pointed at for complete reading.
   Repository instructions include the standards file whose rule table names
   each rule's enforcer. Quote each of its rules that applies;
   [correction](modes/correction.md) ("This file owns correction") places that file.
   This is a content rule, not a reading ban; [references/harnesses/shared.md](harnesses/shared.md) ("A worker inherits its host's instructions") owns host instructions.
   Each quoted repository rule, here or on a compact `Rule:` line, carries its policy row from `ledger.md` as
   carried evidence, not a verdict; [references/telemetry.md](telemetry.md) owns the policy row.
   For code review, include the effective policy, severity/confidence
   calibration, partition rules, review ratchet, counted round and remaining
   allowance from `references/review-convergence.md`.
6. `## Checks`: exact commands with cwd and expected exit.
   Declared checks appear as the brief's invocations ([references/toolchain.md](toolchain.md) ("The brief carries the exact invocation.")), in the order [references/planning.md](planning.md) ("Mark each declared check heavy or not heavy") owns.
   A code-review pack
   also carries, under this heading, each applicable red or fault-injection
   observation that implementing recorded, marked as carried evidence (command,
   head, exit, and failure signal) and not as a command to run;
   [references/review.md](review.md) owns the judgment.
   A code-review pack also carries, under this heading, real-run evidence that passed the "Real-run evidence checklist" below, marked as carried evidence and not as a verdict.
7. `## Named files`: `path:line-range` plus its anchor and reason, the only task files the worker may open; "Citation rule" below owns the entry's form.

Citation rule: every citation of repository text in a plan or a pack names its target by a stable anchor, as [.capstan/vocabulary.md](../.capstan/vocabulary.md) ("Stable anchor") defines it: a heading's exact text or a verbatim phrase.
A `path:line` or `path:line-range` may accompany the anchor as a locating hint; when the hint and the anchor disagree, the anchor governs.
A `## Named files` entry keeps its `path:line-range`, which bounds the worker's reads, and adds the anchor of what the range covers, written `path:line-range ("anchor") — reason`.
For that entry, the range is a hint for locating the anchor and bounding the read, and the anchor identifies what is meant; the coordinator writes a range that contains the anchor, and a worker that does not find the anchor inside the range reports a pack gap and does not read past it.
A quoted sentence under `## Rules that apply`, or on a compact `Rule:` line, already carries its anchor as the quote.
A citation whose anchor matches its target is valid even when its line hint has moved, and a hint that disagrees with its anchor is not a finding.
A citation with no anchor, or whose anchor does not match its target, does not meet this rule.
This rule covers citations in plans and packs only; it does not change the evidence field of a read-only report, which [references/contract.md](contract.md) ("**Evidence:**") owns, the policy-row key, which [references/telemetry.md](telemetry.md) ("This file owns the policy row") owns, or citations in worker results and run reports, including the Citations item of the "Real-run evidence checklist" below.

Real-run evidence checklist: real-run evidence is evidence the coordinator itself produces by running an invocation or a launch for an acceptance criterion; worker output and declared checks are not real-run evidence.
Before writing a code-review pack that carries real-run evidence, the coordinator checks that evidence against these four items:
- Transcript: every command the run executed, with its exit status. A command the harness log does not show counts as missing.
- State: the before and after state of each repository or tree the run reads or changes, where its criterion depends on it being unchanged.
- Citations: every claim the run's report must cite carries a `path:line`, or a URL plus its commit SHA, and every `path:line` in the report matches the cited file, as the coordinator confirmed by opening that file.
- Coverage: where the output has a coverage section, every item the run inventoried has exactly one disposition there, and a partial read is labeled partial, never listed as read in full.

An item that does not apply to the run is marked not applicable in the carried evidence, with its reason, such as Coverage for a run with no coverage section, or Citations for a launch that writes no report.
A failed item is completed or corrected before the pack is written; when only the run can supply the missing record, such as a missing command or after state, the coordinator repeats the run and checks the new evidence.
The coordinator records a notes line in `ledger.md` naming each failed item, what was completed or corrected, and whether the run was repeated.
Evidence that meets every item goes into the pack unchanged, and no correction is recorded.
The checklist checks the evidence a run recorded; it does not replace the bite of an evidence check below.

Compact form, the exception for one Named files entry, one check, and no open
finding rows: nothing is written as `none`, no heading beyond Candidate appears,
and the read-station ceiling is 7 (1 + 1 + 5).

```
# Pack — owner/repo#N, implementing attempt 1, candidate: plan comment URL, revision R
## Candidate
<the one plan item, verbatim>
Criterion: AC 2 — "<quoted criterion>"
Rule: `CONTRIBUTING.md:14` — "<quoted sentence>"
Check: `make test` in WORKTREE, expected exit 0
Named file: `src/cli.py:40-58` ("<anchor>") — the option parser this item edits
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
An evidence check the initial plan writes is bitten after the coordinator publishes that plan and before the plan-review brief launches, by the method below.
When that bite shows a defective check, the coordinator repairs it before plan review, records the old and new check in `ledger.md`, and repeats the bite; later packs carry the repaired check until the single correction changes it.
A check that passes that bite goes to plan review unchanged, and no repair is recorded.
The plan-review pack carries the bite outcomes and any repair as carried evidence, and the plan reviewer judges whether a repair weakened the check.
A check that the single correction changes, or that a worker reports defective, is bitten again before the brief that depends on it launches.
The coordinator runs the evidence check against at least one known-good case, which it passes, and at least one planted defect, which it fails.
Plant at least one defect per evidence check and one per carried finding the check claims to close.
When no known-good candidate exists yet, the coordinator either bites the check on a synthetic fixture or names the assertions that cannot run until the candidate exists.
A synthetic fixture is a scratch copy with a representative edit built from the plan's text; it stays outside the product worktree, is a scratch git clone with a commit when the check inspects commits or diffs, and is never given to a worker.
Named deferred assertions are the only exception to the pre-launch bite; the coordinator bites them at the closure proof gate, before review starts.
The coordinator records a notes line in `ledger.md` naming each check's command, the known-good outcome, and each planted defect's outcome and exit.
Evidence scripts stay under the delivery's evidence root, outside the repository.
When a worker reports a defective evidence check, the worker does not repair it; the coordinator repairs it, records the old and new check in `ledger.md`, and repeats the bite.
The next review pack carries the change, and the reviewer judges whether it weakened the check.

[references/findings.md](findings.md) ("## Closure proof gate") owns closure proof for the effective blocking findings an implementing or fix brief carries.
