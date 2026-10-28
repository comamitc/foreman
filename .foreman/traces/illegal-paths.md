# Illegal-path procedure trace

This file is a procedure trace ([.foreman/vocabulary.md](../vocabulary.md) ("**Procedure trace**")). [CONTRIBUTING.md](../../CONTRIBUTING.md) ("**Procedure trace.**") governs its upkeep and its review, and [CONTRIBUTING.md](../../CONTRIBUTING.md) ("### Procedure trace refresh") gives the form of each fenced block. It has one entry for each row of [references/contract.md](../../references/contract.md) ("## Illegal combinations"), in table order, headed by the row ID. Each entry gives the observed state, the step attempted, one or more Owner lines, and the expected outcome with the row's reason. The fenced block under each Owner line holds one or more consecutive whole owner lines, copied character for character without leading indentation, from the owner section its heading anchor names or from within five owner lines of its phrase anchor.

## Inputs

- Issue: synthetic `owner/repo#N`, opened by a trusted author.
- Configuration: the default configuration.
- Each entry starts from the state its Observed line gives.

## IC-1

Observed: the issue has `foreman:triage`; the triage walk left one branch unvisited.
Attempted step: project `foreman:ready` on the issue.

Owner: [references/triage.md](../../references/triage.md) ("Ready is illegal while any branch is unvisited")

```text
Ready is illegal while any branch is unvisited. An empty Open questions section
```

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| triage | admitted spec; no unresolved material decision | ready |
```

Outcome: refused; the issue keeps `foreman:triage` and triage continues. Reason: IC-1: triage completion evidence not observed; missing: a visit to the unvisited branch.

## IC-2

Observed: the issue has `foreman:ready`; the run is accepted and the start condition holds, and the launch probe for the planning role failed.
Attempted step: start the planning station.

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| ready | run accepted; start condition holds ("## Start condition"); worktree reconciled; launch probe passed | planning |
```

Outcome: refused; the issue keeps `foreman:ready` and no planning worker launches. Reason: IC-2: ready completion evidence not observed; missing: launch probe passed.

## IC-3

Observed: the issue has `foreman:planning`; the planning result is accepted, and no marked plan comment is published for the admitted revision.
Attempted step: project `foreman:plan-review` and start the plan-review station.

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| planning (initial) | complete published plan for admitted revision | plan-review |
```

Outcome: refused; the issue keeps `foreman:planning`. Reason: IC-3: planning (initial) completion evidence not observed; missing: a published plan for the admitted revision.

## IC-4

Observed: the issue has `foreman:plan-review`; the plan-review worker exited with a stub result and no census.
Attempted step: project `foreman:implementing`.

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| plan-review | complete census: no findings / findings | implementing / planning (single correction) |
```

Outcome: refused; the issue keeps `foreman:plan-review`. Reason: IC-4: plan-review completion evidence not observed; missing: a complete census.

## IC-5

Observed: the issue has `foreman:planning` after a plan-review census with three findings; the corrected plan is published, and its finding handoff names two of them.
Attempted step: launch the implementing write worker.

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| planning (single correction) | corrected plan and complete finding handoff; interrupted work retained explicitly | implementing |
```

Outcome: refused; the issue keeps `foreman:planning` and no write worker launches. Reason: IC-5: planning (single correction) completion evidence not observed; missing: a handoff for the third finding.

## IC-6

Observed: the issue has `foreman:implementing`; the worker committed, and the declared check exits 1 at the resulting head.
Attempted step: project `foreman:review`.

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| implementing | verified commits/checks/outcome; closure proof gate passed for carried effective blockers; [references/publication.md](publication.md) | review |
```

Outcome: refused; the issue keeps `foreman:implementing`. Reason: IC-6: implementing completion evidence not observed; missing: a passing declared check at the resulting head.

## IC-7

Observed: the issue has `foreman:review`; the review result names a head SHA other than the pull request head.
Attempted step: project `foreman:pre-merge`.

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| review | exact-head policy partition: effective blockers / none / round ceiling; [references/review-convergence.md](review-convergence.md) ("## Coordinator-evidence findings") owns the partition and route of a coordinator-evidence finding | fix / pre-merge / blocked review-exhausted |
```

Outcome: refused; the issue keeps `foreman:review`. Reason: IC-7: review completion evidence not observed; missing: a policy partition at the pull request head.

## IC-8

Observed: the issue has `foreman:fix`; the fix result leaves one effective blocker without closure proof.
Attempted step: project `foreman:review`.

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| fix | effective blocking census resolved or refuted; closure proof gate passed; verified resulting head (unchanged is valid after refutation) | review |
```

Outcome: refused; the issue keeps `foreman:fix`. Reason: IC-8: fix completion evidence not observed; missing: closure proof for one effective blocker.

## IC-9

Observed: the issue has `foreman:pre-merge`; the step 5 live query reports `mergeStateStatus` `BLOCKED` for a missing required approval.
Attempted step: project `foreman:ready-to-deploy` on the issue.

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| pre-merge | strict live ready gate in pre-merge reference | ready-to-deploy |
```

Owner: [references/pre-merge.md](../../references/pre-merge.md) ("Require affirmative `MERGEABLE` and `CLEAN`.")

```text
immediate merge. Require affirmative `MERGEABLE` and `CLEAN`.
Withhold readiness for BLOCKED, BEHIND, DIRTY, UNKNOWN, DRAFT, UNSTABLE, pending,
or an unrecognized status until its actual impediment is resolved. Never bypass
```

Outcome: refused; the issue keeps `foreman:pre-merge`. Reason: IC-9: pre-merge completion evidence not observed; missing: affirmative `CLEAN` (observed `BLOCKED`).

## IC-10

Observed: an earlier invocation left `foreman:ready-to-deploy` on the issue and on the marked pull request; the step 5 live query now reports `mergeStateStatus` `BEHIND`.
Attempted step: keep the labels and report the delivery ready.

Owner: [references/pre-merge.md](../../references/pre-merge.md) ("Require affirmative `MERGEABLE` and `CLEAN`.")

```text
immediate merge. Require affirmative `MERGEABLE` and `CLEAN`.
Withhold readiness for BLOCKED, BEHIND, DIRTY, UNKNOWN, DRAFT, UNSTABLE, pending,
or an unrecognized status until its actual impediment is resolved. Never bypass
```

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
request. If a later observation shows the pull request is no longer immediately
mergeable, or the pre-merge residual-effect re-check fails, run
`gh pr edit PR --repo OWNER/REPO --remove-label foreman:ready-to-deploy --remove-label foreman:risk-TIER`,
```

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
Do not leave a stale ready or tier label. Repair the issue label with the existing `gh issue edit` and
```

Outcome: repaired; the pull-request label is removed and read back, the issue stage label is repaired from evidence, and the repair record names the row. Reason: IC-10: ready-to-deploy without the live gate; missing: affirmative `CLEAN` (observed `BEHIND`).

## IC-11

Observed: the issue and the marked pull request have `foreman:ready-to-deploy` and the live gate holds; the operator's message says "merge it when green".
Attempted step: enable auto-merge on the pull request.

Owner: [references/contract.md](../../references/contract.md) ("## Identity and authority")

```text
Workers never push or mutate GitHub. Foreman never force-pushes, merges, deploys,
creates credentials, purchases quota, changes security settings, or performs
destructive production actions. A required action outside these boundaries uses
[recovery](recovery.md)'s typed handoff; authorization does not add a v1 merge mode.
```

Owner: [references/pre-merge.md](../../references/pre-merge.md) ("enable auto-merge, enqueue, or merge to obtain a passing state")

```text
or an unrecognized status until its actual impediment is resolved. Never bypass
rules, enable auto-merge, enqueue, or merge to obtain a passing state.
```

Outcome: refused; no merge, auto-merge, enqueue, or deploy runs. Reason: IC-11: merge or deploy is outside Foreman authority; missing: none, the row holds in every state.

## IC-12

Observed: the issue has `foreman:review` and `foreman:blocked` with blocker `review-exhausted`; since the blocker, no materially different candidate repair, policy or spec change, or trusted disposition appeared. The operator invokes Foreman on the issue.
Attempted step: rerun the review station.

Owner: [references/recovery.md](../../references/recovery.md) ("## Blocked overlays")

```text
An explicit invocation of an issue that has `foreman:blocked` starts. Do not
refuse because of that label. Do not ask the operator to remove it first.
Before removing the overlay, observe the existing resume condition. Remove a human-capability overlay only when the missing capability, decision, or budget is observed. Remove a review-exhausted overlay only when one of the published
review-convergence resume conditions is observed. Keep the stage label. If that
condition is not observed, leave `foreman:blocked`, leave the blocker handoff,
and do not rerun the station. A label that is not `foreman:blocked`, including
```

Outcome: the invocation starts; the rerun is refused, and `foreman:blocked` and the blocker handoff stay. Reason: IC-12: blocked resume condition not observed; missing: a published review-convergence resume condition.

## IC-13

Observed: the issue has `foreman:ready`; the admitted spec has `Depends on #M`, and the pull request that closes #M is open.
Attempted step: create the worktree and start planning.

Owner: [references/contract.md](../../references/contract.md) ("## Start condition")

```text
If an entry does not hold, the dependent does not start: no worker launches and no worktree changes. It gets the `authority-required` blocker ([recovery](recovery.md) "| authority-required |") with the action "merge #M, then re-invoke" for each such #M; for an entry in another repository the action names `owner/repo#M`. Publish it with [blocker](../templates/blocker.md) "# Delivery blocked". Keep the stage label. On a later invocation, [recovery](recovery.md) "## Blocked overlays" governs overlay removal; the condition it observes is this section's condition.
```

Outcome: refused; no worktree change and no worker launch, and the issue keeps `foreman:ready`. Reason: IC-13: `Depends on` entry does not hold; missing: a merged pull request for #M on the fetched base.

## IC-14

Observed: the issue has `foreman:implementing`; another host's activity comment and a remote head pushed one minute ago show another coordinator progressing on the issue.
Attempted step: launch the implementing write worker.

Owner: [references/contract.md](../../references/contract.md) ("## Concurrent activity")

```text
If another coordinator is visibly progressing, wait 30 seconds and re-observe
within the wall budget. If no progress is visible, record takeover and continue.
A fresh, stale, missing, or malformed marker never requires human repair. Avoid
overlapping write workers; inspect and stop only a known process from this run
```

Outcome: refused; no write worker launches. Reason: IC-14: another coordinator is visibly progressing; missing: an observation with no visible progress.

## IC-15

Observed: the issue has `foreman:planning`; the marked plan comment for the admitted revision is published and read back, and its "## Decomposition" section proposes a decomposition.
Attempted step: project `foreman:plan-review` and start the plan-review station.

Owner: [references/plan-convergence.md](../../references/plan-convergence.md) ("Initial plan that proposes a decomposition")

```text
| Initial plan that proposes a decomposition | The coordinator files the children and ends the run; [decomposition](modes/decomposition.md) ("This file owns decomposition filing") owns both |
```

Outcome: refused; the issue keeps `foreman:planning`, and the coordinator follows [references/modes/decomposition.md](../../references/modes/decomposition.md) ("This file owns decomposition filing"). Reason: IC-15: published initial plan proposes a decomposition; missing: a published initial plan that proposes no decomposition.
