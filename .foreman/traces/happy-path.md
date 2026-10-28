# Happy-path procedure trace

This file is a procedure trace ([.capstan/vocabulary.md](../vocabulary.md) ("**Procedure trace**")). [CONTRIBUTING.md](../../CONTRIBUTING.md) ("**Procedure trace.**") governs its upkeep and its review. Each fenced block quotes one shape from the owner file and stable anchor on the Owner line above it.

## Inputs

- Issue: synthetic `owner/repo#N`, opened by a trusted author.
- Configuration: the default configuration.
- Plan review: the plan-review census has no findings.
- Code review: the code-review census has no findings, so it has no effective blockers.

No fix station runs on this path.

## triage

### Spec marker

Owner: [references/contract.md](../../references/contract.md) ("## Marked Markdown artifacts")

```text
`<!-- capstan:KIND owner/repo#N -->`
```

Owner: [references/contract.md](../../references/contract.md) ("## Marked Markdown artifacts")

```text
`spec`,
```

Owner: [references/triage.md](../../references/triage.md) ("Keep the existing issue-body spec marker")

```text
`<!-- capstan:spec owner/repo#N -->`
```

### Stage label form

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
`capstan:` before each stage name
```

### Stage-label move

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| triage | admitted spec; no unresolved material decision | ready |
```

## ready

### Local evidence root

Owner: [references/contract.md](../../references/contract.md) ("| Local evidence root |")

```text
`${CAPSTAN_STATE:-${XDG_STATE_HOME:-$HOME/.local/state}/capstan}/owner/repo/N/`
```

### Evidence files at run acceptance

Owner: [references/telemetry.md](../../references/telemetry.md) ("At the contract's delivery evidence root")

```text
create owner-only `briefs/`, `results/`,
```

Owner: [references/telemetry.md](../../references/telemetry.md) ("At the contract's delivery evidence root")

```text
`workers/`, `checks/`, and `events.jsonl`
```

### Ledger

Owner: [references/telemetry.md](../../references/telemetry.md) ("Always write `ledger.md` at")

```text
Always write `ledger.md` at
```

### Pile directories

Owner: [references/telemetry.md](../../references/telemetry.md) ("The pile is exactly")

```text
`briefs/`, `results/`, `workers/`, `checks/`, `toolchain/`,
```

Owner: [references/telemetry.md](../../references/telemetry.md) ("The pile is exactly")

```text
`tooling/`, and `events.jsonl`.
```

### Branch

Owner: [references/contract.md](../../references/contract.md) ("| Item | Stable identity |")

```text
| Branch | `capstan/N` |
```

### Worktree

Owner: [references/contract.md](../../references/contract.md) ("| Item | Stable identity |")

```text
| Worktree | `<repo>/.worktrees/capstan+N` |
```

### Stage-label move

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| ready | run accepted; start condition holds ("## Start condition"); worktree reconciled; launch probe passed | planning |
```

### Host status line

Owner: [references/telemetry.md](../../references/telemetry.md) ("Shape:")

```text
`capstan OWNER/REPO#N · STATION · EVENT: FACT`
```

## planning

### Plan marker

Owner: [references/contract.md](../../references/contract.md) ("## Marked Markdown artifacts")

```text
`<!-- capstan:KIND owner/repo#N -->`
```

Owner: [references/contract.md](../../references/contract.md) ("## Marked Markdown artifacts")

```text
`plan`,
```

Owner: [templates/plan.md](../../templates/plan.md) ("`<!-- capstan:plan OWNER/REPO#N -->`")

```text
<!-- capstan:plan OWNER/REPO#N -->
```

### Stage-label move

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| planning (initial) | complete published plan for admitted revision | plan-review |
```

### Host status line

Owner: [references/telemetry.md](../../references/telemetry.md) ("Shape:")

```text
`capstan OWNER/REPO#N · STATION · EVENT: FACT`
```

## plan-review

### Plan-review marker

Owner: [references/contract.md](../../references/contract.md) ("## Marked Markdown artifacts")

```text
`<!-- capstan:KIND owner/repo#N -->`
```

Owner: [references/contract.md](../../references/contract.md) ("## Marked Markdown artifacts")

```text
`plan-review`,
```

### Stage-label move

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| plan-review | complete census: no findings / findings | implementing / planning (single correction) |
```

### Host status line

Owner: [references/telemetry.md](../../references/telemetry.md) ("Shape:")

```text
`capstan OWNER/REPO#N · STATION · EVENT: FACT`
```

## implementing

### Stage-label move

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| implementing | verified commits/checks/outcome; closure proof gate passed for carried effective blockers; [references/publication.md](publication.md) | review |
```

### Host status line

Owner: [references/telemetry.md](../../references/telemetry.md) ("Shape:")

```text
`capstan OWNER/REPO#N · STATION · EVENT: FACT`
```

## review

### Review marker

Owner: [references/contract.md](../../references/contract.md) ("## Marked Markdown artifacts")

```text
`<!-- capstan:KIND owner/repo#N -->`
```

Owner: [references/contract.md](../../references/contract.md) ("## Marked Markdown artifacts")

```text
`review`,
```

Owner: [templates/review.md](../../templates/review.md) ("`<!-- capstan:review OWNER/REPO#N -->`")

```text
<!-- capstan:review OWNER/REPO#N -->
```

### Pull-request identity line

Owner: [references/contract.md](../../references/contract.md) ("| Item | Stable identity |")

```text
| PR | exact head `capstan/N` and body line `Capstan: owner/repo#N` |
```

### Pull-request close line

Owner: [references/publication.md](../../references/publication.md) ("At the publication boundary")

```text
`Closes #N`
```

### Stage-label move

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| review | exact-head policy partition: effective blockers / none / round ceiling; [references/review-convergence.md](review-convergence.md) ("## Coordinator-evidence findings") owns the partition and route of a coordinator-evidence finding | fix / pre-merge / blocked review-exhausted |
```

### Host status line

Owner: [references/telemetry.md](../../references/telemetry.md) ("Shape:")

```text
`capstan OWNER/REPO#N · STATION · EVENT: FACT`
```

## pre-merge

### Risk tier line

Owner: [references/pre-merge.md](../../references/pre-merge.md) ("Risk tier:")

```text
`Risk tier: TIER at HEAD_SHA; basis: BASIS`
```

### Walkthrough section (`high` tier)

Owner: [references/pre-merge.md](../../references/pre-merge.md) ("Walkthrough:")

```text
`## Walkthrough`
```

### Stage-label move

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
| pre-merge | strict live ready gate in pre-merge reference | ready-to-deploy |
```

### Host status line

Owner: [references/telemetry.md](../../references/telemetry.md) ("Shape:")

```text
`capstan OWNER/REPO#N · STATION · EVENT: FACT`
```

## ready-to-deploy

### Pull-request labels

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
shows `capstan:ready-to-deploy` and exactly one
```

Owner: [references/contract.md](../../references/contract.md) ("## Stage projection")

```text
`capstan:risk-*` label, the computed one
```

### Final ledger

Owner: [references/end-of-run.md](../../references/end-of-run.md) ("Write the final `ledger.md` and read it back.")

```text
the final `ledger.md`
```

### Summary marker

Owner: [references/contract.md](../../references/contract.md) ("## Marked Markdown artifacts")

```text
`<!-- capstan:KIND owner/repo#N -->`
```

Owner: [references/contract.md](../../references/contract.md) ("## Marked Markdown artifacts")

```text
`summary`,
```

Owner: [references/end-of-run.md](../../references/end-of-run.md) ("Compose the summary from `ledger.md`")

```text
publish a marked issue summary
```

### Host status line

Owner: [references/telemetry.md](../../references/telemetry.md) ("Shape:")

```text
`capstan OWNER/REPO#N · STATION · EVENT: FACT`
```
