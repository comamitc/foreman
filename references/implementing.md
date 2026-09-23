# Implementing — fresh primary, write

The coordinator extracts the [finding resolution](findings.md) closure-row
requirements into the pack; the worker reads the brief and the pack. Planning
handoff is permission to implement, not independent approval of the corrected
design or closure of its findings.

`features` is the optional feature-map field. Resolution order is invocation,
then `CAPSTAN_FEATURES`, then the `.capstan.json` field `features`, then
`.capstan/features` when that directory contains `README.md`. `features: null`
disables the map. A missing explicit path is recorded in `run.md`. The run
continues with no map. A delivery with no map still completes. Do not generate
a map during an ordinary issue.

When a feature map is present, use the named `Driving it` steps for the
user-surface proof. If the change alters reachability, drive steps, or the
proof, the same commit updates that feature file. When the map is present, a
new user-facing behavior adds one feature file and one index line.

Each feature file uses only these four H2 headings and no harness name:
`Sub-features`, `How to get to it (user POV)`, `Driving it`, `Gotchas`.
`Driving it` states the repository commands and the observable end state. A
harness name, a host skill path, or another section does not satisfy the shape.
No Launch, Doctor, Evidence, Cleanup, or Helpers section.

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

1. Read the brief and the pack: the current plan text, every carried finding row
   with its proposed disposition including unfinished correction work, the rule
   extract, the commands the plan names plus the final gates, and the plan's
   affected files and tests as Named files. A write station may read named files
   fully and run the named checks and declared final gates; it has no numeric
   ceiling. A path the pack does not name is a gap reported under Risks and
   unresolved items, not a search. A one-file, one-check item gets a compact pack
   whose single named file and check bound the reads. Map ALL carried findings to
   implementation tasks/checks or evidence-backed refutations. Complete this
   mapping before affected code is written. Reconcile existing work before
   repeating interrupted steps.
2. Implement plan items in order. Use a failing behavior check where meaningful,
   prove it fails for the intended reason, then make the smallest change and rerun.
   Documentation, configuration, deletion, generated, and operational changes may
   use stronger appropriate proof instead; explain when a failing test adds no value.
3. Run each item's verification. Keep scope narrow; commit coherent changes.
   Triage reads the committed `.capstan/vocabulary.md` on `main` when it exists,
   after repository instructions and before a question. Implementation writes
   the file. An unmerged vocabulary edit is not evidence for a different issue.
   A settlement is repository-scoped when the term names a standing behavior,
   role, or artifact of the repository, and later deliveries need the same
   meaning. A settlement is delivery-scoped when it binds only this issue, this
   pull request, or this change. Keep a delivery-scoped decision in the admitted
   spec. Do not copy it into `.capstan/vocabulary.md`. The implementation commit
   for a repository-scoped term creates or updates `.capstan/vocabulary.md` in
   the same commit as the behavior. Use one `**Term**:` entry per term. Include
   the meaning and the rejected alternative that the triage walk recorded.
   Triage does not create the file. Do not edit `CONTEXT.md`. Do not add a
   stage, a label, a config field, or an executable. Keep #20's per-issue
   Vocabulary and Decisions sections.
   Follow [ladder](ladder.md) before introducing new code. Do not restate the
   ladder. Preserve human changes and do not silently stage unrelated files.
4. Prove each carried finding's original acceptance condition against the code,
   or propose a refutation with concrete evidence. Record unfinished obligations
   explicitly; technical failures stay in implementing recovery, not planning.
   Run all declared final checks and exercise the real user surface. Use the
   exact invocation the brief carries. Record actual
   commands, exit statuses, output/evidence paths, and the resulting head SHA.
5. Prepare PR text with Why, Scope, Tradeoffs, Blast Radius, and Verification.
   Report risks honestly and verify a clean worktree containing the intended commits.
   Finish everything the pack supports; the result cites the pack.

For any effective blocking obligation carried from review, include the red/green/bite
row in the closure-row format the pack carries from
[finding resolution](findings.md); planned or proxy tests are insufficient.

Add `## Acceptance proof`, `## Finding closure proofs`, `## Finding dispositions`,
`## Resulting head`, and `## PR content` to common result headings. Complete when the diff is nonempty and
in scope, the brief's exact declared-check invocations
pass, every carried finding has an evidenced proposed disposition, the user-visible
result is demonstrated, commits contain the intended change, and the tree is clean.
A no-op or already-delivered issue is reconciled with the
coordinator; do not manufacture a change to satisfy the nonempty criterion.

Coordinator independently checks evidence and applies the closure proof gate for
every carried effective blocker. Do not push, and do not create the pull request,
at that transition. Then review.

A new delivery with no remote issue branch or pull request stays on local `capstan/N` through code review and fix. Do not push, and do not create the pull request, at that transition. The secondary reviews the exact local base and head SHAs and their three-dot diff. A fix commit is not pushed merely to start the next review. The closure-proof gate still applies before review. Local CI is the declared checks run on the local machine, including tests and the other commands the plan or repository conventions already name. Do not invent a check from a file extension. Do not parse workflow YAML. A named check that cannot run locally is recorded as not run locally and remains a pre-merge GitHub check. A missing or failing local check uses existing recovery and does not advance toward publication. The publication boundary is the point after local code review converges and base freshness is confirmed. Before the first push, fetch the resolved base. A stale-base ordinary merge that changes the head is a changed candidate. It needs a fresh review of the new local SHAs and three-dot diff, zero effective blockers, and a rerun of affected local CI before the first push. Do not publish the pre-merge head. Then push the exact reviewed `capstan/N` head once without force and create or reconcile one non-draft pull request. Apply the existing marker, `Closes #N`, title suffix, and read-backs. The observed pull-request head must equal the reviewed local head before pre-merge. Before the pull request exists, marked code-review censuses and dispositions are issue comments. After creation, the final converged exact-head census and applicable dispositions go on the pull request and link that issue history. No new marker kind. Do not read, wait for, or rerun GitHub-hosted checks before the publication boundary. Pre-merge owns those checks after publication. Do not use `[skip ci]`, workflow disabling, draft behavior, branch-rule changes, or a synthetic empty commit. This is not a promise of one workflow run. Record why each post-publication push was necessary. If a matching remote branch or marked pull request already exists, preserve it. Do not delete, close, or recreate it to obtain the deferred path.

At the publication boundary, push the exact reviewed `capstan/N` head once without
force, and find or create one non-draft PR on base `main` whose written body
contains both the identity marker `Capstan: owner/repo#N` and a separate line
`Closes #N`. `N` is the delivery issue number in the pull request's repository.
The created title is the subject, a space, then `(#N)`. `N` is not the
pull-request number. The #12 shape is
`Replace the repository tour with one coordinator-written pack per worker launch (#12)`.
The marker stays the identity check. A title suffix is not a substitute for the
marker. A wrong title does not retarget branch `capstan/N` or worktree
`.worktrees/capstan+N`. The keyword is `Closes #N` only. Do not use
`Fixes`. Do not use `owner/repo#N` as the close keyword. Do not close the issue
at create. Observe a push rejection before deciding how to integrate remote
human work; delegate any needed commit/repair to a worker. Read back
PR/head/body after create. Read the title back after create. If the suffix is
missing or different, repair it with `gh pr edit` on the same pull request. Do
not open a second pull request. If the title already ends with ` (#N)` for that
issue, leave it unchanged and do not double the suffix. If `Closes #N` is
missing, add that line on the same pull request. If the body already contains
`Closes #N` for that issue, leave it and do not write the keyword a second
time. Shipping this text does not rewrite already-merged pull requests.
The rule applies to pull requests Capstan creates or next edits after the text
is in force.
Attempt failures use recovery inside implementing rather than the review fix label.
