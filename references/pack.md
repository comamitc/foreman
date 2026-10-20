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
     A code-review pack for round 2 and later instead carries the saved `git diff <preceding reviewed head>..<HEAD>` output, the repair delta, verbatim under its exact command line with both SHAs written out, and does not carry the cumulative `git diff BASE...HEAD`.
     The preceding reviewed head is the head SHA the previous code-review round's census records as reviewed; the coordinator reads it there.
     When the preceding reviewed head is not an ancestor of HEAD (`git merge-base --is-ancestor <preceding reviewed head> <HEAD>` exits nonzero), or the base SHA changed since the preceding reviewed head, the pack carries the saved cumulative `git diff BASE...HEAD` instead, as round 1 does.
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
   A planning pack whose admitted criteria change the text of a procedure file, as [CONTRIBUTING.md](../CONTRIBUTING.md) ("**Section contradiction.**") defines one, also names, in that form, each other file at the fetched base that states a rule on a behavior those criteria change, with a range that holds that rule; the reason names the behavior.
   A single-correction pack names again the entries of this kind that the initial planning pack named, and also each such file for a behavior that the proposed correction of an open finding changes; [planning](planning.md) ("In the single correction pass") owns the rest of that pack, and the gap table row "single correction" below owns a gap the correction reports.
   The coordinator finds those files with `git` only: for each changed behavior it runs `git grep -n -i -F -e <term> [-e <term> ...] <fetched base SHA>` with no pathspec, so the search reads every tracked file at that SHA, over the terms that the criteria, or for a single-correction pack the finding, use for that behavior; it opens each match at the fetched base and keeps each file whose matched text states a rule on that behavior.
   When one file states rules on that behavior in places one range cannot hold, the pack names one entry per place, each with its own anchor; [references/harnesses/shared.md](harnesses/shared.md) ("Named files entries plus") owns the read-station ceiling.
   A code-review pack for round 2 and later names under `## Named files`, for each prior code-review finding row it carries, the file range at HEAD that holds that row's location, in the entry form "Citation rule" below owns; the anchor is a verbatim phrase at that location at HEAD, and the reason names the row's ID.
   It also names, in that form, each further range at HEAD that the row's original failure scenario and evidence reach, so the row's scenario and acceptance condition can be checked inside named ranges.
   When a row's location no longer exists at HEAD, the row says so, the pack names no range for that location, and it still names the row's further ranges, including the range at HEAD, if any, that holds the code that replaced it.

Citation rule: every citation of repository text in a plan or a pack names its target by a stable anchor, as [.capstan/vocabulary.md](../.capstan/vocabulary.md) ("Stable anchor") defines it: a heading's exact text or a verbatim phrase.
A `path:line` or `path:line-range` may accompany the anchor as a locating hint; when the hint and the anchor disagree, the anchor governs.
A `## Named files` entry keeps its `path:line-range`, which bounds the worker's reads, and adds the anchor of what the range covers, written `path:line-range ("anchor") — reason`.
For that entry, the range is a hint for locating the anchor and bounding the read, and the anchor identifies what is meant; the coordinator writes a range that contains the anchor, and a worker that does not find the anchor inside the range reports a pack gap and does not read past it.
A quoted sentence under `## Rules that apply`, or on a compact `Rule:` line, already carries its anchor as the quote.
A citation whose anchor matches its target is valid even when its line hint has moved, and a hint that disagrees with its anchor is not a finding.
A citation with no anchor, or whose anchor does not match its target, does not meet this rule.
This rule covers citations in plans and packs, and each quoted anchor that follows an owner link in the repository's tracked Markdown; it does not change the evidence field of a read-only report, which [references/contract.md](contract.md) ("**Evidence:**") owns, the policy-row key, which [references/telemetry.md](telemetry.md) ("This file owns the policy row") owns, or citations in worker results and run reports, including the Citations item of the "Real-run evidence checklist" below.
Citation check: `scripts/launch.sh cite` checks this rule in the repository's tracked Markdown and in plans, and `scripts/launch.sh pack` checks it for `## Named files` entries and `Named file:` lines, as "Pack check:" below states; review stays the enforcer of whether an anchor states the rule it is cited for, which [CONTRIBUTING.md](../CONTRIBUTING.md) ("**Misattributed owner.**") owns, and [references/harnesses/shared.md](harnesses/shared.md) ("The coordinator runs the citation check") owns when the plan check runs.
An anchor occurs in its target when, after each run of whitespace in both is collapsed to one space, the anchor is part of the target's text; an anchor shortened with an ellipsis does not occur.
In repository Markdown, the check reads each owner link that a parenthesized quoted anchor follows in the same sentence, within 60 characters holding no other link, bracket, or parenthesis, where a `.`, `!`, or `?` directly followed by whitespace ends a sentence; one parenthesis may hold several quoted anchors joined by `and` or a comma, it closes at the first `")`, so an anchor may hold `(` and `)`; the link's path resolves from the citing file's directory, a link whose path starts with `http` or `#` is not read, and a link whose file the tree does not hold fails, with an error that names the anchor.
In a plan, the check reads only lines outside fenced blocks, so product text the plan plans or quotes goes inside a fence; a plan names an anchor that it adds, and that the base does not hold yet, by its backticked path and a bare quote, which is not a citation.
Outside fences, a citation of a repository file is a `path:line` or `path:line-range` whose path, from the repository root, is a file in the tree at the plan's base; a Markdown link whose path is such a file once leading `./` and `../` are dropped; or a backticked path that a parenthesized quoted anchor, `(step N)`, or `(item N)` directly follows.
A `path:line` takes the first quoted anchor, parenthesized or bare, that follows it within 60 characters holding no bracket, parenthesis, backtick, or `|`, and a link takes the first parenthesized quoted anchor within the same span; the check reads on after that anchor, so text inside an anchor is never read as a citation; a citation with no anchor, with a step or item number in place of an anchor, or with an anchor that does not occur in its target fails.
A backticked path with no line hint and no parenthesis directly after it, a link to a URL, and a `path:line` with no quoted anchor whose path is no file in the tree are not citations, so a plan names a whole file by its backticked path, and a timestamp cites nothing, as "Pack check:" below states; a backticked path or `path:line` that a quoted anchor follows, whose path is no file in the tree and holds no `/`, resolves to the one file in the tree with that name, and when several files have that name the check fails and the fix is the path from the repository root.
Pack check: every file that a `## Rules that apply` quote or a compact `Rule:` line cites is also named by a `## Named files` entry or a compact `Named file:` line in the form the Citation rule above owns, so the worker can open the quoted line.
Each `## Named files` entry and `Named file:` line also carries a parenthesized quoted anchor directly after its backticked path, and when that path is a file in the station's worktree, the anchor occurs, as "Citation check:" above defines it, inside the entry's line range, which the Citation rule above has the coordinator write, or anywhere in the file when the entry has no range; a path that is no file in the worktree, such as an evidence-root path or an absolute path outside it, is checked for its anchor only.
In a full pack, the quotes are the lines under the last line that starts `## Rules that apply`, up to the next line after it that starts `## Checks` or `## Named files`, and the entries are the lines under the last line that starts `## Named files`, when that line comes after it, up to the next line that starts `## `.
The candidate and the open findings come before those headings, so a heading or line they carry, fenced or not, is not pack metadata.
A quote line cites the backticked path that opens it, after any list or blockquote marker; a line that opens with no backticked path cites each `path:line` or `path:line-range` on it; an entry names the backticked path that opens it; a path holds a `/` or a `.`, or ends in a line hint.
On a line that opens with no backticked path, a `path:line` starts the line or follows a space, `(`, or backtick, its path holds a letter, and its line hint is followed by no `:`, letter, or digit, so a timestamp such as `2026-10-20T15:12:49Z` or `15:12` cites nothing.
A compact pack is one whose last non-blank line starts `Criterion:`, `Rule:`, `Check:`, or `Named file:`; the lines read are the closing run of such lines and blank lines, where a `Rule:` line cites the path after `Rule:`, backticked or not, and a `Named file:` line names the backticked path after `Named file:`.
A cited path and a named path are compared without a `:line` or `:line-range` hint, a leading `./`, or a leading worktree path.
`scripts/launch.sh pack` checks this; [references/harnesses/shared.md](harnesses/shared.md) ("The coordinator runs the pack check") owns when it runs.

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

Compact form, the exception for one task Named files entry, one check, and no open finding rows: nothing is written as `none`, no heading beyond Candidate appears, each file a `Rule:` line quotes gets its own `Named file:` line as "Pack check:" above requires, and the read-station ceiling is the number of `Named file:` lines + 1 + 5 (8 for the example below).

```
# Pack — owner/repo#N, implementing attempt 1, candidate: plan comment URL, revision R
## Candidate
<the one plan item, verbatim>
Criterion: AC 2 — "<quoted criterion>"
Rule: `CONTRIBUTING.md:14` — "<quoted sentence>"
Check: `make test` in WORKTREE, expected exit 0
Named file: `src/cli.py:40-58` ("<anchor>") — the option parser this item edits
Named file: `CONTRIBUTING.md:1-14` ("<quoted sentence>") — the rule the Rule: line quotes
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
When an evidence check claims to preserve an inventory or a set of cases, the bite plants, for each item, a defect that removes or changes only that item, and the check must fail on each such plant.
A check claims this when its group's named planted defect, the plan item it verifies, or the criterion it is derived from names items to keep, such as rows, sentences, duties, entries, or cases.
A per-item plant deletes that one item, or rewrites only its required behavior, and keeps every other item and every phrase the check matches outside that item; every item is planted, with no sample.
Per-item plants are planted defects, so this paragraph's known-good case, synthetic fixture, named deferred assertions, and `ledger.md` notes line apply to each one.
A check that passes on one of these plants is a defective evidence check.
A check group whose planned assertion requires text or behavior that is absent at the resolved base is also run at that base as part of its bite, whatever its gate label, and must fail there; the base run counts as a planted defect for this paragraph's `ledger.md` notes line.
A check that the coordinator changes after the plan states it, by a bite repair, a single-correction change, a worker-reported defect, or a fix-round change, is bitten again against every planted defect and every base case its earlier version failed, and must fail each one.
A check that passes one of these cases is a defective evidence check.
When no known-good candidate exists yet, the coordinator either bites the check on a synthetic fixture or names the assertions that cannot run until the candidate exists.
A synthetic fixture is a scratch copy with a representative edit built from the plan's text; it stays outside the product worktree, is a scratch git clone with a commit when the check inspects commits or diffs, and is never given to a worker.
Named deferred assertions are the only exception to the pre-launch bite; the coordinator bites them at the closure proof gate, before review starts.
The coordinator records a notes line in `ledger.md` naming each check's command, the known-good outcome, and each planted defect's outcome and exit.
Evidence scripts stay under the delivery's evidence root, outside the repository.
When a worker reports a defective evidence check, the worker does not repair it; the coordinator repairs it, records the old and new check in `ledger.md`, and repeats the bite.
The next review pack carries the change, and the reviewer judges whether it weakened the check.

[references/findings.md](findings.md) ("## Closure proof gate") owns closure proof for the effective blocking findings an implementing or fix brief carries.
