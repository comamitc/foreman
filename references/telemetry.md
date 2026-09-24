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

At terminal readiness or review exhaustion publish a marked issue summary from
`ledger.md`. Do not recompute it from the pile. The summary contains
PR URL, current head/base, observed ready-gate or exhaustion facts, one station
attempt table, two wall totals, reported usage/cost, findings addressed/refuted,
recovery history, human interventions, same-harness independence or unsafe mode
disclosures, and gaps. The attempt-table field rules are stated above. Worker-process
wall is the sum of attempt rows that have a
process start and exit. End-to-end wall is from spec admission to the ready-label
read-back, or to the review-exhausted summary publication. A bound that was not
observed is `unknown`. The supervisor-record rule above is that observation. The two totals are not substitutes for each other. A telemetry
gap in this table does not block ready-to-deploy. Include recovered
counts only when evidence supports them. Lost local data yields unknown details,
not an unrecoverable run. A failed GitHub summary publication uses normal transient
recovery; do not pretend it published. Remote progress evidence preserves budget
and rerun history across local deletion.

Emission: after the marked summary is read back, the coordinator's final message in the host session contains the stage-analysis table and the two wall totals. A URL may follow. The URL alone does not satisfy this. Trigger only at
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

This file owns the ledger and deletion. [contract.md](contract.md) owns
resolution of `evidence.delete_pile`.

`ledger.md` is the retained local record of totals and check outcomes. Always
write it, whether or not deletion is enabled. The attempt-table field rules
above are the ledger row. The switch cannot suppress `ledger.md`.

If `run.md` or `events.jsonl` exists, its required facts are already in
`ledger.md` before it may be deleted. Remote marked comments are still
published. Budget start still survives from the earliest remote activity or
summary timestamp. Loss of the pile does not reset the budget. A missing raw
file is `unknown` only when the ledger does not already contain the number.
Unreported usage is `unknown`, never zero and never estimated.

The pile is exactly `briefs/`, `results/`, `workers/`, `checks/`, `toolchain/`,
`tooling/`, and `events.jsonl` when present. It does not include `ledger.md`.
`run.md` is not pile.

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
