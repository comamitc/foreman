# Evidence, not control state

At the contract's delivery evidence root, create owner-only `briefs/`, `results/`,
`workers/`, `checks/`, `run.md`, and optional `events.jsonl`. Give attempts unique
human-readable filenames, for example `planning-20260921T120000Z-1.md`. On resume,
append rather than overwrite surviving attempts. Follow security before capture.

Write run.md directly. Record delivery identity, spec revision, effective nonsecret
configuration, run start/budget, and a chronological station/attempt table. Each
station records start/end UTC and wall time, role, harness/version/model/effort,
safety mode, process exit/session, reported tokens/cost, checks and exit results,
head before/after, finding census, recovery hypotheses, label changes, and evidence
paths/remote URLs. Say `unknown` when not reported; never estimate or use zero for
missing usage. Avoid adding both session totals and their constituent turn totals.

Use these event kinds when their trigger occurs:

| Kind | Trigger |
| --- | --- |
| run-start / run-resume | accepted invocation or reconstructed continuation |
| station-start / station-end | station begins or completion criterion verified |
| worker-start / worker-end | each worker attempt, including corrective attempts |
| check | observed command/check outcome and applicable head |
| finding-census | plan/code review verdict and finding counts at revision/SHAs |
| recovery | failure, semantic progress comparison, hypothesis, next attempt |
| label-change | observed before/after labels, including projection repair |
| blocker / unblock | typed capability and observed satisfaction |
| telemetry-gap | missing, malformed, or failed evidence capture |
| run-end | ready, capability/budget handoff, or cancellation |

Events may be Markdown paragraphs. JSONL is an optional convenience, with fields
such as time, kind, station, attempt, head, outcome, and evidence. Existing `jq -cn`
with `--arg` or another installed JSON emitter can append correctly escaped lines.
Do not concatenate unescaped worker text into JSON. No validator, parser, helper,
or event is needed to choose a station. On failed append or malformed event, note
the gap in run.md or the next available remote comment and continue.

At terminal readiness publish a marked issue summary containing PR URL, current
head/base, observed ready-gate facts, station/attempt table, wall time, reported
usage/cost, findings addressed/refuted, recovery history, human interventions,
same-harness independence or unsafe mode disclosures, and gaps. Include recovered
counts only when evidence supports them. Lost local data yields unknown details,
not an unrecoverable run. A failed GitHub summary publication uses normal transient
recovery; do not pretend it published. Remote progress evidence preserves budget
and rerun history across local deletion.
