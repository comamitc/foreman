# Plan review — fresh secondary, read-only

The coordinator reads [one-pass planning](plan-convergence.md) and
[finding resolution](findings.md) and extracts the row format into the pack; the
worker's task reading is the brief and the pack; [references/harnesses/shared.md](harnesses/shared.md) ("A worker inherits its host's instructions") owns host instructions.

1. Read the brief and the pack. The pack carries the applicable criteria, the
   current plan text only (never a rejected plan), Open findings `none — single
   review of the initial plan`, the rule extract, the commands the plan names, the evidence-check bite outcomes and any repair as carried evidence, which [references/pack.md](pack.md) ("An evidence check the initial plan writes") owns, and
   the plan's own citations as Named files. Record the candidate plan/spec revision
   and the initial tree. A citation that does not meet [references/pack.md](pack.md) ("Citation rule") is a Standards or Correctness finding with the pack
   row as evidence. Run only the named commands. [brief](../templates/brief.md) ("## Worker constraints") owns reads and gaps; [references/harnesses/shared.md](harnesses/shared.md) ("An operation is one tool call") owns the operation count and the ceiling.
   At the ceiling, write the result and list
   every unchecked criterion, item, citation, or check as a gap.
2. Examine every acceptance criterion and plan item on all applicable axes.
   On the Simplicity axis, judge module shape, including the red flags that
   [references/ladder.md](ladder.md) ("## Module") owns, by the module finding
   in [references/review.md](review.md) step 3. When "## Rules that apply" quotes
   no repository design rule, the finding's claim states that it is out of
   scope for this change, and that finding alone does not make the verdict
   revise. When it quotes one, the finding is in scope with its existing
   severity and confidence.
   A design comparison that does not meet [references/planning.md](planning.md) ("Those designs are compared at equal reuse") is a Simplicity finding, in scope or out of scope as the module finding above is.

   | Axis | Question |
   | --- | --- |
   | Spec | Does it cover the requested behavior without unrequested scope? |
   | Standards | Does it follow repository rules and appropriate verification seams? |
   | Correctness | Can the proposed sequence produce the intended result safely? |
   | Simplicity | Does it follow [ladder](ladder.md)? |

3. Use [review](../templates/review.md) ("## Finding format") for separate axes and grounded findings.
   Produce the complete feedback set in this review, not
   staged subsets. Ground unsafe behavior, missing
   outcomes, and unrequested scope in evidence. Record inapplicable axes with reasons.
4. Return approve or revise, identifying the exact plan reviewed. Verify the tree
   and head are unchanged; write only the result.

Add `## Reviewed plan`, `## Coverage`, `## Spec`, `## Standards`,
`## Correctness`, `## Simplicity`, and `## Verdict` to common result headings.
Complete when all criteria/items are examined against the pack, the complete
feedback set is recorded, the result cites the pack and lists its operations, and
a supported verdict is present.
Coordinator publishes a marked plan-review comment. [one-pass planning](plan-convergence.md) ("## Fixed sequence") owns what follows, and its section ("## Prerequisites versus implementation obligations") owns typed recovery.
