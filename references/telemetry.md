# Evidence, not control state

At the contract's delivery evidence root, create owner-only `briefs/`, `results/`,
`workers/`, `checks/`, and `events.jsonl`. Create `events.jsonl` at run acceptance of every delivery run, single or batch, including a resume, and append each event when its trigger occurs. A resumed run appends to it. If it was lost, recreate it and record a `telemetry-gap`. A read-only invocation and init are not runs and write no `events.jsonl`. Always write `ledger.md` at
run acceptance and rewrite it at each station end, an interrupted or failed
attempt, a blocker publication, a cancellation, review exhaustion, and
ready-to-deploy, whether or not deletion is enabled. `run.md` is not a second source of
truth. Give attempts unique
human-readable filenames, for example `planning-20260921T120000Z-1.md`. On resume,
append rather than overwrite surviving attempts. Follow security before capture.

Write the ledger row directly. Record delivery
identity, spec revision,
effective nonsecret configuration with the source of `heavy_checks.max_concurrent`
and the resolved `boundary_pass` with its source,
the resolved `triage.auto_accept_recommended` with its source and the resolved `triage.pause_categories` with its source,
each ignored unknown or retired configuration field or ignored file, environment, or invocation value by name and source (file, environment, or
invocation override) apart from effective configuration and without its value,
each old name whose value was used, as deprecated, and each old name ignored because its Foreman name is present, as ignored ([contract](contract.md) ("## Compat read path")), by name and source and without its value,
budget start, the
resolved deletion switch, and
a chronological station/attempt table. Write
one row per station attempt and one row per probe attempt. At each risk tier
computation in [pre-merge.md](pre-merge.md) ("Risk tier:"), record in
`ledger.md` the tier, its basis, and the head SHA; a later computation adds a
record.

This file owns the attempt table. The attempt table has these columns, in this order:

`| Stage | Attempt | Start | End | Worker | Coord | Harness | Tokens |`

- Stage: one stage name from the [contract](contract.md) stage table ("Stage projection"), without `foreman:`. Both planning rows of the stage table write `planning`, the name in `foreman:planning`; the Attempt cell tells them apart. Nothing else goes in this cell.
- Attempt: the qualifier and nothing else. `N` for station attempt N; `rR · N` for review and fix round R, attempt N; `probe KIND` for a launch probe, where KIND is `read` or `write`, followed by ` N` when N > 1 and ` fail` when it failed, in the row of the stage at which the probe ran; `correction` for the single planning correction; in pre-merge, `N`, `CI wait N`, and `repair N`. N and R count from 1.
- Start, End: `HH:MM:SS` UTC. The coordinator's observed attempt start and end (station-start/worker-start, station-end/worker-end). When the coordinator did not observe one, that cell is the supervisor record's process start or exit when a worker ran, else `unknown`. Read the time cells in table order, row by row, Start before End, with the Total row last. The current date starts as the date line's date. A known cell whose UTC date differs from the current date is written `YYYY-MM-DD HH:MM:SS`, and its date becomes the current date. An `unknown` cell leaves the current date unchanged. Reconstruct each time cell as a UTC instant: its own date when written, else the current date at that cell, with its time, as `YYYY-MM-DDTHH:MM:SSZ`. An `unknown` cell has no instant. Coord and End-to-end use these instants. A ledger written before this table shape keeps its `YYYY-MM-DDTHH:MM:SSZ` time cells; each is its own instant, and the ledger is not rewritten.
- Worker: the row's Worker wall: process exit minus process start from the supervisor record. `—` when the row has no worker process. `unknown` only when that record is gone.
- Coord: the row's Coordinator wall: when the coordinator observed both Start and End, End minus Start minus the row's worker duration. For this calculation, a row with no worker process uses zero worker duration; its Worker cell still shows `—`. `not timed` when the coordinator did not observe both bounds, even when Worker is `unknown`. `unknown` when the coordinator observed both bounds and Worker is `unknown`.
- Duration format, for every wall cell and wall total: `45s` below one minute, `2m18s` below one hour, `1h08m26s` otherwise. Use whole seconds. Every unit after the first has two digits.
- Harness: the harness name and model, for example `claude opus-5-5` or `codex gpt-6.1-sol`, with the leading `claude-` dropped from a Claude model ID. `coordinator` for a row with no worker.
- Tokens: one integer with thousands separators, counted once by the rule below, including cached reads. `—` for a row with no worker. `unknown` for a worker row whose usage was not reported, never zero or an estimate.

The last row is the Total row: `| **Total** | — | START | END | WORKER | COORD | — | TOKENS |`.
- Start is spec admission. End is the ready-label read-back, or the review-exhaustion decision. Until the ready-label read-back or the review-exhaustion decision, End is the latest End cell in the table that is not `unknown`, else `unknown`.
- Worker is the Worker-process wall: the sum of the Worker cells. Coord is the sum of the Coord cells. Tokens is one total across all harnesses.
- Each total is `unknown` when any cell it sums is `unknown`. A `—` or `not timed` cell adds zero.

One line follows the table, the date line: `Date YYYY-MM-DD UTC · End-to-end DURATION`. The date is the UTC date of the first time cell, in the reading order above, that is not `unknown`; it is `unknown` when none is. DURATION is the End-to-end wall: from spec admission to the ready-label read-back, before summary publication, or to the review-exhaustion decision; before either, to the Total row's End. A bound that was not observed makes it `unknown`. End-to-end also covers time between rows, so it can exceed Worker plus Coord. The Worker total and End-to-end are not substitutes for each other.

Every write of `ledger.md` ends the attempt table with the Total row and the date line, so a run that stops at any point, or whose host dies after its last ledger write, leaves both. A resumed run appends its rows and rewrites the Total row over every row. A ledger recreated after local loss writes the Total row and the date line, with `unknown` cells for missing facts.

Pre-merge rows separate CI wait from repair. Each `CI wait N` row and each `repair N` row is written in addition to the pre-merge `N` row. The `N` row spans the station attempt and has no worker process, so its Worker cell is `—`. Its Coord is End minus Start, minus the span (End minus Start) of each `CI wait` and `repair` row inside it. It is `unknown` when any of those rows lacks a bound. A `CI wait N` row runs from the first observation with a required check pending to the settled `check` event. It has no worker. A `repair N` row is the in-diff repair worker ([pre-merge](pre-merge.md)).

Also record safety mode, process start, exit, and session, checks and exit
results, head before/after, finding census, recovery hypotheses, label changes,
and evidence paths/remote URLs. [harnesses/shared.md](harnesses/shared.md) owns the probe. A field the harness did not report is `unknown`,
not zero and not an estimate. Coordinator-only stages with no process
timer, such as triage and ready, stay in the table. Print observed timestamps, such as
spec admission and the ready label. A supervisor record that still has the start and the exit is observed. If the exit notice lacks those clocks, read that record, then write the ledger row. Publishing `unknown` for process start, process exit, or Worker wall while that record still has them is a telemetry gap, not a permitted `unknown`. `unknown` remains only when that record is gone, and the summary names the gap. Do not name a host path. Avoid adding both session totals and their
constituent turn totals.

Tokens counts each reported token once:
- Claude: `input_tokens + cache_creation_input_tokens + cache_read_input_tokens + output_tokens` from the worker JSON `usage`.
- Codex: `input_tokens + output_tokens` from the `turn.completed.usage` fields. `cached_input_tokens` is inside `input_tokens` and `reasoning_output_tokens` is inside `output_tokens`; do not add them again.
- Grok and Oh My Pi: the harness's own reported total when it reports one; otherwise the sum of the fields whose documented meanings do not overlap. When the overlap cannot be settled, the cell is `unknown`.

Tokens is a count-once volume and readability measure of the usage workers reported. It is not spend, not a cache-efficiency score, and not proof of equivalent resource use across models or harnesses. When coordinator usage is unavailable, do not describe the Total as complete end-to-end usage. A low cache-read share alone is not evidence of cache invalidation.

The ledger notes keep the raw usage. In `ledger.md`, after the date line, write one notes line per attempt, in table order. The Total row has none. STAGE and ATTEMPT are the row's cells.
- A row with a worker: `- STAGE ATTEMPT: HARNESS VERSION MODEL EFFORT; field=value ...`. MODEL is the full model ID. A version, model, or effort the harness did not report is `unknown`.
- A row with no worker: `- STAGE ATTEMPT: coordinator`. It carries no version, model, effort, or usage.

After the attempt lines, write one line for each heavy check that ran unlocked, after its first observed unlocked run: ``- unlocked CHECK: ran unlocked because `flock` is not on `PATH` ``. CHECK is the declared invocation. An observed run is that check's entry under a captured result's `## Checks`, or the coordinator's own run. A heavy check the stop skipped writes no line. These lines are not attempt lines.

Fields use the harness's own names and values, as reported. List only reported fields; when the harness reported no usage, write `usage=unknown`. A field is listed once. On a failed attempt, `exit=N error=REDACTED;` follows EFFORT, with the exit status and the redacted raw error. The summary and the final message do not copy the notes. The one exception is the verbatim `ledger.md` block the end-of-run order publishes in the summary; the summary's ordinary narrative still does not copy them. Foreman captures no cost. Record no spent, reported, or estimated cost figure or price in `ledger.md`, the summary, a host status line, or a benchmark or improvement comparison, even when the harness reports one.

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
| check | each declared check outcome, coordinator-run or worker-reported |
| finding-census | plan/code review verdict; policy; round; blocking/advisory partition at revision/SHAs |
| recovery | failure, semantic progress comparison, hypothesis, next attempt |
| label-change | observed before/after labels, including projection repair |
| blocker / unblock | typed capability or review exhaustion, and observed resume condition |
| telemetry-gap | missing, malformed, or failed evidence capture |
| run-end | ready, blocked handoff, cancellation, or decomposition end |
| tool-call | a coordinator worker process, check command, or wait ends; a worker tool call completes |

Every event line is one JSON object with these fields: `time`, `kind`, `delivery`, `station`, and `attempt`, then the added fields of its kind. `time` is UTC `YYYY-MM-DDTHH:MM:SS[.ffffff]Z`; `delivery` is `owner/repo#N`; `station` is the stage name as in the attempt table; `attempt` is the Attempt cell, or `—` outside an attempt. The added fields:

- run-start, run-resume: `spec_revision`, `budget_start`.
- station-start, station-end: `time` is the station's UTC start or end; station-end adds `outcome`.
- worker-start, worker-end: `harness`, `model`, `process_start`, `process_exit`, `exit`.
- check: `command`, `head`, `start`, `end`, `duration_s`, `exit`, and `source`: `coordinator` for a check the coordinator ran, `worker` for a check a worker reports.
- finding-census: `verdict`, `round`, `blocking`, `advisory`, `head`.
- recovery: `failure`, `hypothesis`, `next`.
- label-change: `before`, `after`.
- blocker, unblock: `reason`, `condition`.
- telemetry-gap: `what`, `error` (redacted).
- run-end: `outcome`.
- tool-call: `source`, `tool`, `start`, `end`, `duration_s`. A coordinator call has `source` `coordinator`, `tool` `worker`, `check`, or `wait`, `command` with its command or a label, and `exit` with its exit status or `outcome` with its wait outcome: `settled`, `exited`, `timeout`, or `interrupted`. A worker call has `source` `worker`, `tool` with the tool name, `id`, and `error` with the Claude `is_error` or `exit` with the Codex `exit_code`.

A value that was not observed is `"unknown"`, never zero or an estimate. `duration_s` is `end` minus `start` in seconds.

The coordinator writes each of its own lines itself, escaping every string per JSON, as one append-mode write of a whole line. It never rewrites the file, and it never concatenates unescaped worker text into a line. Every declared check, coordinator-run or worker-reported, gets a `check` event. A worker-reported check's `command`, `head`, and `exit` come from the result's `## Checks`; a field the worker omitted is `unknown`. Its `start`, `end`, and `duration_s` come from the matching worker `tool-call` line in the capture when the harness records one, and are otherwise `"unknown"`. A worker `tool-call` line carries no command, so it matches only through its `id`: the coordinator takes each shell tool call in the capture's `stream` whose input command is the reported command, either exactly or followed by ` > `, a log path, and ` 2>&1`, the check-log redirect that [templates/brief.md](../templates/brief.md) ("followed by ` > LOG 2>&1`") owns; when the result gives that run's log path, only a call that redirects to that path matches. When exactly one call matches, the coordinator takes the `tool-call` line with that call's `id`; when no call matches, more than one does, or no line has that `id`, the three fields are `"unknown"`. Each worker process, check command, and wait the coordinator runs (a worker wait, a silent-check wait, or a CI wait) gets a coordinator `tool-call` event when it ends. An accepted same-head check record ([harnesses/shared.md](harnesses/shared.md) ("The coordinator accepts a same-head check record")) gets its `check` event with `source` `worker`, and the coordinator writes no coordinator `check` event and no `tool-call` event for that check; a check the coordinator runs instead gets both, as above.

The run script that [harnesses/shared.md](harnesses/shared.md) ("A run script that `scripts/launch.sh write` writes takes `--capture DIR`") describes appends each worker `tool-call` line when that call completes, during the worker run. A worker call's `start` and `end` are the arrival times of its start and end records in the capture's stream. The coordinator does not read those lines during the run. At worker-end, a `telemetry-error` file in the capture becomes one `telemetry-gap` that cites it. A Grok or Oh My Pi worker's tool-call durations are `unknown`, recorded as one `telemetry-gap` per attempt.

No validator, parser, helper, or event is needed to choose a station. A failed append or a malformed event is
a telemetry gap under the gap rule below. A remote comment may still publish the
gap. Continue.

[end-of-run.md](end-of-run.md) ("this end-of-run order:") owns the end-of-run order.

Host status line rule: while a run is active, the coordinator posts one line in
the invoking host session when an event-table event occurs. Shape:
`foreman OWNER/REPO#N · STATION · EVENT: FACT`, for example
`foreman owner/repo#N · review · finding-census round 1: 2 blocking, 3 advisory → fix`.
FACT is one observed value from that event's evidence. A value not observed is
`unknown`. No estimates. A blocker line or a typed human decision line ends with
what the operator must do. This rule (#134) narrows #34 decision 3. A `tool-call` event posts no host status line.

Supervision observations follow the same rule: a running worker, a silent-check
wait, and the pre-merge CI wait. An observation posts a line only when it
changes something the line reports. For a worker, that is a new worktree head,
a new commit, or the result file appearing. The line gives elapsed time,
worktree head, new commits since the last line, and whether the result file
exists, for example
`foreman owner/repo#N · implementing · observation: 19m elapsed, head 1a2b3c4, 1 new commit, result absent`.
For a silent-check or CI wait, a snapshot is an observation while the silent
check still runs or a required CI check is still pending. The first snapshot
and each changed check state post an observation line with elapsed time, the
head, and the observed states. The settled outcome is the `check` event: the
silent check exits, or no required CI check is pending. It posts the `check`
line only, not an observation line. A change that is itself an event-table
event posts that event's line only. An unchanged observation posts nothing.
Lines come from observations the coordinator already makes, not from a new
timer. This rule adds no Foreman number or timeout. Workers do
not post status lines.

Same-figures rule: copy the published summary's figures. Do not recompute.
`unknown` stays `unknown`.

Gap rule: a failed event append, a malformed event, a missed status line, and a
missed host message are each a `telemetry-gap`. Record it in `ledger.md` before
the end-of-run order; after that, per its event cutoff. None of these gaps, nor
a gap in the attempt table, blocks a station or a label projection, skips the
GitHub summary, or withholds ready-to-deploy.

## Earlier deliveries and recurrence

This section owns earlier deliveries, their mistake and friction kinds, classes, the recurrence comparison, and the `Recurrence:` line.

Earlier deliveries are this repository's issues whose body carries the marked `spec`, `<!-- foreman:spec owner/repo#N -->` or `<!-- capstan:spec owner/repo#N -->`. List open and closed issues with `gh`, every page, and keep those whose body contains the exact spec marker; do not rely on search to find the marker. Each earlier delivery is read in two kinds:

- Mistakes: actionable findings in marked `plan-review` comments and marked `review` censuses, fix rounds in the attempt table, reverts of a delivery's commits on the integration base, and PR review comments from trusted authors under [security](security.md).
- Friction: (1) pack gaps naming the same file or fact a worker could not reach; (2) repeated permission denials for the same command; (3) read stations hitting their operation ceiling; (4) recovery attempts; (5) evidence checks reported defective. Read them from the `ledger.md` each marked summary publishes verbatim, the local `ledger.md` when its evidence root survives, and the marked station artifacts.

A class is a group of occurrences of one kind that name the same defect. Finding categories are free text: group findings by the defect class they name, whatever the wording; exact category matching is not required. A class counts once it occurred in two or more deliveries, and it cites every occurrence by issue, census, or ledger URL. A source an earlier delivery does not retain is a named limitation, not zero.

The recurrence comparison is in [end-of-run.md](end-of-run.md) ("Recurrence comparison.").

## Ledger, pile, and deletion

This file owns the ledger, deletion, retention, and provenance. [contract.md](contract.md) owns
resolution of `evidence.delete_pile` and owns `evidence.retain_replay`.

`ledger.md` is the retained local record of totals and check outcomes. No switch
suppresses it. The attempt-table field rules above are the ledger row.

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

This file owns the policy row. A policy row is a ledger row in `ledger.md` for
each repository-instruction sentence quoted under `## Rules that apply`, or on a
compact `Rule:` line, in any pack of the delivery. The row is keyed by the
quoted `path:line` at the resolved base SHA. The row states applicability,
`applies` or `not-applicable` with a reason; how the rule was satisfied; the
evidence command, artifact, or review-census entry and the head it applies to;
and `verified`, `unresolved`, or `not-applicable`. Foreman's own policy text in
a pack gets no row. A rule is mandatory when its quoted sentence contains
`must`, `must not`, `shall`, `required`, `never`, `do not`, or `don't`, case-insensitive, as whole words.
The lifecycle paragraph that follows applies to policy rows; for a policy row,
planning also maps applicability.

Planning maps intended checks. Implementation records observed evidence. Review
independently assesses required claims. A planned check is not a passed check.
A changed spec or a changed head invalidates the affected claims. Contradictory
evidence stays `unresolved`. Process exit and result headings cannot certify
correctness.

A structured export is not station-selection authority. This rule is
coordinator-enforced Markdown procedure. It is not server-enforced attestation.
Do not add a schema server or an unsupported security guarantee.

Provenance is part of `ledger.md`. It records revision or digest, nonsecret
configuration, spec revision, initial target SHA, pack identities, harness
version, and reported model identity. A missing harness version or reported
model identity stays `unknown`. No switch suppresses provenance. Delivery
identity, run identity, and attempt identity stay distinct. Retention does not
change branch identity. Retention does not change pull-request identity. The
ledger records the resolved `evidence.retain_replay`.

If `run.md` or `events.jsonl` exists, its required facts are already in
`ledger.md` before it may be deleted. Remote marked comments are still
published. Remote progress evidence preserves rerun history across local
deletion. [contract.md](contract.md) ("Loss of local telemetry does not reset
it.") owns the run budget. A missing raw file is `unknown` only when the ledger
does not already contain the number.

The pile is exactly `briefs/`, `results/`, `workers/`, `checks/`, `toolchain/`,
`tooling/`, and `events.jsonl`. It does not include `ledger.md`.
`run.md` is not pile.

A selected bundle is not pile only when the resolved `evidence.retain_replay`
is `true`. When `evidence.retain_replay` is `false`, pile deletion is
unchanged. `evidence.delete_pile: false` does not mark a run replayable.

[modes/improvement.md](modes/improvement.md) ("This file owns the improvement invocation") owns replay selection and consumption, the improvement invocation, review corrections, the no-new-violations guard, and the comment rule. Trigger: the resolved `evidence.retain_replay` is `true`, an improvement invocation consumes replay inputs, or the admitted issue or the text invocation states an improvement invocation.

Do not add a skill or service. Do not add a path for the bundle.

No mid-run deletion. At ready-to-deploy, after the ready-label read-back still
holds, after `ledger.md` is written and read back, and after no worker from
this run is active, and before the ledger digest, delete the named pile paths
only when the resolved switch is `true` and every required ledger field is
present. A successful read-back is not completeness. A missing required field
keeps the pile and the worktree, and the gap is recorded, even when the switch
is `true`. When the switch is `false`, the pile stays and the ledger says
deletion was skipped. Name each deleted path in `ledger.md` and read it back
before the digest. Do not recurse over the evidence root,
`$HOME/.local/state/foreman`, `$HOME/.local/state/capstan`, or any other issue directory. If the ready label
was removed because the live gate no longer holds, do not delete.

The same step may remove only `.worktrees/foreman+N`, or `.worktrees/capstan+N` under [contract](contract.md) ("## Compat read path"), created by this run, and
only when the switch is `true`, the ledger is complete, and the pushed head
equals the ledger head. It does not remove a worktree this run did not create,
and it does not remove the shared checkout. When the switch is `false` or the
ledger is incomplete, the worktree stays.

Before ready-to-deploy, the pile and the worktree stay while a worker is active
or while the attempt's ledger row is unwritten. A manual cleanup before that
point names one verified run directory. Shipping this text does not delete
existing evidence directories.
