# Evidence, not control state

At the contract's delivery evidence root, create owner-only `briefs/`, `results/`,
`workers/`, `checks/`, `run.md`, and optional `events.jsonl`. Give attempts unique
human-readable filenames, for example `planning-20260921T120000Z-1.md`. On resume,
append rather than overwrite surviving attempts. Follow security before capture.

Write run.md directly. Record delivery identity, spec revision, effective nonsecret
configuration, run start/budget, and a chronological station/attempt table. Write
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
the gap in run.md or the next available remote comment and continue.

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

Emission: after the marked summary is read back, the coordinator's final
message in the host session contains the stage-analysis table and the two wall
totals. A URL may follow. The URL alone does not satisfy this. Trigger only at
verified `capstan:ready-to-deploy` or review exhaustion. No mid-station note.
The surface is that final message on Claude Code, Codex, Grok, and Oh My Pi.
No plugin, notification command, status-line API, or new marker. Workers do
not post the table. Do not add a second summary comment or post the table on
the pull request.

Same-figures rule: copy the published summary's figures. Do not recompute.
`unknown` stays `unknown`.

Gap rule: a missed host message is a telemetry gap in `run.md`. It does not
skip the GitHub summary and does not withhold ready.
