<!-- foreman:plan OWNER/REPO#N -->
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

## Decomposition

[references/planning.md](../references/planning.md) step 3 ("proposes a decomposition only when") owns when a plan proposes one and its file condition. A plan that proposes none writes `none` in place of the table.

| Child | Title | Parent criteria | Files | Depends on |
| --- | --- | --- | --- | --- |
| C1 | | AC 1 | | none |

Each parent acceptance criterion appears in exactly one Parent criteria cell. Depends on lists other Child keys, or `none`.

## Sentences outside their rule owner

Each row is a sentence the plan proposes to add outside the file that owns the rule the sentence concerns. [CONTRIBUTING.md](../CONTRIBUTING.md) ("**Restated rule.**") owns how review compares these rows with their owners.

| Proposed sentence | Owner file link | Owner's stable anchor | One fact the owner's text does not state |
| --- | --- | --- | --- |
| | | | |

A row whose sentence adds no such fact is a bare pointer: the sentence names the owner file and anchor and states no behavior, and its last cell reads "bare pointer". A plan that proposes no such sentence writes "none" in place of the table.

## Documentation impact

[references/planning.md](../references/planning.md) owns this field. [references/implementing.md](../references/implementing.md) owns documentation completeness.

- Behavior:
- Canonical path:
- Decision:
- Verification:

## Final proof

Repository checks and real user-surface demonstration.

| Order | Declared check (exact command) | Heavy |
| --- | --- | --- |
| 1 | | |

[references/planning.md](../references/planning.md) step 3 ("Mark each declared check heavy or not heavy") owns the marks and the order.

[references/planning.md](../references/planning.md) step 3 ("A check script the plan writes") owns how a planned check script is built.

## Revision response

Every prior actionable finding as [finding resolution](../references/findings.md) ("## Record the obligation")
records it, with its changed plan location, or “none” for an initial plan.
[One-pass planning](../references/plan-convergence.md) ("One correction means one pass over all N findings")
owns the correction's coverage and handoff, and [one-pass planning](../references/plan-convergence.md)
("If a finding was omitted or inadequately treated") owns unresolved obligations.
