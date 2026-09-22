# Code review — fresh secondary, read-only

Read [finding resolution](findings.md) for new findings and prior-finding closure,
then [code-review convergence](review-convergence.md) for policy, partitioning,
ratchet, and round ceilings.

1. Record exact candidate head and base SHAs, initial status, spec revision, and
   implementation plan and full planning finding handoff, including proposed
   refutations and unfinished correction items. Inspect the cumulative
   `git diff BASE_SHA...HEAD_SHA`, changed code, materially affected callers,
   relevant tests, and prior repair evidence.
2. State a risk assessment. Allocate depth to actual uncertainty and impact.
   For high-risk changes, inspect every applicable failure surface; for low-risk
   changes, cover all applicable axes without inventing hypothetical problems.
3. Keep four separate sections: Spec (requested behavior/scope), Standards (repo
   rules and verification), Correctness (reachable failures/invariants), and
   Simplicity (delete/reuse/native capability/shrink). Do not merge away disagreement.
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
Complete when full diff and repair evidence have been examined, findings are
grounded, prior lineages are reconciled, and tree/head are unchanged. The
coordinator independently partitions findings under the effective policy and
publishes the marked census on the PR at the reviewed SHAs. Effective blockers
enter fix while the round allowance remains; zero effective blockers enters
pre-merge; a final allowed review with blockers adds the review-exhausted blocked
overlay. Any later head change requires the confirmation behavior in code-review
convergence before readiness.
