# Planning — fresh primary, read-only

Before a revision, the coordinator applies [plan convergence](plan-convergence.md).
Revisions and their briefs must include [finding resolution](findings.md).

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
4. If revising, propose a correction or evidence-backed refutation for every
   actionable finding against its original scenario and acceptance condition.
   Include the diagnosed repair strategy when escalated. Preserve settled scope;
   surface missing product decisions to the coordinator rather than choosing
   consequential new behavior.
5. Verify unchanged tree/head and write only the assigned result.

Add `## Plan`, `## Acceptance mapping`, and `## Revision response` to the common
result headings. Complete when every acceptance criterion is covered, every item
has observable verification and a failure signal, every prior finding has a
supported proposed disposition, repository gates are named, and
the tree is unchanged. The coordinator publishes the plan with its specification
revision and advances to plan-review. A failure uses shared recovery.
