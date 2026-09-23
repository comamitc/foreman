# Fix — fresh primary, write

Enter only for effective blockers from the coordinator-partitioned current review
census. The coordinator extracts [code-review convergence](review-convergence.md)
and [finding resolution](findings.md) into the pack; the
primary proposes closure, the coordinator gates its proof, and the fresh secondary
reviews the cumulative candidate. Preserve original scenarios and acceptance
conditions.

The coordinator runs [toolchain](toolchain.md) before this worker launches.

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

Use [templates/result.md](../templates/result.md) for common and fix result headings. Complete when every effective blocking finding has a complete proposed
closure row, checks pass, and the worktree is clean. The coordinator then applies
the closure proof gate independently. An incomplete or non-discriminating row stays
in fix recovery; it is not pushed for a secondary reviewer to rediscover. Only
after the gate passes does the coordinator start a fresh review
under the code-review convergence ratchet, even if a refutation left head
unchanged. The pack carries the cumulative diff and identifies the repair delta. The new
census replaces prior finding authority with explicit reconciliation; old finding
IDs do not veto fresh evidence or disappear without a supported disposition.

[references/publication.md](publication.md) owns publication.
