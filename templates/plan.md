<!-- capstan:plan OWNER/REPO#N -->
# Plan

Specification revision / issue body updatedAt:
Observed head / base:
Planning step (initial / single correction) / review artifact / correction launch:

## Current behavior and data shape

Trace concrete repository patterns, inputs, outputs, and affected callers.

## Simplicity decision

Why this is the smallest sufficient approach after checking reuse/native options.

## Ordered items

An Ordered items row for non-trivial logic names, inside its "Verification command and failure signal" cell, the acceptance criterion its check is derived from, the seam (the owning module's interface) it drives through, and its test tier; a Markdown-only or exempt row names the Markdown-only rule or the implementing exemption in that cell instead of a seam or tier. [references/ladder.md](../references/ladder.md) ("## Check") owns the derivation, the seam, and the tiers, and [references/implementing.md](../references/implementing.md) step 2 owns the exemption.

| Item | Acceptance criterion | Observable outcome / affected area | Verification command and failure signal | Risk |
| --- | --- | --- | --- | --- |
| 1 | AC 1 | | | |

## Documentation impact

[references/planning.md](../references/planning.md) owns this field. [references/implementing.md](../references/implementing.md) owns documentation completeness.

- Behavior:
- Canonical path:
- Decision:
- Verification:

## Final proof

Repository checks and real user-surface demonstration.

[references/planning.md](../references/planning.md) step 3 ("A check script the plan writes") owns how a planned check script is built.

## Revision response

For every prior actionable finding: origin, original failure scenario, acceptance
condition, proposed correction/refutation, changed plan location, and supporting
evidence. Identify unresolved items; distinguish observed checks from planned tests.
Use [finding resolution](../references/findings.md), or “none” for an initial plan.
For the single correction, cover ALL review findings in this pass and update
affected plan items. Include implementation tasks/checks and actual prerequisites.
These are proposed treatments, not verified closure. Preserve unfinished items
explicitly in the implementation handoff; there is no second plan review.
