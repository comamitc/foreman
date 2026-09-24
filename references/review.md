# Code review — fresh secondary, read-only

The coordinator reads [finding resolution](findings.md) for new findings and
prior-finding closure, then [code-review convergence](review-convergence.md) for
policy, partitioning, ratchet, and round ceilings. It extracts the row format and
applicable policy into the pack; the worker reads the brief and the pack, nothing
else.

[references/contract.md](contract.md) owns feature-map resolution and heading shape.

[references/implementing.md](implementing.md) owns the feature-map write.

[references/planning.md](planning.md) owns feature-map adoption.

[references/planning.md](planning.md) owns the feature-map audit.

Block a second map. Block an internal-only feature file. Block an unverifiable claim.

Deleting a still-true claim to make the audit pass blocks. Weakening a proof to make the audit pass blocks.

[references/planning.md](planning.md) owns the ADR rule.

Block a missing required ADR. Block a broken supersession link. Block invented rationale. Block a contradiction with the diff.

The ADR is a claim. Code and checks are proof.

Review treats the map as a claim. The diff and the live command remain the
proof. Removing a proof to pass blocks. Omitting a required map update blocks.
A required map update is the same-commit feature-file change when reachability,
drive steps, or the proof change, and one feature file plus one index line when
a new user-facing behavior is added to a present map.

[references/implementing.md](implementing.md) owns which existing page must
change. Omitting a required page update blocks. Deleting a still-true statement
to avoid the update blocks.

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

Use [templates/result.md](../templates/result.md) for common and review result headings.

Review names [telemetry.md](telemetry.md) as the owner of the ledger row.

Complete when the saved diff and carried repair rows have been examined under the
review ratchet, findings are grounded, prior lineages are reconciled, the result
cites the pack, and tree/head are unchanged. The
coordinator independently partitions findings under the effective policy. [references/publication.md](publication.md)
owns census placement. Effective blockers
enter fix while the round allowance remains; zero effective blockers enters
pre-merge; a final allowed review with blockers adds the review-exhausted blocked
overlay. Any later head change requires the confirmation behavior in code-review
convergence before readiness.

[references/publication.md](publication.md) owns publication.
