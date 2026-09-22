# Plan review — fresh secondary, read-only

The coordinator reads [one-pass planning](plan-convergence.md) and
[finding resolution](findings.md) and extracts the row format into the pack; the
worker reads the brief and the pack, nothing else.
This is the single review of the initial plan, not a review of its correction.

1. Read the brief and the pack. The pack carries the applicable criteria, the
   current plan text only (never a rejected plan), Open findings `none — single
   review of the initial plan`, the rule extract, the commands the plan names, and
   the plan's own citations as Named files. Record the candidate plan/spec revision
   and the initial tree. Open a named file only to confirm a cited line; a citation
   that does not match the file is a Standards or Correctness finding with the pack
   row as evidence. A path the pack does not name is a gap under Risks and
   unresolved items, not a search. Run only the named commands. Count each tool
   call, one read call or one shell command, however many files it names, as a
   numbered line under
   `## Checks`; at the ceiling written in
   the brief header, stop, write the result, and list every unchecked criterion,
   item, citation, or check as a gap. A compact pack's single named file and check
   are the whole read allowance.
2. Examine every acceptance criterion and plan item on all applicable axes.
   Judge simplicity by [ladder](ladder.md). Do not restate the ladder.

   | Axis | Question |
   | --- | --- |
   | Spec | Does it cover the requested behavior without unrequested scope? |
   | Standards | Does it follow repository rules and appropriate verification seams? |
   | Correctness | Can the proposed sequence produce the intended result safely? |
   | Simplicity | Does it follow [ladder](ladder.md)? |

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
Complete when all criteria/items are examined against the pack, the complete
feedback set is recorded, the result cites the pack and lists its operations, and
a supported verdict is present.
Coordinator publishes a marked plan-review comment. Approve enters implementing;
revise sends the complete finding set to the single correction pass, then directly
to implementing. Actual missing prerequisites use typed recovery. Independent
verification of corrections happens in code review, not another plan-review.
