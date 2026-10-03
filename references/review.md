# Code review — fresh secondary, read-only

The coordinator reads [finding resolution](findings.md) for new findings and
prior-finding closure, then [code-review convergence](review-convergence.md) for
policy, partitioning, ratchet, and round ceilings. It extracts the row format and
applicable policy into the pack; the worker reads the brief and the pack, nothing
else.

[references/contract.md](contract.md) owns feature-map resolution and heading shape.

[references/implementing.md](implementing.md) owns the feature-map write.

[modes/feature-map-adoption.md](modes/feature-map-adoption.md) ("This file owns feature-map adoption") owns feature-map adoption. Trigger: the admitted issue or the text invocation states that outcome.
[modes/documentation-backfill.md](modes/documentation-backfill.md) ("This file owns documentation backfill") owns documentation backfill. Trigger: the admitted issue or the text invocation states that outcome.

[modes/feature-map-audit.md](modes/feature-map-audit.md) ("This file owns the feature-map audit") owns the feature-map audit. Trigger: the admitted issue or the text invocation states that outcome.

Block a second map. Block an internal-only feature file. Block an unverifiable claim.

[modes/adr.md](modes/adr.md) ("This file owns the ADR rule") owns the ADR rule. Trigger: repository instructions or the admitted issue require an ADR.

[modes/lessons.md](modes/lessons.md) ("This file owns the lesson rule") owns the lesson rule and lesson maintenance. Trigger: repository instructions name a lessons path, or the admitted issue or the text invocation states lesson maintenance.

Review treats the map as a claim. The diff and the live command remain the
proof. Removing a proof to pass blocks. Omitting a required map update blocks.
A required map update is the same-commit feature-file change when reachability,
drive steps, or the proof change, and one feature file plus one index line when
a new user-facing behavior is added to a present map.

[references/implementing.md](implementing.md) owns documentation completeness.
Omitting required canonical coverage blocks. An unsupported behavior claim
blocks. Rewriting a valid documented invariant to fit a regression blocks.
Deleting a still-true statement to avoid the update blocks. Changed-head
invalidation follows `references/telemetry.md`
("A changed spec or a changed head invalidates the affected claims").

Invented historical architectural rationale blocks. A claim of an exhaustive
audit outside the admitted scope blocks. A manufactured diff, duplicate page,
or duplicate section on an unchanged repository blocks.

A populated Documentation impact or Documentation disposition section is not
sufficient. Compare it with the diff. Do not mark the claim complete when the
path or decision does not match the diff, or when the disposition is
`unverified`.

The review pack copies every Documentation impact path into Named files and
every verification into Checks. Unknown paths stay `discovery gap:`.

1. Read the brief and the pack. The saved `git diff BASE_SHA...HEAD_SHA` in the
   pack is the candidate at the recorded SHAs; record them, the initial status,
   and the spec revision. Apply the effective policy and review ratchet extracted
   into the pack: round 1 covers the cumulative diff; later rounds verify prior
   effective blockers and the repair delta, with the policy's stated exceptions.
   The pack carries every carried finding row with the
   primary's proposed disposition and candidate location, not prior plan-review
   essays or implementing narratives. The exception is each applicable red or
   fault-injection observation carried under Checks as evidence already
   recorded. [references/pack.md](pack.md) owns that carry.
   Confirm each cited line and each row's
   original scenario against the saved diff; a citation that does not match is a
   finding. Run only the named checks and record the observed exit at HEAD. Callers
   are the ones the pack names; the diff carries the rest. A path the pack does not
   name is a gap under Risks and unresolved items, not a search.
   Count each tool call, one read call or one shell command, however many files it names, as a numbered line under `## Checks`, except a host-instruction read ([references/harnesses/shared.md](harnesses/shared.md) "A host-instruction read is not an operation");
   stop when the pack has been checked or at the ceiling in the brief header,
   listing unchecked rows as gaps. A compact pack's single named file and check
   are the whole read allowance.
2. State a risk assessment. Allocate depth to actual uncertainty and impact.
   For high-risk changes, inspect every applicable failure surface; for low-risk
   changes, cover all applicable axes without inventing hypothetical problems.
3. Keep four separate sections: Spec (requested behavior/scope), Standards (repo
   rules and verification), Correctness (reachable failures/invariants), and
   Simplicity ([ladder](ladder.md)). Do not merge away disagreement. Do not
   restate the ladder. A new dependency, a new file, or a reimplementation of
   an existing function is unrequested scope and blocks. A pure "this could be
   shorter" note stays minor. Keep one judge. Do not install a ponytail skill.
   For each applicable new or changed check, name the observable contract, a
   plausible defect and its failure signal, and whether a
   mock or stub suppresses that failure. A check that
   restates the implementation's constant, a mock setup that cannot fail, or a
   source-text or field-presence proxy is not sufficient behavioral proof. Allow
   a structural or source-text check when the
   structure is itself the accepted contract, and state that justification.
   [references/implementing.md](implementing.md) owns the exemption.
   Do not restate it. Prefer red evidence at the old head, or a
   cheap targeted fault injection, when either is meaningful. Do not require
   mutation testing on every change, a new test framework, or
   per-function suites. [references/ladder.md](ladder.md) owns that limit
   (`references/ladder.md` under "Check").
   Judge the required check's test tier against that rule on the Standards
   axis. "## Rules that apply" in the review pack is the only channel for a
   target repository test-tier rule. When it quotes none, a lower tier without
   a stated reason, or a mock or stub of an owned collaborator offered as the
   required check, is recorded on the Standards axis with its claim stating
   that it is out of scope for this change;
   [references/review-convergence.md](review-convergence.md) ("Out-of-scope and
   pre-existing observations are advisory regardless of their raw severity")
   owns that partition. When it quotes one, the finding is in scope and uses
   the existing severity and confidence calibration in
   [references/review-convergence.md](review-convergence.md).
   Judge the red or fault-injection evidence the pack carries. Trace that
   evidence against the saved diff when needed.
   When the pack carries a changed evidence check, judge whether the change weakened it; [references/pack.md](pack.md) ("An evidence check is bitten before the brief that depends on it launches") owns the rule.
   Do not change the tree.
   Do not produce the red evidence. A correction uses the
   existing implementing or fix write station. On round 1, apply this rule to
   every applicable new or changed check in the cumulative diff. On a later
   round, apply it only to checks the repair delta adds or changes. Prior
   effective blockers still follow the ratchet.
   [references/review-convergence.md](review-convergence.md)
   owns severity, confidence, partition, the ratchet, and
   `max_review_fix_rounds`. Do not change them. Do not add a severity mapping.
   A style preference alone is never a blocker.
   Record the finding on the Standards axis in the existing finding format.
   Cite an admitted acceptance criterion or a reachable defect.
   [references/findings.md](findings.md) owns closure proof.
   Do not restate that gate.
   On the Standards axis, independently assess each applicable policy row the
   pack carries under `## Rules that apply` or on a compact `Rule:` line;
   [telemetry.md](telemetry.md) owns the policy row. An applicable rule with no
   evidence is a finding in the existing finding format;
   [references/review-convergence.md](review-convergence.md) partitions it.
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
