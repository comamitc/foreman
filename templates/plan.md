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

Every prior actionable finding as [finding resolution](../references/findings.md) ("## Record the obligation")
records it, with its changed plan location, or “none” for an initial plan.
[One-pass planning](../references/plan-convergence.md) ("One correction means one pass over all N findings")
owns the correction's coverage and handoff, and [one-pass planning](../references/plan-convergence.md)
("If a finding was omitted or inadequately treated") owns unresolved obligations.
