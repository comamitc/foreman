# Fix — fresh primary, write

Enter only for effective blockers from the coordinator-partitioned current review
census. The coordinator extracts [code-review convergence](review-convergence.md)
and [finding resolution](findings.md) into the pack; the
primary proposes closure, the coordinator gates its proof, and the fresh secondary
reviews the cumulative candidate. Preserve original scenarios and acceptance
conditions.

The coordinator runs the preflight below before this worker launches.

Take commands from the plan's named checks, then the repository's documented runner.
Do not detect a language. Do not invent a second runner.
Run preflight before worker launch.
The preflight records the command, the tool path, and the provenance.
A preflight failure is visible.
A preflight failure does not spend a worker turn on discovery.
This is a ban on worker-side discovery.
The brief carries the exact invocation.
A worker that substitutes a global tool has not followed the brief.
The worker runs that invocation.
The worker does not discover a command, a runner, or a tool path.

The three-step precedence is this order.
First, use the recorded toolchain when the identity matches.
Identity is the lockfile or manifest bytes, not a language version.
A mismatch invalidates only the recorded toolchain.
Resolution then uses the declared runner on `PATH`.
Second, use the declared runner on `PATH`.
Do not skip that `PATH` step.
Third, create one task-scoped environment only if that `PATH` step fails.
The fallback tool is the repository's own declared tool.
Do not limit that tool to a lockfile.
A manifest-only repository is included.
Do not assume a package manager is global.
Do not create a task environment when the `PATH` step succeeds.
Record the choice as provenance.

A single executable with no lockfile gets that executable and no new environment.
No declared check leaves the repo unchanged.
A declared `pipenv run` when no global `pipenv` exists uses these three steps.
A non-Python runner that is absent from `PATH` uses these three steps.
Neither is a virtualenv special case.
When a task environment is created, put it at `toolchain/` under the evidence root.
Do not implement #10 deletion. Do not re-run `lyric-utils#764`.

1. Read the brief and the pack. It carries the effective blocking rows with the red command
   and output at the reviewed head, the saved diff, the functions the failing
   commands touch as Named files readable in full, and the failing commands plus
   the relevant final gates. Run those; a write station has no numeric ceiling,
   and its reads are bounded to the named files. A path the pack does not name is
   a gap reported under Risks and unresolved items, not a search. A one-file,
   one-check repair gets a compact pack. Reconcile any earlier repair effects.
2. Reproduce each finding at the exact reviewed head before editing and preserve
   its red command/output. On recovery from partial work, use an isolated scratch
   checkout at that head. Fix its root cause with a regression check that exercises
   the original scenario, or justify a non-executable seam and supply a deterministic
   old/new trace. Follow [ladder](ladder.md). Do not restate the ladder. Use the
   smallest coherent diff; avoid adjacent refactors and opportunistic cleanup.
3. Run affected checks and the relevant final gates. Use the exact invocation
   the brief carries. Commit coherent repairs,
   preserve human work, and verify clean status. Record resulting head and proof
   for every finding, including evidence-backed refutations.
4. Write the result; never push or publish it yourself. For every finding, include
   the complete red/green/bite row required by [finding resolution](findings.md).

Add `## Finding closure proofs`, `## Finding dispositions`, and `## Resulting head`
to common results. Complete when every effective blocking finding has a complete proposed
closure row, checks pass, and the worktree is clean. The coordinator then applies
the closure proof gate independently. An incomplete or non-discriminating row stays
in fix recovery; it is not pushed for a secondary reviewer to rediscover. Only
after the gate passes does the coordinator push normally and start a fresh review
under the code-review convergence ratchet, even if a refutation left head
unchanged. The pack carries the cumulative diff and identifies the repair delta. The new
census replaces prior finding authority with explicit reconciliation; old finding
IDs do not veto fresh evidence or disappear without a supported disposition.

A new delivery with no remote issue branch or pull request stays on local `capstan/N` through code review and fix. Do not push, and do not create the pull request, at that transition. The secondary reviews the exact local base and head SHAs and their three-dot diff. A fix commit is not pushed merely to start the next review. The closure-proof gate still applies before review. Local CI is the declared checks run on the local machine, including tests and the other commands the plan or repository conventions already name. Do not invent a check from a file extension. Do not parse workflow YAML. A named check that cannot run locally is recorded as not run locally and remains a pre-merge GitHub check. A missing or failing local check uses existing recovery and does not advance toward publication. The publication boundary is the point after local code review converges and base freshness is confirmed. Before the first push, fetch the resolved base. A stale-base ordinary merge that changes the head is a changed candidate. It needs a fresh review of the new local SHAs and three-dot diff, zero effective blockers, and a rerun of affected local CI before the first push. Do not publish the pre-merge head. Then push the exact reviewed `capstan/N` head once without force and create or reconcile one non-draft pull request. Apply the existing marker, `Closes #N`, title suffix, and read-backs. The observed pull-request head must equal the reviewed local head before pre-merge. Before the pull request exists, marked code-review censuses and dispositions are issue comments. After creation, the final converged exact-head census and applicable dispositions go on the pull request and link that issue history. No new marker kind. Do not read, wait for, or rerun GitHub-hosted checks before the publication boundary. Pre-merge owns those checks after publication. Do not use `[skip ci]`, workflow disabling, draft behavior, branch-rule changes, or a synthetic empty commit. This is not a promise of one workflow run. Record why each post-publication push was necessary. If a matching remote branch or marked pull request already exists, preserve it. Do not delete, close, or recreate it to obtain the deferred path.
