# Evidence, not control state

At the contract's delivery evidence root, create owner-only `briefs/`, `results/`,
`workers/`, `checks/`, `run.md`, and optional `events.jsonl`. Always write
`ledger.md` at run acceptance and update it at each station end, whether or not
deletion is enabled. `toolchain/` and `tooling/` are pile when present; do not
treat either directory as a second record. Give attempts unique
human-readable filenames, for example `planning-20260921T120000Z-1.md`. On resume,
append rather than overwrite surviving attempts. Follow security before capture.

Write the same facts in `ledger.md` first. `ledger.md` is the retained record.
`run.md` is not a second source of truth. Write run.md directly. Record delivery
identity, spec revision, effective nonsecret configuration, run start/budget, and
a chronological station/attempt table. Write
one row per station attempt. The columns are stage, start UTC, end UTC, wall time,
role, harness, and the usage fields that harness reported. Also record harness
version, model, effort, safety mode, process exit/session, checks and exit
results, head before/after, finding census, recovery hypotheses, label changes,
and evidence paths/remote URLs. Say `unknown` when not reported; never estimate
or use zero for missing usage. A field the harness did not report is `unknown`,
not zero and not an estimate. Record Grok `total_cost_usd` when present. Record
Codex `turn.completed` usage as its token fields. Probe `codex-cli 0.153.4`:
`exec --help` has no cost flag. Live `--json` turn
`01a0caf9-a2b4-7ce3-aabc-1603e76df0a5` has no dollar field in
`turn.completed.usage`. The matching session rollout has event types
`token_count` and `token_usage_record` and no dollar cost key. Codex cost
stays `unknown`. A newer CLI that later reports a dollar field in
`turn.completed` or in that session rollout has that field copied as
`reported`. Coordinator-only stages with no process
timer, such as triage and ready, stay in the table. Their wall is `not timed`
unless a start and an end were both observed. Print observed timestamps, such as
spec admission and the ready label. Avoid adding both session totals and their
constituent turn totals.

For planning, record the initial plan, single review, correction launch/outcome,
and full finding handoff into implementing. Record any operator-authorized reopening
with its changed scope/architecture, not a reset caused by technical feedback.
For implementing/fix attempts carrying effective blocking findings, record each closure
gate row's reviewed head, red/green commands and outcomes, bite method, coordinator
verification, and any proxy/incomplete reason that kept the station open.

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

At terminal readiness or review exhaustion publish a marked issue summary containing
PR URL, current head/base, observed ready-gate or exhaustion facts, one station
attempt table, two wall totals, reported usage/cost, findings addressed/refuted,
recovery history, human interventions, same-harness independence or unsafe mode
disclosures, and gaps. The table has one row per station attempt. The columns are
stage, start UTC, end UTC, wall time, role, harness, and the usage fields that
harness reported. Say `unknown` when not reported; never estimate or use zero for
missing usage. A field the harness did not report is `unknown`, not zero and not
an estimate. Record Grok `total_cost_usd` when present. Record Codex
`turn.completed` usage as its token fields. Probe `codex-cli 0.153.4`:
`exec --help` has no cost flag. Live `--json` turn
`01a0caf9-a2b4-7ce3-aabc-1603e76df0a5` has no dollar field in
`turn.completed.usage`. The matching session rollout has event types
`token_count` and `token_usage_record` and no dollar cost key. Codex cost
stays `unknown`. A newer CLI that later reports a dollar field in
`turn.completed` or in that session rollout has that field copied as
`reported`. Keep coordinator-only stages with no process timer,
such as triage and ready, in the table. Their wall is `not timed` unless a start
and an end were both observed. Print observed timestamps, such as spec admission
and the ready label. Worker-process wall is the sum of attempt rows that have a
process start and exit. End-to-end wall is from spec admission to the ready-label
read-back, or to the review-exhausted summary publication. A bound that was not
observed is `unknown`. The two totals are not substitutes for each other. Sum
token fields only within one harness and one field. Do not add cache reads again
into a single mixed total. Do not add reasoning tokens again on top of output
when the harness already counts them inside output. Name the summed fields. A
telemetry gap in this table does not block ready-to-deploy. Include recovered
counts only when evidence supports them. Lost local data yields unknown details,
not an unrecoverable run. A failed GitHub summary publication uses normal transient
recovery; do not pretend it published. Remote progress evidence preserves budget
and rerun history across local deletion.

## Ledger, pile, and deletion

`ledger.md` is the retained local record of totals and check outcomes. Always
write it. Record identity, spec revision, nonsecret config, budget start, the
resolved deletion switch, and one row per attempt. Each closure-gate check
outcome is a ledger row before the next push or review: head, command, exit, and
pass or fail. A script path may be named. The script body is not the record.
`checks/fix-4-red.py` is not the record. `run.md` and `events.jsonl` are not a
second source of truth. Put required facts in the ledger before either may be
deleted. The switch cannot suppress the ledger. Remote comments still publish.
Budget start survives from the earliest remote timestamp. Unreported usage is
`unknown`, never zero and never estimated. `unknown` is the required state when
a number was never reported, or was deleted before the ledger contained it.

The pile is exactly `briefs/`, `results/`, `workers/`, `checks/`, `toolchain/`,
`tooling/`, and `events.jsonl` when present. `toolchain/` is pile. The pile does
not include `ledger.md`.

`evidence.delete_pile` is a boolean deletion switch. The default is `false`.
Precedence is invocation, then `CAPSTAN_EVIDENCE_DELETE_PILE`, then
`.capstan.json`, then the default. An invalid value is `false`. A missing value
is `false`. Record the resolved value in the ledger. There is no second flag.
The switch authorizes success-path removal of the pile and this run's worktree.
It never authorizes removal of the ledger.

No mid-run deletion. Delete the named pile paths only at ready-to-deploy, and
only when all four gates pass: the switch is `true`, ledger read-back succeeds,
the ledger is explicitly complete, and no worker from this run is active. A
successful read-back is not completeness. The ledger is explicitly complete only
when every required field is present. Required fields include identity, spec
revision, nonsecret config, budget start, the resolved deletion switch, one row
per required attempt, and each required closure-gate row (head, command, exit,
pass or fail). A missing required field is incompleteness. An absent required
attempt row or closure-gate row is a missing required field. An incomplete
ledger keeps the pile and the worktree. Name each deleted path. Do not recurse
over the evidence root or other issue directories. When the switch is `false`,
the pile stays and the ledger says deletion was skipped.

The same switch may remove only `.worktrees/capstan+N` created by this run, and
only at ready-to-deploy, and only when the ledger is explicitly complete and the
pushed head equals the ledger head. Do not remove the shared checkout. When the
switch is `false`, or the ledger is incomplete, the worktree stays. A manual
cleanup before ready-to-deploy stays the old exact-directory rule. Deletion is
not a separate stage, label, or executable.
