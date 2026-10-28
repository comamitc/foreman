# Documentation backfill

## Sub-features
- A settled bound: the audience, the workflow, and the canonical destinations.
- One coverage record per in-scope subject, classed `documented`, `stale`, `missing`, or `unverified`.
- Writes chosen by the rule [implementing](../../references/implementing.md) owns ("This file owns documentation completeness").

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes, and state in an issue or in a text invocation that the outcome is documentation backfill, naming the audience and the workflow.
[documentation backfill](../../references/modes/documentation-backfill.md) ("This file owns documentation backfill") owns the procedure.

## Driving it
Invocation: invoke Foreman with the URL or number of an issue that states the documentation-backfill outcome and names the audience and the workflow, or with text that does.
End state: a backfill that changes documentation opens a pull request, and its summary reports coverage, created and updated pages, intentionally unchanged docs, defects, and gaps.
An unchanged in-scope repository produces no diff and no pull request; a repeat backfill adds no duplicate page or section.
Without a settled audience and workflow, nothing is written.

## Gotchas
- A normal feature delivery, init, or resume does not enter backfill.
- A page that states a valid expectation the product breaks is a product defect, not a stale page.
- No map does not block backfill, and backfill does not seed a map.
- A custom documentation layout is preserved and not moved to `docs/` or `.capstan/features`.
