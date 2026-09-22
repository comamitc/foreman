# Code review — fresh secondary, read-only

The coordinator reads [finding resolution](findings.md) for new findings and
prior-finding closure and extracts its row format into the pack; the worker reads
the brief and the pack, nothing else.

1. Read the brief and the pack. The saved `git diff BASE_SHA...HEAD_SHA` in the
   pack is the candidate at the recorded SHAs; record them, the initial status,
   and the spec revision. The pack carries every carried finding row with the
   primary's proposed disposition and candidate location, not prior plan-review
   essays or implementing narratives. Confirm each cited line and each row's
   original scenario against the saved diff; a citation that does not match is a
   finding. Run only the named checks and record the observed exit at HEAD. Callers
   are the ones the pack names; the diff carries the rest. A path the pack does not
   name is a gap under Risks and unresolved items, not a search. Count each file
   read and command as a numbered line under `## Checks`; stop when the pack has
   been checked or at the ceiling in the brief header, listing unchecked rows as
   gaps. A compact pack's single named file and check are the whole read allowance.
2. State a risk assessment. Allocate depth to actual uncertainty and impact.
   For high-risk changes, inspect every applicable failure surface; for low-risk
   changes, cover all applicable axes without inventing hypothetical problems.
3. Keep four separate sections: Spec (requested behavior/scope), Standards (repo
   rules and verification), Correctness (reachable failures/invariants), and
   Simplicity (delete/reuse/native capability/shrink). Do not merge away disagreement.
4. For every actionable finding, record axis, severity, file/symbol or plan item,
   claim, evidence, and correction in [review](../templates/review.md). Blocking
   correctness claims need a reachable call path, reproduced failure, violated
   invariant, or direct spec contradiction. Omit unsupported hypotheticals or mark
   them non-blocking. Unrelated pre-existing defects are outside blocking scope.
5. Independently verify every carried plan finding and prior code disposition
   against its original scenario and acceptance condition. The first code review
   must reconcile planning findings too; a plan correction is not closure.
   Return the whole current census, reconciled lineage,
   and verdict. Confirm no tree/head mutation.

| Severity | Meaning | Effect |
| --- | --- | --- |
| blocker | security, data loss, irreversible corruption, fundamentally wrong implementation | fix |
| major | required behavior missing/incorrect, unsafe behavior, substantial unrequested scope | fix |
| minor | maintainability/simplicity improvement that does not prevent the outcome | non-blocking |

Add `## Reviewed head and base`, `## Risk assessment`, `## Coverage`, `## Spec`,
`## Standards`, `## Correctness`, `## Simplicity`, and `## Verdict` to common results.
Complete when the saved diff and carried rows have been examined, findings are
grounded, the result cites the pack, and tree/head are unchanged. Coordinator
publishes the marked census on the PR at the reviewed SHAs. Blocker/major enters
fix; otherwise pre-merge.
Any later head change requires fresh cumulative review before readiness.
