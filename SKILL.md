---
name: capstan
description: Turn a trusted GitHub issue into an immediately mergeable pull request, with independent workers and recoverable evidence.
disable-model-invocation: true
---

# Capstan

[references/contract.md](references/contract.md) owns text intake. [references/recovery.md](references/recovery.md)
owns blocked-overlay removal.

You are the coordinator. Own observation, user decisions, worker delegation,
GitHub mechanics, and verification. Workers author product changes and commits.
Finish at an open, immediately mergeable PR. Never merge or deploy.

## Coordinator loop

1. **Observe.** Read [contract](references/contract.md) on every invocation.
   Resolve identity, trust, configuration, repository instructions, and current
   evidence. Reconcile side effects before retrying operations or trusting labels.
2. **Choose and load.** Select the current station from completion evidence.
   Read that station's reference and no other station's. Repair contradictory labels.
   For planning, plan-review, or their resume, apply [one-pass planning](references/plan-convergence.md)
   before dispatch: initial plan → review → single all-findings correction → implementing.
3. **Brief.** Before consuming issue content or writing a worker brief, read
   [security](references/security.md). Use [brief](templates/brief.md) with the
   admitted spec, numbered station steps, a checkable completion criterion, and
   one pack per launch, sized to the unit (compact for a one-file, one-check unit)
   and named in the brief as the worker's only reading. Extract the applicable
   rules into the pack; never paste a conventions file.
4. **Delegate.** Triage is interactive coordinator work. Before you dispatch a
   write station (implementing or fix) or a review station (plan-review or
   review), load [ladder](references/ladder.md). For each other judgment
   or write station, start a fresh headless worker using
   [harnesses](references/harnesses.md). Pre-merge observation and GitHub actions
   stay with you; delegate its technical repairs. Write briefs, packs, and results
   outside the product worktree. Read stations get a numeric turn ceiling in the
   brief; write stations read named files only. Supervise the process until exit
   or recorded handoff.
5. **Verify.** Inspect actual results, commands, commits, diff, and GitHub.
   [references/harnesses/shared.md](references/harnesses/shared.md) owns result acceptance.
   Before pushing a write-station candidate, apply [finding resolution's closure
   proof gate](references/findings.md) to every carried effective blocker; incomplete
   red/green/bite proof stays in the current station.
6. **Recover.** Any failed attempt, command, check, missing artifact, or weak
   result loads [recovery](references/recovery.md). A pack gap is a brief defect:
   amend the pack; planning gaps follow one-pass planning. Recover within this
   station; fresh evidence determines whether previously completed work needs
   repeating.
7. **Record.** Publish the station artifact with its revision or SHAs. Read
   [telemetry](references/telemetry.md) to record attempts and evidence. A telemetry
   failure is a reported gap, never a veto on delivery.
8. **Advance and re-observe.** Only after result acceptance owned by
   [references/harnesses/shared.md](references/harnesses/shared.md) holds, project
   the next stage label and read it and external state back. Repeat the loop.

| Station | Reference | Owner |
| --- | --- | --- |
| triage | [triage](references/triage.md) | coordinator |
| ready | contract: accept run and reconcile worktree, then planning | coordinator |
| planning | [planning](references/planning.md) | fresh primary |
| plan-review | [plan-review](references/plan-review.md) | fresh secondary |
| implementing | [implementing](references/implementing.md) | fresh primary |
| review | [review](references/review.md), [code-review convergence](references/review-convergence.md) | fresh secondary |
| fix | [fix](references/fix.md), [code-review convergence](references/review-convergence.md), only for effective blockers | fresh primary |
| pre-merge | [pre-merge](references/pre-merge.md) | coordinator and repair workers |

Before creating `capstan/N`, run `git fetch origin <resolved-base>` so `origin/<resolved-base>` is updated in this run. For this repository that command is `git fetch origin main`. Immediately after a successful fetch, record the SHA of that ref. Create the worktree from that SHA. Local `main`, an unfetched `origin/main`, and `origin/HEAD` are not valid parents. If the fetch fails, stop. Do not create the worktree from local `main`. An existing `capstan/N` worktree is not rebased or recreated. Do not fast-forward, switch, or edit the shared checkout.

Stop only at verified `capstan:ready-to-deploy`, a verified review-exhausted
blocked overlay, a typed human capability or budget decision from recovery, or
user cancellation. Pending infrastructure and
activity markers call for bounded waiting and observation, not abandonment.
On resume, [references/recovery.md](references/recovery.md) owns blocked-overlay
removal. A formerly ready PR must satisfy the live gate again.

[references/telemetry.md](references/telemetry.md) owns stage-analysis emission.

## Init

[references/contract.md](references/contract.md) owns init.

[references/publication.md](references/publication.md) owns publication.
