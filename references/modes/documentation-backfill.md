# Documentation backfill

Run it only when the admitted issue or the text invocation states that the outcome is documentation backfill.

This file owns documentation backfill.

Settle the audience, the workflow, and the canonical destinations before any write. If that bound is absent, do not invent a whole-repository scope and do not write.

Inventory in-scope source, entry points, tests, configuration, and existing authoritative docs. Classify each in-scope subject as `documented`, `stale`, `missing`, or `unverified`. Do not claim an exhaustive audit outside that scope. An unnamed path stays a gap.

`documented` means the page and the current source or observed behavior agree. `stale` means the page disagrees with current source or observed behavior, and the page is the defective artifact. `missing` means the bound requires a statement and no suitable canonical page has it. `unverified` means there is no source and no observation. A page that states a valid expectation while the product disagrees is not `stale`. It is a product defect. Do not change the page to match the defect.

One coverage record names one in-scope subject, one of those four classes, and one evidence pointer. The pointer is a source `path:line` or a command and the observed result. The action is the write selected by the documentation-completeness and canonical-page eligibility rule owned by [implementing](../implementing.md) ("This file owns documentation completeness" and "Prefer that existing page when it is a suitable destination"), or a mode-specific result of no-change, explicit gap, or product-defect handoff. Do not restate that rule.

Point at the adoption and audit procedures owned by `references/modes/feature-map-adoption.md` ("This file owns feature-map adoption") and `references/modes/feature-map-audit.md` ("This file owns the feature-map audit"). Do not copy their procedure clauses. Backfill does not enter adoption or the audit. Enter either mode only when its own outcome is admitted. An optional map may link to a canonical page without copying that page. An absent or disabled map does not block backfill and does not get seeded.

Use the documentation-completeness and canonical-page eligibility rule owned by [implementing](../implementing.md) ("This file owns documentation completeness" and "Prefer that existing page when it is a suitable destination"), including the same-commit write ("Write the correction in the same commit as the behavior"). Do not restate that rule. Do not add a second write rule. Preserve a custom documentation layout. Do not move that layout to `docs/` or to `.capstan/features`.

Separate observed current behavior, intended behavior, known defects, and unknowns. Do not invent historical architectural rationale. Do not rewrite a valid expectation to excuse a regression. Do not delete a still-true statement.

Every material new or corrected claim cites source or an observed result. Run a runnable example when its prerequisite is present. Record the target repository's exact declared command, the exit status, and the observed output of that run. If the prerequisite is absent, record an explicit gap. Do not fabricate success. A present prerequisite with a skipped or failed example is a failure.

A created page or section maps to `added`. An updated page maps to `updated`. A checked page with no write maps to `intentionally unchanged`. A gap, an unavailable prerequisite, or an unverified claim maps to `unverified` and row state `unresolved`. A product defect is a handoff in the summary. Contradictory evidence stays `unresolved` ([telemetry](../telemetry.md) under "Ledger, pile, and deletion"). Do not add a fifth disposition word. [telemetry](../telemetry.md) owns those four words under "Ledger, pile, and deletion".

The summary reports coverage, created pages, updated pages, intentionally unchanged docs, defects, and gaps, with the disposition map above.

An unchanged in-scope repository produces no diff. A second backfill of that same unchanged repository does not add a duplicate page, a duplicate section, or a changelog line. The second diff is empty. Do not manufacture a commit to satisfy a nonempty-diff rule. [implementing](../implementing.md) owns that reconciliation ("A no-op or already-delivered issue is reconciled").

Evidence follows the terminal outcome. A diff-producing backfill links its issue, its pull request, its head, and its logs. A clean no-op or a repeated backfill opens no pull request. It links the admitted issue or reconciliation record, the unchanged head, empty `git status --porcelain`, empty `git diff`, and proof that no duplicate was created.

Do not add a generator or OpenSpec. Admission is the outcome sentence. `features` remains the map switch only.

Acceptance is the normal pipeline and reviewer evidence on the diff.
