---
name: capstan
description: Turn a trusted GitHub issue into an immediately mergeable pull request, with independent workers and recoverable evidence.
disable-model-invocation: true
---

# Capstan

Start only on an explicit user invocation with an issue URL, or an issue number
inside its repository. Repeating the invocation resumes the same delivery.
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
   admitted spec, repository conventions, current artifacts, numbered station
   steps, and a checkable completion criterion.
4. **Delegate.** Triage is interactive coordinator work. For each other judgment
   or write station, start a fresh headless worker using
   [harnesses](references/harnesses.md). Pre-merge observation and GitHub actions
   stay with you; delegate its technical repairs. Write briefs/results outside
   the product worktree. Supervise the process until exit or recorded handoff.
5. **Verify.** Inspect actual results, commands, commits, diff, and GitHub.
   Worker claims and successful process exits alone do not establish completion.
   Before pushing a write-station candidate, apply [finding resolution's closure
   proof gate](references/findings.md) to every carried blocker/major; incomplete
   red/green/bite proof stays in the current station.
6. **Recover.** Any failed attempt, command, check, missing artifact, or weak
   result loads [recovery](references/recovery.md). Recover within this station;
   fresh evidence determines whether previously completed work needs repeating.
7. **Record.** Publish the station artifact with its revision or SHAs. Read
   [telemetry](references/telemetry.md) to record attempts and evidence. A telemetry
   failure is a reported gap, never a veto on delivery.
8. **Advance and re-observe.** Only after the station criterion holds, project
   the next stage label and read it and external state back. Repeat the loop.

| Station | Reference | Owner |
| --- | --- | --- |
| triage | [triage](references/triage.md) | coordinator |
| ready | contract: accept run and reconcile worktree, then planning | coordinator |
| planning | [planning](references/planning.md) | fresh primary |
| plan-review | [plan-review](references/plan-review.md) | fresh secondary |
| implementing | [implementing](references/implementing.md) | fresh primary |
| review | [review](references/review.md) | fresh secondary |
| fix | [fix](references/fix.md), only for blocking findings | fresh primary |
| pre-merge | [pre-merge](references/pre-merge.md) | coordinator and repair workers |

Stop only at verified `capstan:ready-to-deploy`, a typed human capability or
budget decision from recovery, or user cancellation. Pending infrastructure and
activity markers call for bounded waiting and observation, not abandonment.
On resume, observe whether the missing capability has appeared before removing
the blocked overlay. A formerly ready PR must satisfy the live gate again.
