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
identity, spec revision, effective nonsecret configuration, each ignored unknown
or retired configuration field by name and source (file, environment, or
invocation override) apart from effective configuration and without its value,
budget start, the
resolved deletion switch, and
a chronological station/attempt table. Write
one row per station attempt and one row per probe attempt.

This file owns the attempt table. The attempt table has these columns, in this order:

`| Stage | Attempt | Start | End | Worker | Coord | Harness | Tokens |`

- Stage: one stage name from the [contract](contract.md) stage table ("Stage projection"), without `capstan:`. Both planning rows of the stage table write `planning`, the name in `capstan:planning`; the Attempt cell tells them apart. Nothing else goes in this cell.
- Attempt: the qualifier and nothing else. `N` for station attempt N; `rR · N` for review and fix round R, attempt N; `probe KIND` for a launch probe, where KIND is `read` or `write`, followed by ` N` when N > 1 and ` fail` when it failed, in the row of the stage at which the probe ran; `correction` for the single planning correction; in pre-merge, `N`, `CI wait N`, and `repair N`. N and R count from 1.
- Start, End: `HH:MM:SS` UTC. The coordinator's observed attempt start and end (station-start/worker-start, station-end/worker-end). When the coordinator did not observe one, that cell is the supervisor record's process start or exit when a worker ran, else `unknown`. Read the time cells in table order, row by row, Start before End, with the Total row last. The current date starts as the date line's date. A known cell whose UTC date differs from the current date is written `YYYY-MM-DD HH:MM:SS`, and its date becomes the current date. An `unknown` cell leaves the current date unchanged. Reconstruct each time cell as a UTC instant: its own date when written, else the current date at that cell, with its time, as `YYYY-MM-DDTHH:MM:SSZ`. An `unknown` cell has no instant. Coord and End-to-end use these instants. A ledger written before this table shape keeps its `YYYY-MM-DDTHH:MM:SSZ` time cells; each is its own instant, and the ledger is not rewritten.
- Worker: the row's Worker wall: process exit minus process start from the supervisor record. `—` when the row has no worker process. `unknown` only when that record is gone.
- Coord: the row's Coordinator wall: when the coordinator observed both Start and End, End minus Start minus the row's worker duration. For this calculation, a row with no worker process uses zero worker duration; its Worker cell still shows `—`. `not timed` when the coordinator did not observe both bounds, even when Worker is `unknown`. `unknown` when the coordinator observed both bounds and Worker is `unknown`.
- Duration format, for every wall cell and wall total: `45s` below one minute, `2m18s` below one hour, `1h08m26s` otherwise. Use whole seconds. Every unit after the first has two digits.
- Harness: the harness name and model, for example `claude opus-5-5` or `codex gpt-6.1-sol`, with the leading `claude-` dropped from a Claude model ID. `coordinator` for a row with no worker. Harness version and effort are in the ledger notes.
- Tokens: one integer with thousands separators, counted once by the rule below, including cached reads. `—` for a row with no worker. `unknown` for a worker row whose usage was not reported, never zero or an estimate.

The last row is the Total row: `| **Total** | — | START | END | WORKER | COORD | — | TOKENS |`.
- Start is spec admission. End is the ready-label read-back, or the review-exhaustion decision.
- Worker is the Worker-process wall: the sum of the Worker cells. Coord is the sum of the Coord cells. Tokens is one total across all harnesses.
- Each total is `unknown` when any cell it sums is `unknown`. A `—` or `not timed` cell adds zero.

One line follows the table, the date line: `Date YYYY-MM-DD UTC · End-to-end DURATION`. The date is the UTC date of the first time cell, in the reading order above, that is not `unknown`; it is `unknown` when none is. DURATION is the End-to-end wall. End-to-end also covers time between rows, so it can exceed Worker plus Coord.

Pre-merge rows separate CI wait from repair. Each `CI wait N` row and each `repair N` row is written in addition to the pre-merge `N` row. The `N` row spans the station attempt and has no worker process, so its Worker cell is `—` and counts as zero. Its Coord is End minus Start, minus the span (End minus Start) of each `CI wait` and `repair` row inside it. It is `unknown` when any of those rows lacks a bound. A `CI wait N` row runs from the first observation with a required check pending to the settled `check` event. It has no worker, so its Coord is its full span. A `repair N` row is the in-diff repair worker ([pre-merge](pre-merge.md)).

Also record harness
version, model, effort, safety mode, process start, exit, and session, checks and exit
results, head before/after, finding census, recovery hypotheses, label changes,
and evidence paths/remote URLs. A failed attempt's notes line carries its exit status and redacted raw error. [harnesses/shared.md](harnesses/shared.md) owns the probe. Say `unknown` when not reported; never estimate or use zero for missing usage. A field the harness did not report is `unknown`,
not zero and not an estimate. Coordinator-only stages with no process
timer, such as triage and ready, stay in the table. Print observed timestamps, such as
spec admission and the ready label. A supervisor record that still has the start and the exit is observed. If the exit notice lacks those clocks, read that record, then write the ledger row. Publishing `unknown` for process start, process exit, or Worker wall while that record still has them is a telemetry gap, not a permitted `unknown`. `unknown` remains only when that record is gone, and the summary names the gap. A missing clock does not block ready-to-deploy. Do not name a host path. Avoid adding both session totals and their
constituent turn totals.

Tokens counts each reported token once:
- Claude: `input_tokens + cache_creation_input_tokens + cache_read_input_tokens + output_tokens` from the worker JSON `usage`.
- Codex: `input_tokens + output_tokens` from the `turn.completed.usage` fields. `cached_input_tokens` is inside `input_tokens` and `reasoning_output_tokens` is inside `output_tokens`; do not add them again.
- Grok and Oh My Pi: the harness's own reported total when it reports one; otherwise the sum of the fields whose documented meanings do not overlap. When the overlap cannot be settled, the cell is `unknown`.

Tokens is a count-once volume and readability measure of the usage workers reported. It is not spend, not a cache-efficiency score, and not proof of equivalent resource use across models or harnesses. When coordinator usage is unavailable, do not describe the Total as complete end-to-end usage. A low cache-read share alone is not evidence of cache invalidation.

The ledger notes keep the raw usage. In `ledger.md`, after the date line, write one notes line per attempt, in table order. The Total row has none. STAGE and ATTEMPT are the row's cells.
- A row with a worker: `- STAGE ATTEMPT: HARNESS VERSION MODEL EFFORT; field=value ...`. MODEL is the full model ID. A version, model, or effort the harness did not report is `unknown`.
- A row with no worker: `- STAGE ATTEMPT: coordinator`. It carries no version, model, effort, or usage.

Fields use the harness's own names and values, as reported. List only reported fields; when the harness reported no usage, write `usage=unknown`. A field is listed once. On a failed attempt, `exit=N error=REDACTED;` follows EFFORT. The summary and the final message do not copy the notes. The one exception is the verbatim `ledger.md` block the end-of-run order publishes in the summary; the summary's ordinary narrative still does not copy them. Capstan captures no cost. Record no spent, reported, or estimated cost figure or price in `ledger.md`, the summary, a host status line, or a benchmark or improvement comparison, even when the harness reports one.

For planning, record the initial plan, single review, correction launch/outcome,
and full finding handoff into implementing. Record any operator-authorized reopening
with its changed scope/architecture, not a reset caused by technical feedback.
For implementing/fix attempts carrying effective blocking findings, record each closure
gate row's reviewed head, red/green commands and outcomes, bite method, coordinator
verification, and any proxy/incomplete reason that kept the station open.
A closure-gate check outcome is a ledger row before the next review and before
publication: exact head, command, exit, and pass or fail. A proof script path
may be named. The script body is not the record.

For pre-merge, when `review_policy.residual_effect_approval` resolves to
`true`, record the residual-effect approval in `ledger.md` at each observation
of [pre-merge](pre-merge.md) step 4 and step 5, before the end-of-run order:
whether the gate applied; the residual effects or `unknown` reversibility that
triggered it, where a missing statement is `unknown`; and the counting approver
login, review `id`, and head SHA, or `no approval yet at <head SHA>` while the
blocker stands. Pre-merge owns the gate. This record is the summary source for
it.

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
the gap in `ledger.md` before the end-of-run order; after that, per its event
cutoff. A remote comment may still publish the gap. `run.md` is not the record.
Continue.

At terminal readiness, project the ready label and read it back. At review
exhaustion, do not project `capstan:ready-to-deploy`; the order starts after the
review-exhaustion decision. Then run the recurrence comparison under "Earlier
deliveries and recurrence" and write its lines into `ledger.md`. Then follow
this end-of-run order:

1. Write the final `ledger.md` and read it back.
2. At ready-to-deploy only, apply the deletion rule under "Ledger, pile, and deletion", write its records into `ledger.md`, and read it back.
3. Compute the ledger digest with `sha256sum ledger.md` or `shasum -a 256 ledger.md` and take the hex field. Nothing is written into `ledger.md` after this step.
4. Compose the summary from `ledger.md`, inspect it for credentials per [security.md](security.md) rule 7, and publish a marked issue summary.
5. Read the summary back.

Event cutoff: append the `run-end` event before step 1. From step 1 on, record
no event in `events.jsonl` or any other evidence file; the only ledger write
after step 1 is step 2's deletion records. An event from step 1 on, such as a
`telemetry-gap`, a `recovery` for a failed summary publication, or a
`label-change`, goes into the summary's gaps when it occurs before step 4
composes the summary, and otherwise into the final message. A missed final
message has no later record; the published summary stands. Host status lines
continue.

Any other marked summary, such as a batch human-capability summary, uses steps
1 and 3–5 and the event cutoff. Do not recompute the summary from the pile. The summary contains
PR URL, current head/base, observed ready-gate or exhaustion facts, the ledger's
attempt table with its Total row and the date line (copied unchanged: the same columns, order, and cell formats), findings addressed/refuted,
recovery history, human interventions, same-harness independence or unsafe mode
disclosures, applicable policy rows whose state is not `verified`, the ledger's
`Recurrence:` lines, the line
`Residual-effect approval:` from the latest ledger residual-effect approval
record when one exists, stating whether the gate applied, which residual
effects or `unknown` reversibility triggered it, and who approved at which
head, or `no approval yet at <head SHA>` in a blocked summary, and gaps. It
also contains the line `Ledger sha256: <hex>`, or `Ledger sha256: unknown` when
the digest fails. At `capstan:ready-to-deploy`, a summary whose admitted spec
has a `## Post-merge checks` section contains that section copied verbatim,
heading included; the final `ledger.md` records it verbatim, so step 4 composes
it from the ledger.
A summary for a spec without that section has no such heading.
Last, it contains the final `ledger.md` verbatim:

~~~
<details>
<summary>ledger.md</summary>

````
<ledger.md bytes>
````

</details>
~~~

The fence is backticks, one longer than the longest backtick run in `ledger.md`
and at least three. The final `ledger.md` ends with a newline. The block ends the
comment: nothing follows `</details>`, not even a newline. Before publishing,
write the whole candidate comment, block included, to FILE and measure it in
bash or zsh with `SUMMARY_BODY="$(<FILE)" gh api rate_limit --jq '$ENV.SUMMARY_BODY | length'`.
The `--jq` filter runs locally on the variable; the body is not sent. The count
is in Unicode code points. Include the block only when the count is at most
65,536, GitHub's comment limit, and the block passes the credential inspection.
A failed command or a count of 0 means the size is unknown. Otherwise put
`Ledger not published: <reason>.` in place of the block, where the reason is
`the comment would exceed 65,536 characters`,
`the comment size could not be measured`, or `credential inspection failed`. If
GitHub still rejects the comment as too long, publish it once more without the
block, with the first reason.

The attempt-table field rules are stated above. Both wall totals use the duration format above. End-to-end wall is from spec admission to the ready-label
read-back, before summary publication, or to the review-exhaustion decision. A bound that was not
observed is `unknown`. The supervisor-record rule above is that observation. The two totals are not substitutes for each other. A telemetry
gap in this table does not block ready-to-deploy. A digest failure or an
unpublished ledger is a telemetry gap. It does not block ready-to-deploy. It is
reported per the event cutoff, not in `ledger.md`. The summary comment and its
read-back are the record of publication. Include recovered
counts only when evidence supports them. Lost local data yields unknown details,
not an unrecoverable run. A failed GitHub summary publication uses normal transient
recovery; do not pretend it published. Remote progress evidence preserves budget
and rerun history across local deletion.

Emission follows the summary read-back. The coordinator's final message in the host session contains the attempt table with its Total row and the date line, copied unchanged from the published summary in the summary's columns, order, and formats. A URL may follow. The URL alone does not satisfy this. Trigger only at
verified `capstan:ready-to-deploy` or review exhaustion. The table stays terminal-only.
In a batch invocation, each issue's summary also publishes at a human-capability blocked overlay, and the final message waits for batch end; [batch invocation](modes/batch-invocation.md) ("Emit the final message once, after the last issue's summary read-back") owns both.
The surface is that final message on Claude Code, Codex, Grok, and Oh My Pi.
No plugin, notification command, or status-line API. Workers do
not post the table. Do not add a second summary comment or post the table on
the pull request.

Host status line rule: while a run is active, the coordinator posts one line in
the invoking host session when an event-table event occurs. Shape:
`capstan OWNER/REPO#N · STATION · EVENT: FACT`, for example
`capstan owner/repo#N · review · finding-census round 1: 2 blocking, 3 advisory → fix`.
FACT is one observed value from that event's evidence. A value not observed is
`unknown`. No estimates. A blocker line or a typed human decision line ends with
what the operator must do. This narrows decision 3 of
https://github.com/comamitc/capstan/issues/34: the stage-analysis table stays
terminal-only, and one-line host status lines are allowed and required.

Supervision observations follow the same rule: a running worker, a silent-check
wait, and the pre-merge CI wait. An observation posts a line only when it
changes something the line reports. For a worker, that is a new worktree head,
a new commit, or the result file appearing. The line gives elapsed time,
worktree head, new commits since the last line, and whether the result file
exists, for example
`capstan owner/repo#N · implementing · observation: 19m elapsed, head 1a2b3c4, 1 new commit, result absent`.
For a silent-check or CI wait, a snapshot is an observation while the silent
check still runs or a required CI check is still pending. The first snapshot
and each changed check state post an observation line with elapsed time, the
head, and the observed states. The settled outcome is the `check` event: the
silent check exits, or no required CI check is pending. It posts the `check`
line only, not an observation line. A change that is itself an event-table
event posts that event's line only. An unchanged observation posts nothing.
Lines come from observations the coordinator already makes, not from a new
timer. This rule adds no Capstan number or timeout. Workers do
not post status lines. A missed status line is a `telemetry-gap` in
`ledger.md` before the end-of-run order; after that, per its event cutoff. It
does not block a station, a label projection, or ready-to-deploy.

Same-figures rule: copy the published summary's figures. Do not recompute.
`unknown` stays `unknown`.

Gap rule: a missed host message is a telemetry gap in `ledger.md` before the
end-of-run order; after that, per its event cutoff. It does not skip the GitHub
summary and does not withhold ready.

## Earlier deliveries and recurrence

This section owns earlier deliveries, their mistake and friction kinds, classes, the recurrence comparison, and the `Recurrence:` line.

Earlier deliveries are this repository's issues whose body carries the marked `spec`. List open and closed issues with `gh`, every page, and keep those whose body contains the exact spec marker; do not rely on search to find the marker. Each earlier delivery is read in two kinds:

- Mistakes: actionable findings in marked `plan-review` comments and marked `review` censuses, fix rounds in the attempt table, reverts of a delivery's commits on the integration base, and PR review comments from trusted authors under [security](security.md).
- Friction: (1) pack gaps naming the same file or fact a worker could not reach; (2) repeated permission denials for the same command; (3) read stations hitting their operation ceiling; (4) recovery attempts; (5) evidence checks reported defective. Read them from the `ledger.md` each marked summary publishes verbatim, the local `ledger.md` when its evidence root survives, and the marked station artifacts.

A class is a group of occurrences of one kind that name the same defect. Finding categories are free text: group findings by the defect class they name, whatever the wording; exact category matching is not required. A class counts once it occurred in two or more deliveries, and it cites every occurrence by issue, census, or ledger URL. A source an earlier delivery does not retain is a named limitation, not zero.

Recurrence comparison. At terminal readiness after the ready-label read-back, or at the review-exhaustion decision, and before end-of-run step 1, compare this delivery with the 20 most recent earlier deliveries other than this one, newest first by issue number:

- classes of this delivery's plan-review and code-review findings, against those deliveries' marked `plan-review` and `review` censuses;
- this delivery's friction of kinds 1–3 from its `ledger.md`, against those deliveries' marked summaries, including their ledger blocks when present.

Read each earlier delivery's marked `plan-review` comments and marked summaries on its issue, and its marked `review` censuses on its marked pull request, with `gh` only, and apply trust per [security.md](security.md) item 1. Listing earlier deliveries still pages every issue; only these marked-comment reads are bounded to 20 deliveries. For friction, the comparison reads each marked summary's published `ledger.md` block when present, and also its recovery history and gaps, which correction does not read. For each class or signal of this delivery that occurred in two or more earlier deliveries, write one notes line in `ledger.md`:

`Recurrence: <class or signal> — #A <occurrence URL>, #B <occurrence URL>[, …]; suggest a correction issue (correction mode, [modes/correction.md](modes/correction.md)).`

When none recurs, write `Recurrence comparison: no recurrence; scope: <K> earlier deliveries #X–#Y; <sources read>.` A failed, truncated, or partial read is a telemetry gap: write `Recurrence comparison: gap: <source>: <redacted error>` in `ledger.md` and continue. A gap does not block and is not zero. Do not invent a result. A recurrence line is disclosure only: it does not block ready, open an issue, change a blocking/advisory partition, or change the review-exhaustion decision. "Any other marked summary" does not run the comparison. The within-delivery `surface_recurrence_rounds` diagnosis under [review convergence](review-convergence.md) is separate and unchanged.

## Ledger, pile, and deletion

This file owns the ledger, deletion, retention, and provenance. [contract.md](contract.md) owns
resolution of `evidence.delete_pile` and owns `evidence.retain_replay`.

`ledger.md` is the retained local record of totals and check outcomes. Always
write it, whether or not deletion is enabled. The attempt-table field rules
above are the ledger row. The switch cannot suppress `ledger.md`.

Ledger digest check: in the directory holding `ledger.md`, run `printf '%s  ledger.md\n' HEX | sha256sum -c -` or `printf '%s  ledger.md\n' HEX | shasum -a 256 -c -`, where HEX is the published `Ledger sha256:` value. It prints `ledger.md: OK` and exits 0 on a match, and prints `ledger.md: FAILED` and exits 1 otherwise. To check the published bytes instead, first recover them into an empty directory with `gh api repos/OWNER/REPO/issues/comments/ID --jq '.body | (split("\n\n</details>") | .[-2] | split("\n") | last) as $f | split("<summary>ledger.md</summary>\n\n" + $f + "\n") | last | split("\n" + $f + "\n") | first' > ledger.md`, then run the same command. The filter reads the fence from the comment's end and the last opening, so delimiter text inside the ledger or earlier in the summary does not cut the bytes short. A body with CRLF line endings fails recovery and the check. The digest is tamper-evident, not tamper-proof: a mismatch shows that the ledger or the published bytes changed after publication, and nothing prevents the change. Someone who can edit the comment can change both. It is not signing, attestation, or server enforcement.

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
and `verified`, `unresolved`, or `not-applicable`. Capstan's own policy text in
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

[modes/improvement.md](modes/improvement.md) ("This file owns the improvement invocation") owns replay selection and consumption, the improvement invocation, review corrections, the no-new-violations guard, and the comment rule. Trigger: the resolved `evidence.retain_replay` is `true`, an improvement invocation consumes replay inputs, or the admitted issue or the text invocation states an improvement invocation.

A selected bundle survives pile cleanup only when
`evidence.retain_replay` is `true`. Do not add a skill or
service. Do not add a path for the bundle.

Missing switch and invalid switch are not replayable.
[contract.md](contract.md) owns that resolution.

No mid-run deletion. At ready-to-deploy, after the ready-label read-back still
holds, after `ledger.md` is written and read back, and after no worker from
this run is active, and before the ledger digest, delete the named pile paths
only when the resolved switch is `true` and every required ledger field is
present. A successful read-back is not completeness. A missing required field
keeps the pile and the worktree, and the gap is recorded, even when the switch
is `true`. When the switch is `false`, the pile stays and the ledger says
deletion was skipped. Name each deleted path in `ledger.md` and read it back
before the digest. Do not recurse over the evidence root,
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
