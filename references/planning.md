# Planning — fresh primary, read-only

Before dispatch, the coordinator applies [one-pass planning](plan-convergence.md).
The single correction and its brief include [finding resolution](findings.md).

1. Read the admitted spec, repository conventions, affected modules, tests, and
   callers. Trace existing behavior and cite concrete patterns rather than assuming
   a framework or file structure. Record the initial head and worktree status.
2. Name input/output and data shapes before implementation mechanics. Apply the
   simplicity ladder: need → existing code → standard library → platform → installed
   dependency → one line → minimum new code. Justify any new dependency or abstraction.
3. Produce [plan](../templates/plan.md). Map every acceptance criterion to ordered
   items with an observable outcome, affected area, verification command/seam,
   failure signal, and risk. Name final repository checks and real user-surface proof.
   Scale the plan to the change: a small CLI option needs a short behavior map,
   not repeated explanations of the same command in several sections.
4. In the single correction pass, address ALL findings from the complete review.
   For each original scenario and acceptance condition, update the affected plan
   items and implementation checks, propose an evidence-backed refutation, or
   identify an actual prerequisite. Carry technical obligations into implementation
   for code-level verification. Preserve settled scope and report any omissions.
5. Verify unchanged tree/head and write only the assigned result.

Add `## Plan`, `## Acceptance mapping`, and `## Revision response` to the common
result headings. Complete when every acceptance criterion is covered, every item
has observable verification and a failure signal, every prior finding has a
supported proposed disposition, repository gates are named, and
the tree is unchanged. The coordinator publishes the plan with its specification
revision. The initial plan enters plan-review; the correction enters implementing
with the complete finding handoff, without another plan review. Incomplete output
follows the recovery rules in one-pass planning.
