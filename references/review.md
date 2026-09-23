# Code review — fresh secondary, read-only

The coordinator reads [finding resolution](findings.md) for new findings and
prior-finding closure, then [code-review convergence](review-convergence.md) for
policy, partitioning, ratchet, and round ceilings. It extracts the row format and
applicable policy into the pack; the worker reads the brief and the pack, nothing
else.

`features` is the optional feature-map field. Resolution order is invocation,
then `CAPSTAN_FEATURES`, then the `.capstan.json` field `features`, then
`.capstan/features` when that directory contains `README.md`. `features: null`
disables the map. A missing explicit path is recorded in `run.md`. The run
continues with no map. A missing map does not block the delivery.

Review treats the map as a claim. The diff and the live command remain the
proof. Removing a proof to pass blocks. Omitting a required map update blocks.
A required map update is the same-commit feature-file change when reachability,
drive steps, or the proof change, and one feature file plus one index line when
a new user-facing behavior is added to a present map.

Each feature file uses only these four H2 headings and no harness name:
`Sub-features`, `How to get to it (user POV)`, `Driving it`, `Gotchas`.
`Driving it` states the repository commands and the observable end state. A
harness name, a host skill path, or another section does not satisfy the shape.
No Launch, Doctor, Evidence, Cleanup, or Helpers section.

1. Read the brief and the pack. The saved `git diff BASE_SHA...HEAD_SHA` in the
   pack is the candidate at the recorded SHAs; record them, the initial status,
   and the spec revision. Apply the effective policy and review ratchet extracted
   into the pack: round 1 covers the cumulative diff; later rounds verify prior
   effective blockers and the repair delta, with the policy's stated exceptions.
   The pack carries every carried finding row with the
   primary's proposed disposition and candidate location, not prior plan-review
   essays or implementing narratives. Confirm each cited line and each row's
   original scenario against the saved diff; a citation that does not match is a
   finding. Run only the named checks and record the observed exit at HEAD. Callers
   are the ones the pack names; the diff carries the rest. A path the pack does not
   name is a gap under Risks and unresolved items, not a search. Count each tool
   call, one read call or one shell command, however many files it names, as a
   numbered line under
   `## Checks`; stop when the pack has
   been checked or at the ceiling in the brief header, listing unchecked rows as
   gaps. A compact pack's single named file and check are the whole read allowance.
2. State a risk assessment. Allocate depth to actual uncertainty and impact.
   For high-risk changes, inspect every applicable failure surface; for low-risk
   changes, cover all applicable axes without inventing hypothetical problems.
3. Keep four separate sections: Spec (requested behavior/scope), Standards (repo
   rules and verification), Correctness (reachable failures/invariants), and
   Simplicity ([ladder](ladder.md)). Do not merge away disagreement. Do not
   restate the ladder. A new dependency, a new file, or a reimplementation of
   an existing function is unrequested scope and blocks. A pure "this could be
   shorter" note stays minor. Keep one judge. Do not add a second review
   station. Do not install a ponytail skill.
4. For every actionable finding, record axis, severity, confidence, category,
   file/symbol or plan item, claim, evidence, and correction in
   [review](../templates/review.md). Blocking
   correctness claims need a reachable call path, reproduced failure, violated
   invariant, or direct spec contradiction. Omit unsupported hypotheticals or mark
   them non-blocking. Unrelated pre-existing defects are outside blocking scope.
5. Independently verify every carried plan finding and prior code disposition
   against its original scenario and acceptance condition. The first code review
   must reconcile planning findings too; a plan correction is not closure.
   Return the whole current census, reconciled lineage,
   and verdict. Confirm no tree/head mutation.

Add `## Reviewed head and base`, `## Risk assessment`, `## Coverage`, `## Spec`,
`## Standards`, `## Correctness`, `## Simplicity`, `## Policy partition`, and
`## Verdict` to common results.
Complete when the saved diff and carried repair rows have been examined under the
review ratchet, findings are grounded, prior lineages are reconciled, the result
cites the pack, and tree/head are unchanged. The
coordinator independently partitions findings under the effective policy and
publishes the marked census on the PR at the reviewed SHAs. Effective blockers
enter fix while the round allowance remains; zero effective blockers enters
pre-merge; a final allowed review with blockers adds the review-exhausted blocked
overlay. Any later head change requires the confirmation behavior in code-review
convergence before readiness.

A new delivery with no remote issue branch or pull request stays on local `capstan/N` through code review and fix. Do not push, and do not create the pull request, at that transition. The secondary reviews the exact local base and head SHAs and their three-dot diff. A fix commit is not pushed merely to start the next review. The closure-proof gate still applies before review. Local CI is the declared checks run on the local machine, including tests and the other commands the plan or repository conventions already name. Do not invent a check from a file extension. Do not parse workflow YAML. A named check that cannot run locally is recorded as not run locally and remains a pre-merge GitHub check. A missing or failing local check uses existing recovery and does not advance toward publication. The publication boundary is the point after local code review converges and base freshness is confirmed. Before the first push, fetch the resolved base. A stale-base ordinary merge that changes the head is a changed candidate. It needs a fresh review of the new local SHAs and three-dot diff, zero effective blockers, and a rerun of affected local CI before the first push. Do not publish the pre-merge head. Then push the exact reviewed `capstan/N` head once without force and create or reconcile one non-draft pull request. Apply the existing marker, `Closes #N`, title suffix, and read-backs. The observed pull-request head must equal the reviewed local head before pre-merge. Before the pull request exists, marked code-review censuses and dispositions are issue comments. After creation, the final converged exact-head census and applicable dispositions go on the pull request and link that issue history. No new marker kind. Do not read, wait for, or rerun GitHub-hosted checks before the publication boundary. Pre-merge owns those checks after publication. Do not use `[skip ci]`, workflow disabling, draft behavior, branch-rule changes, or a synthetic empty commit. This is not a promise of one workflow run. Record why each post-publication push was necessary. If a matching remote branch or marked pull request already exists, preserve it. Do not delete, close, or recreate it to obtain the deferred path.
