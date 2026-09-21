# Fix — fresh primary, write

Enter only for blocker/major findings from the current review census.

1. Read every blocking finding, its evidence, the admitted spec, accepted plan,
   current diff, and applicable conventions. Reconcile any earlier repair effects.
2. Reproduce or trace each finding. Fix its root cause with a regression check
   when a meaningful seam exists, or refute it with concrete evidence. Use the
   smallest coherent diff; avoid adjacent refactors and opportunistic cleanup.
3. Run affected checks and the relevant final gates. Commit coherent repairs,
   preserve human work, and verify clean status. Record resulting head and proof
   for every finding, including evidence-backed refutations.
4. Write the result; never push or publish it yourself.

Add `## Finding dispositions` and `## Resulting head` to common results.
Complete when every blocking finding is fixed or concretely refuted, checks pass,
and the worktree is clean. Coordinator pushes normally and starts a fresh review
of the entire cumulative diff, even if a refutation left head unchanged. The new
census replaces prior finding authority; old finding IDs do not veto fresh evidence.
