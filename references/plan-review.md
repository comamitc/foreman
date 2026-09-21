# Plan review — fresh secondary, read-only

Read [one-pass planning](plan-convergence.md) and [finding resolution](findings.md).
This is the single review of the initial plan, not a review of its correction.

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
   evidence, and lineage. Produce the complete feedback set in this review, not
   staged subsets. Distinguish actual prerequisites from implementation obligations;
   severity alone does not require a planning stop. Ground unsafe behavior, missing
   outcomes, and unrequested scope in evidence. Record inapplicable axes with reasons.
4. Return approve or revise, identifying the exact plan reviewed. Verify the tree
   and head are unchanged; write only the result.

Add `## Reviewed plan`, `## Coverage`, `## Spec`, `## Standards`,
`## Correctness`, `## Simplicity`, and `## Verdict` to common result headings.
Complete when all criteria/items are examined, the complete feedback set is recorded,
and a supported verdict is present.
Coordinator publishes a marked plan-review comment. Approve enters implementing;
revise sends the complete finding set to the single correction pass, then directly
to implementing. Actual missing prerequisites use typed recovery. Independent
verification of corrections happens in code review, not another plan-review.
