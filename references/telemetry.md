# Evidence, not control state

At the contract's delivery evidence root, create owner-only `briefs/`, `results/`,
`workers/`, `checks/`, and optional `events.jsonl`. Always write `ledger.md` at
run acceptance and update it at each station end, including an interrupted
attempt, whether or not deletion is enabled. `run.md` is not a second source of
truth. `toolchain/` and `tooling/` are pile when present. Give attempts unique
human-readable filenames, for example `planning-20260921T120000Z-1.md`. On resume,
append rather than overwrite surviving attempts. Follow security before capture.

Write the ledger row directly. [contract.md](contract.md) owns resolution of
`evidence.delete_pile`. Record delivery
identity, spec revision, effective nonsecret configuration, budget start, the
resolved deletion switch, and
a chronological station/attempt table. Write
one row per station attempt. The columns are stage, start UTC, end UTC, wall time,
role, harness, and the usage fields that harness reported. Also record harness
version, model, effort, safety mode, process exit/session, checks and exit
results, head before/after, finding census, recovery hypotheses, label changes,
and evidence paths/remote URLs. Say `unknown` when not reported; never estimate or use zero for missing usage. A field the harness did not report is `unknown`,
not zero and not an estimate. Coordinator-only stages with no process
timer, such as triage and ready, stay in the table. Their wall is `not timed`
unless a start and an end were both observed. Print observed timestamps, such as
spec admission and the ready label. A supervisor record that still has the start and the exit is observed. If the exit notice lacks those clocks, read that record, then write the ledger row. Publishing `unknown` for start, end, or wall while that record still has them is a telemetry gap, not a permitted `unknown`. `unknown` remains only when that record is gone, and the summary names the gap. A missing clock does not block ready-to-deploy. Do not name a host path. Do not add an executable. Avoid adding both session totals and their
constituent turn totals. Sum token fields only within one harness and one field.
Do not add cache reads again into a single mixed total. Do not add reasoning tokens
again on top of output when the harness already counts them inside output. Name the
summed fields.

For planning, record the initial plan, single review, correction launch/outcome,
and full finding handoff into implementing. Record any operator-authorized reopening
with its changed scope/architecture, not a reset caused by technical feedback.
For implementing/fix attempts carrying effective blocking findings, record each closure
gate row's reviewed head, red/green commands and outcomes, bite method, coordinator
verification, and any proxy/incomplete reason that kept the station open.
A closure-gate check outcome is a ledger row before the next review and before
publication: exact head, command, exit, and pass or fail. A proof script path
may be named. The script body is not the record.

Publish these with marked plan/review/activity artifacts for reconstruction after
local loss. Finding censuses retain origin links and separate verified closure,
unresolved/reopened, and genuinely new findings; counts alone are not progress.

Use these event kinds when their trigger occurs:

| Kind | Trigger |
| --- | --- |
| run-start / run-resume | accepted invocation or reconstructed continuation |
| station-start / station-end | station begins or completion criterion verified |
| worker-start / worker-end | each worker attempt, including corrective attempts |
| check | observed command/check outcome and applicable head |
| finding-census | plan/code review verdict; policy; round; blocking/advisory partition at revision/SHAs |
| recovery | failure, semantic progress comparison, hypothesis, next attempt |
| label-change | observed before/after labels, including projection repair |
| blocker / unblock | typed capability or review exhaustion, and observed resume condition |
| telemetry-gap | missing, malformed, or failed evidence capture |
| run-end | ready, blocked handoff, or cancellation |

Events may be Markdown paragraphs. JSONL is an optional convenience, with fields
such as time, kind, station, attempt, head, outcome, and evidence. Existing `jq -cn`
with `--arg` or another installed JSON emitter can append correctly escaped lines.
Do not concatenate unescaped worker text into JSON. No validator, parser, helper,
or event is needed to choose a station. On failed append or malformed event, note
the gap in `ledger.md`. A remote comment may still publish the gap. `run.md` is
not the record. Continue.

At terminal readiness, project the ready label and read it back before
publishing the summary. At review exhaustion, do not project
`capstan:ready-to-deploy`. Publish the marked summary after that read-back, or
after the exhaustion decision when no ready label is projected. At
terminal readiness or review exhaustion, publish a marked issue summary from
`ledger.md`. Do not recompute it from the pile. The summary contains
PR URL, current head/base, observed ready-gate or exhaustion facts, one station
attempt table, two wall totals, reported usage/cost, findings addressed/refuted,
recovery history, human interventions, same-harness independence or unsafe mode
disclosures, and gaps. The attempt-table field rules are stated above. Worker-process
wall is the sum of attempt rows that have a
process start and exit. End-to-end wall is from spec admission to the ready-label
read-back, before summary publication, or to the review-exhausted summary
publication. A bound that was not
observed is `unknown`. The supervisor-record rule above is that observation. The two totals are not substitutes for each other. A telemetry
gap in this table does not block ready-to-deploy. Include recovered
counts only when evidence supports them. Lost local data yields unknown details,
not an unrecoverable run. A failed GitHub summary publication uses normal transient
recovery; do not pretend it published. Remote progress evidence preserves budget
and rerun history across local deletion.

Emission follows the summary read-back. The coordinator's final message in the host session contains the stage-analysis table and the two wall totals. A URL may follow. The URL alone does not satisfy this. Trigger only at
verified `capstan:ready-to-deploy` or review exhaustion. No mid-station note.
The surface is that final message on Claude Code, Codex, Grok, and Oh My Pi.
No plugin, notification command, status-line API, or new marker. Workers do
not post the table. Do not add a second summary comment or post the table on
the pull request.

Same-figures rule: copy the published summary's figures. Do not recompute.
`unknown` stays `unknown`.

Gap rule: a missed host message is a telemetry gap in `ledger.md`. It does not
skip the GitHub summary and does not withhold ready.

## Ledger, pile, and deletion

This file owns the ledger, deletion, retention, and provenance. [contract.md](contract.md) owns
resolution of `evidence.delete_pile` and owns `evidence.retain_replay`.

`ledger.md` is the retained local record of totals and check outcomes. Always
write it, whether or not deletion is enabled. The attempt-table field rules
above are the ledger row. The switch cannot suppress `ledger.md`.

This file owns the acceptance ledger row. Other files name this owner. Other
files do not restate the row fields. The row is a ledger row in `ledger.md`.
Always write the row. No switch suppresses the row. Do not add a retention
flag.

The row keeps the criterion identity tied to the spec revision. The row states
`verified`, `unresolved`, or `not-applicable`. The row states the evidence
command or artifact, the applicable head, and the verifier. `not-applicable`
requires a reason. The row joins finding obligations and closure proofs. The
row does not copy the full narrative. The row does not reset review budgets.

Documentation evidence starts with `added`, `updated`, `intentionally unchanged`,
or `unverified`, then the canonical path. Missing, contradictory, or unresolved
evidence stays `unverified`. `unverified` uses row state `unresolved`. The other
three use `verified` only after the named check passes. `intentionally unchanged`
is not `not-applicable`. A result word cannot replace the row.

Planning maps intended checks. Implementation records observed evidence. Review
independently assesses required claims. A planned check is not a passed check.
A changed spec or a changed head invalidates the affected claims. Contradictory
evidence stays `unresolved`. Process exit and result headings cannot certify
correctness.

A structured export is not station-selection authority. This rule is
coordinator-enforced Markdown procedure. It is not server-enforced attestation.
Do not add an executable, a schema server, or an unsupported security
guarantee.

The fixture cases are partial satisfaction, failed check despite exit zero,
stale SHA, changed criterion, supported not-applicable, and conflicting
observations. The pull request links those records in
`comamitc/capstan-fixtures`. Do not copy those trees here.

Provenance is part of `ledger.md`. It records revision or digest, nonsecret
configuration, spec revision, initial target SHA, pack identities, harness
version, and reported model identity. A missing harness version or reported
model identity stays `unknown`. `unknown` stays `unknown`. Provenance is not
configurable off. No switch suppresses provenance. Delivery identity, run
identity, and attempt identity stay distinct. Retention does not change branch
identity. Retention does not change pull-request identity. The ledger records
the resolved `evidence.retain_replay`. [contract.md](contract.md) owns that
field.

If `run.md` or `events.jsonl` exists, its required facts are already in
`ledger.md` before it may be deleted. Remote marked comments are still
published. Budget start still survives from the earliest remote activity or
summary timestamp. Loss of the pile does not reset the budget. Resume does not
reset budgets. A missing raw file is `unknown` only when the ledger does not
already contain the number.
Unreported usage is `unknown`, never zero and never estimated.

The pile is exactly `briefs/`, `results/`, `workers/`, `checks/`, `toolchain/`,
`tooling/`, and `events.jsonl` when present. It does not include `ledger.md`.
`run.md` is not pile.

A selected bundle is not pile only when the resolved `evidence.retain_replay`
is `true`. When `evidence.retain_replay` is `false`, pile deletion is
unchanged. `evidence.delete_pile: false` does not mark a run replayable.

Replay-selection rule: a run is selected only when capture records a bundle of
admitted inputs, pack content, check bodies, setup references, and outcomes.
The bundle has no credentials and no unrestricted raw traces. Redaction removes
a credential. A bundle that still contains a credential is not selected. The
rule is not a script in `.capstan.json`. An unselected run has no replay
bundle. A missing capture is recorded in `ledger.md` and is not replayable. A
failed capture is recorded in `ledger.md` and is not replayable. Benchmark
capture is not a ready gate.

Consume a replay input only when `evidence.retain_replay` marked that input
replayable. A missing bundle, an off switch, or a failed capture is a named
limitation, not a zero. A kept pile is not a benchmark case. Compare the
baseline and the candidate on equivalent inputs. One run is not a victory.
Report acceptance, false-ready, intervention, recurrence, wall, and reported
cost. Unknown usage is not zero. Do not add incompatible token fields. Publish
the exact revisions, the command, the result, and the limitations. Do not
relabel an old evaluation as current-main proof. Prefer an executable check
and a known fault injection. Do not reward weakening verification.

On demand. No daemon, scheduler, external skill, or database. A named batch.
Evidence-backed causes. A ledger failure with no bundle is still a failure. An
empty bundle batch is not "no failures." A proposal cites run identities, the
scenario, a counterexample, a falsifiable hypothesis, and a discriminating
benchmark. Deduplicate against open issues. An issue is published only after an
explicit improvement invocation. Analysis-only stays a report. Compare baseline
and candidate with a held-out check. A weaker rubric is rejected. Workers do not
rewrite the running skill. The improvement stops at an open pull request. A
rejected or unsupported proposal does not manufacture a product change. The
fixture cases are recurring defect, duplicate proposal, unsupported hypothesis,
and benchmark regression.

A selected bundle survives pile cleanup only when
`evidence.retain_replay` is `true`. Do not add a database, parser, skill,
service, or stage. Do not add a path for the bundle.

Reconstruction after cleanup uses the retained check body and the initial
target SHA. A state the bundle does not keep is the named limitation
`unavailable-after-cleanup`. The rule does not claim that the model is
deterministic.

Missing switch and invalid switch are not replayable.
[contract.md](contract.md) owns that resolution.

The fixture cases are resumed run, unknown model or version, failed capture,
redaction, unselected run, selected replay surviving cleanup, missing switch,
and invalid switch.

No mid-run deletion. At ready-to-deploy, after the ready-label read-back still
holds, after `ledger.md` is written and read back, and after no worker from
this run is active, delete the named pile paths only when the resolved switch
is `true` and every required ledger field is present. A successful read-back
is not completeness. A missing required field keeps the pile and the worktree,
and the gap is recorded, even when the switch is `true`. When the switch is
`false`, the pile stays and the ledger says deletion was skipped. Name each
deleted path. Do not recurse over the evidence root,
`$HOME/.local/state/capstan`, or any other issue directory. If the ready label
was removed because the live gate no longer holds, do not delete.

The same step may remove only `.worktrees/capstan+N` created by this run, and
only when the switch is `true`, the ledger is complete, and the pushed head
equals the ledger head. It does not remove a worktree this run did not create,
and it does not remove the shared checkout. When the switch is `false` or the
ledger is incomplete, the worktree stays.

Before ready-to-deploy, the pile and the worktree stay while a worker is active
or while the attempt's ledger row is unwritten. A manual cleanup before that
point names one verified run directory. Shipping this text does not delete
existing evidence directories. Deletion is not a separate stage, label, or
executable.

[publication.md](publication.md) owns publication.
