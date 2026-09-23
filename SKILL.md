---
name: capstan
description: Turn a trusted GitHub issue into an immediately mergeable pull request, with independent workers and recoverable evidence.
disable-model-invocation: true
---

# Capstan

Start a delivery only on an explicit user invocation with an issue URL, an
issue number inside its repository, or a text invocation. Repeating an issue
invocation resumes the same delivery. A delivery, a resume, an issue number,
and text intake do not enter init.

An explicit invocation of an issue that has `capstan:blocked` starts. Do not
refuse because of that label. Do not ask the operator to remove it first.
Before removing the overlay, observe the existing resume condition. Remove a
human-capability overlay only when the missing capability, decision, or budget
is observed. Remove a review-exhausted overlay only when one of the published
review-convergence resume conditions is observed. Keep the stage label. If that
condition is not observed, leave `capstan:blocked`, leave the blocker handoff,
and do not rerun the station. A label that is not `capstan:blocked`, including
a label named `blocked`, does not refuse the invocation and is not removed.

An issue URL uses that issue and does not create a second issue. Allowed
overrides stay overrides. An invocation that is an issue number, with or
without those overrides, uses that issue when it resolves in the current
checkout. Other prose is not this path even if it contains a digit.

Other non-empty prose with no GitHub URL creates one issue in the repository
`gh repo view` resolves from the invoking workspace. Title is the first
non-empty line, at most 256 characters. Body is the full text. Emit the new
issue URL in the host session before continuing. Then run the normal delivery.
Preserve the text as the original request.

If `gh repo view` cannot resolve a repository, create no issue and do not parse
a name from the prose. Ask for `owner/repo`. A GitHub URL that is not an issue
URL creates no issue. Empty text creates no issue. Do not read a filesystem
path. Do not use the surrounding transcript.

The created issue is the delivery identity. This one create is the only added
authority. An ordinary delivery does not create issues. Text intake does not
enter init and does not run init. No executable, parser, or controller.

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
   Worker claims and successful process exits alone do not establish completion;
   a result that cannot cite the pack is not completion.
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
8. **Advance and re-observe.** Only after the station criterion holds, project
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

Stop only at verified `capstan:ready-to-deploy`, a verified review-exhausted
blocked overlay, a typed human capability or budget decision from recovery, or
user cancellation. Pending infrastructure and
activity markers call for bounded waiting and observation, not abandonment.
On resume, observe whether the missing capability or review-exhausted resume
condition has appeared before removing the blocked overlay. A formerly ready PR
must satisfy the live gate again.

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

## Init

Init runs only on an explicit init invocation. A delivery, a resume, and an issue
number do not enter init. Init is not a binary and not a station. Init is not a
gate. Delivery remains valid without init. A missing `.capstan.json` still
delivers. Delivery still creates a missing stage label.

Probe each harness CLI on `PATH` with that CLI's documented help command. Recommend
a primary and a different secondary only from CLIs that answered. Do not invent a
model, effort, or harness. When the observed primary and a different observed
secondary are unambiguous, select that pair and report it. Do not ask. Do not
prompt. Ask only when the probe is ambiguous. Ask that one pair and recommend an
observed answer. Keep timeouts, cost, and `unsafe_autonomy` at the documented
defaults. The invoking host does not become primary merely because it ran init.

If `.capstan.json` is absent, exclusive-create it in the named checkout. Write
only `primary`, `secondary`, and `fallback`, plus the documented recovery
defaults. Set model and effort to null. Set `fallback` to null when no third
observed harness exists. Set `unsafe_autonomy` to false. Leave the file
uncommitted. Do not switch branches. Do not commit, push, or open a pull request.
The write is allowed on `main` and stays uncommitted. Exclusive create writes the
new file only when it is absent. If the file is present before the write finishes,
do not replace it.

If `.capstan.json` exists, leave the bytes unchanged. Do not merge, reformat,
replace, or use `--force`. Report that the file already exists.

Ensure these ten labels exist: `capstan:triage`, `capstan:ready`,
`capstan:planning`, `capstan:plan-review`, `capstan:implementing`, `capstan:review`,
`capstan:fix`, `capstan:pre-merge`, `capstan:ready-to-deploy`, and
`capstan:blocked`. Create only absent labels. Re-read a race. Do not add or remove
any other label. Use the label create command in [contract](references/contract.md).

Init writes no secrets, no evidence directory, no worktree, and no feature map.
Init does not edit product source.

A new delivery with no remote issue branch or pull request stays on local `capstan/N` through code review and fix. Do not push, and do not create the pull request, at that transition. The secondary reviews the exact local base and head SHAs and their three-dot diff. A fix commit is not pushed merely to start the next review. The closure-proof gate still applies before review. Local CI is the declared checks run on the local machine, including tests and the other commands the plan or repository conventions already name. Do not invent a check from a file extension. Do not parse workflow YAML. A named check that cannot run locally is recorded as not run locally and remains a pre-merge GitHub check. A missing or failing local check uses existing recovery and does not advance toward publication. The publication boundary is the point after local code review converges and base freshness is confirmed. Before the first push, fetch the resolved base. A stale-base ordinary merge that changes the head is a changed candidate. It needs a fresh review of the new local SHAs and three-dot diff, zero effective blockers, and a rerun of affected local CI before the first push. Do not publish the pre-merge head. Then push the exact reviewed `capstan/N` head once without force and create or reconcile one non-draft pull request. Apply the existing marker, `Closes #N`, title suffix, and read-backs. The observed pull-request head must equal the reviewed local head before pre-merge. Before the pull request exists, marked code-review censuses and dispositions are issue comments. After creation, the final converged exact-head census and applicable dispositions go on the pull request and link that issue history. No new marker kind. Do not read, wait for, or rerun GitHub-hosted checks before the publication boundary. Pre-merge owns those checks after publication. Do not use `[skip ci]`, workflow disabling, draft behavior, branch-rule changes, or a synthetic empty commit. This is not a promise of one workflow run. Record why each post-publication push was necessary. If a matching remote branch or marked pull request already exists, preserve it. Do not delete, close, or recreate it to obtain the deferred path.
