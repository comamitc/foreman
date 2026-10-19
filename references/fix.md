# Fix — fresh primary, write

Enter only for effective blockers from the coordinator-partitioned current review
census. The coordinator extracts [code-review convergence](review-convergence.md)
and [finding resolution](findings.md) into the pack.

The coordinator runs [toolchain](toolchain.md) before this worker launches.

1. Read the brief and the pack. It carries the effective blocking rows with the red command
   and output at the reviewed head, the saved diff, the functions the failing
   commands touch as Named files readable in full, and the failing commands plus
   the relevant final gates. [references/pack.md](pack.md) ("open prior code-review finding") owns the later-round finding carry. Run those. Reconcile any earlier repair effects.
2. Reproduce each effective blocking finding at the exact reviewed head before editing and preserve
   its red command/output. On recovery from partial work, use an isolated scratch
   checkout at that head. Fix its root cause with a regression check that exercises
   the original scenario, or justify a non-executable seam and supply a deterministic
   old/new trace. Follow [ladder](ladder.md). Use the
   smallest coherent diff; avoid adjacent refactors and opportunistic cleanup.
3. Run affected checks and the relevant final gates. Use the exact invocation
   the brief carries, in the order [references/planning.md](planning.md) ("Mark each declared check heavy or not heavy") owns. Commit coherent repairs,
   preserve human work, and verify clean status. Record each check as
   [templates/result.md](../templates/result.md) ("## Checks") defines it, and
   the resulting head and proof for every effective blocking finding, including
   evidence-backed refutations.
4. Write the result; never push or publish it yourself. For every effective blocking finding, include
   the complete red/green/bite row required by [finding resolution](findings.md).

Use [templates/result.md](../templates/result.md) for common result headings and its "## Implementing" section. Complete when every effective blocking finding has a complete proposed
closure row, checks pass, and the worktree is clean. The coordinator checks
declared-check records under [references/harnesses/shared.md](harnesses/shared.md)
("The coordinator accepts a same-head check record"), then applies the closure
proof gate independently. Only
after the gate passes does the coordinator start a fresh review
under the code-review convergence ratchet, even if a refutation left head
unchanged. [references/pack.md](pack.md) ("A code-review pack for round 2 and later instead carries") owns what that review's pack carries.

[references/publication.md](publication.md) owns publication.
