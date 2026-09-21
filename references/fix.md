# Fix — fresh primary, write

Enter only for blocker/major findings from the current review census.
Read [finding resolution](findings.md); the primary proposes closure, the coordinator
gates its proof, and the fresh secondary reviews the cumulative candidate. Preserve
original scenarios and acceptance conditions.

1. Read every blocking finding, its evidence, the admitted spec, implementation plan,
   current diff, and applicable conventions. Reconcile any earlier repair effects.
2. Reproduce each finding at the exact reviewed head before editing and preserve
   its red command/output. On recovery from partial work, use an isolated scratch
   checkout at that head. Fix its root cause with a regression check that exercises
   the original scenario, or justify a non-executable seam and supply a deterministic
   old/new trace. Use the smallest coherent diff; avoid adjacent refactors and
   opportunistic cleanup.
3. Run affected checks and the relevant final gates. Commit coherent repairs,
   preserve human work, and verify clean status. Record resulting head and proof
   for every finding, including evidence-backed refutations.
4. Write the result; never push or publish it yourself. For every finding, include
   the complete red/green/bite row required by [finding resolution](findings.md).

Add `## Finding closure proofs`, `## Finding dispositions`, and `## Resulting head`
to common results. Complete when every blocking finding has a complete proposed
closure row, checks pass, and the worktree is clean. The coordinator then applies
the closure proof gate independently. An incomplete or non-discriminating row stays
in fix recovery; it is not pushed for a secondary reviewer to rediscover. Only
after the gate passes does the coordinator push normally and start a fresh review
of the entire cumulative diff, even if a refutation left head unchanged. The new
census replaces prior finding authority with explicit reconciliation; old finding
IDs do not veto fresh evidence or disappear without a supported disposition.
