# Plan review — fresh secondary, read-only

Read [finding resolution](findings.md) for new findings and prior-finding closure.

1. Read the admitted spec, proposed plan, repository rules, and code/test evidence
   the plan depends on. Record the candidate plan/spec revision and initial tree.
2. Examine every acceptance criterion and plan item on all applicable axes:

   | Axis | Question |
   | --- | --- |
   | Spec | Does it cover the requested behavior without unrequested scope? |
   | Standards | Does it follow repository rules and appropriate verification seams? |
   | Correctness | Can the proposed sequence produce the intended result safely? |
   | Simplicity | Can it delete, reuse, use the standard library/native platform, or shrink? |

3. Use [review](../templates/review.md) for separate axes and grounded findings.
   Record each finding's original scenario, acceptance condition, correction,
   evidence, and lineage. Independently verify every prior disposition against
   the actual revised plan. Block when the plan prevents the admitted outcome,
   violates safety, or adds substantial unrequested scope; stylistic preference
   is not a blocker. Record inapplicable axes with reasons.
4. Return approve or revise, identifying the exact plan reviewed. Verify the tree
   and head are unchanged; write only the result.

Add `## Reviewed plan`, `## Coverage`, `## Spec`, `## Standards`,
`## Correctness`, `## Simplicity`, and `## Verdict` to common result headings.
Complete when all criteria/items are examined, prior findings are reconciled,
and a supported verdict is present.
Coordinator publishes a marked plan-review comment. Approve enters implementing;
actionable revision returns to planning with the complete finding set and applies
[plan convergence](plan-convergence.md) before dispatching the next worker.
