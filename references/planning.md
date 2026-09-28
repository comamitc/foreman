# Planning — fresh primary, read-only

Before dispatch, the coordinator applies [one-pass planning](plan-convergence.md),
reads [finding resolution](findings.md) for the correction, and writes the pack;
the worker reads the brief and the pack only.

[contract](contract.md) owns feature-map resolution and heading shape.

[implementing](implementing.md) owns the feature-map write.

This file owns feature-map adoption.

Run adoption only when the admitted issue or the text invocation states that the outcome is feature-map adoption. A normal feature delivery, init, or resume does not enter adoption.

Before the plan names files, inventory the target repository. Record what is authoritative. Inventory the contributor instructions, the README, the existing documentation indexes, the ADR location when one is present, the user-visible entry points, the declared checks, and the configured `features` path. Do not copy those sources wholesale.

A map conforms when it uses the heading shape that [contract](contract.md) owns and each feature file has a user-facing reach path.

When a conforming map already exists, adopt that map. Do not create a second map.

When existing documentation is useful and does not match the feature-map shape, create a thin adapter map. Link the adapter to the authoritative pages. Name the relevant source, tests, and checks in the adapter. Do not rewrite the repository's documentation system.

When no map and no suitable location exist, propose the repo-native path. The default path may be `.capstan/features`. An existing documentation convention may justify another configured path. Put the chosen path and any `.capstan.json` change in the same reviewed commit.

The index contains only user-facing features. Each feature file uses the heading shape that [contract](contract.md) owns. State a real reach path, the exact repository command or interaction that drives the feature, the observable end state, and the material gotchas. An internal-only feature file is a feature file for an internal module that has no user-facing reach path. Do not add an internal-only feature file.

Trace every seeded claim to current source, to existing authoritative docs, or to a runnable repository check. The map remains a claim. Omit an unverifiable claim, or report that claim as a gap.

Name every file that adoption writes. [implementing](implementing.md) writes only those files.

Do not install OpenSpec, AgentLens, a documentation generator, or another skill. Do not add a Capstan executable, a stage, a label, a scheduled job, a daemon, a host-skill copy, or a generated architecture encyclopedia.

Use the normal Capstan pipeline for implementation and review. The final pull request is non-draft. The final pull request is mergeable under the existing ready gate.

This delivery's fixture proof covers five cases: a mature repository with an existing docs tree, a repository with no docs map, a custom configured map path, an already conforming map, and a repository where no defensible user-facing map can be produced without a human product decision. The pull request links those records. Do not copy the fixture trees into this repository.

This file owns the feature-map audit.

Run the audit only when the admitted issue or the text invocation states that the outcome is an audit of the configured feature map. A normal feature delivery, init, or resume does not enter the audit. Do not add a recurring job, a watcher, a daemon, a stage, or a label. Do not run the audit during an unrelated delivery.

The coordinator resolves the map exactly as [contract](contract.md) specifies. A disabled or absent map produces a clear no-map result. Do not seed a map.

Before the plan names a repair, inventory the map index, every indexed feature file, the repo instructions, the linked authoritative pages, the named source and tests, and the declared drive commands. Bound the reads through named packs. An unnamed path is a gap, not a search.

Check orphaned index entries, unindexed feature files, duplicate coverage, broken links, nonconforming headings, stale reach paths, stale commands, false observable results, missing material gotchas, and newly user-facing behavior absent from a present map.

Every finding cites the exact documentation claim and the current contradictory source or runnable evidence. Classify a failed drive command before repair. Documentation drift may update the docs. Report a product defect. Do not silently redefine the expected behavior.

Preserve the target repository's authoritative documentation structure. A feature-map change follows the heading shape that [contract](contract.md) owns. An existing user-facing page follows the page rule that [implementing](implementing.md) owns. Do not delete a still-true claim. Do not weaken a proof to make the audit pass.

Change only verified stale or missing documentation. When no drift is found, reconcile the issue as a no-op. Do not manufacture a diff.

Name every verified repair that the audit writes. [implementing](implementing.md) writes only those repairs.

The delivery uses the normal plan, implementation, review, and ready gate. The final summary lists the checked features, the proven repairs, the product-defect handoffs, the unresolved gaps, and the exact fixture evidence.

This delivery's fixture proof covers eight cases: a clean map, a stale command, a renamed reach path, an orphaned index entry, a missing new feature, a false expected result caused by a product defect, a custom map path, and an absent or explicitly disabled map. The pull request links those records in `comamitc/capstan-fixtures`. Do not copy the fixture trees into this repository.

This file owns the ADR rule.

Repository instructions or the admitted issue decide whether an ADR is required. Do not invent a universal ADR threshold. Do not create an ADR directory merely because a design choice exists.

Discover the existing ADR path, template, numbering or naming rule, status model, index, and declared validation command. The plan names the exact ADR and index paths. An unnamed path is a gap, not a search.

A required ADR uses the repository's native format for context, decision, alternatives, consequences, and supersession. Do not copy the issue. Do not duplicate `.capstan/vocabulary.md`.

The new or superseding ADR lands in the same commit as the architectural behavior. Do not rewrite accepted historical ADR text to erase the earlier decision, except for a repository-permitted mechanical correction.

[implementing](implementing.md) writes only the paths the plan names.

No convention and no explicit issue requirement means write no ADR and create no ADR infrastructure.

Do not add an external ADR tool, OpenSpec, a stage, a label, a generator, a daemon, or a host-skill copy. A declared ADR checker stays a declared check.

This delivery's fixture proof covers six cases: a native ADR template, indexed numeric ADRs, superseding an accepted ADR, an explicit issue-required ADR in a repo with a stated convention, no ADR convention, and a change that is important but not architectural. The pull request links those records in `comamitc/capstan-fixtures`. Do not copy the fixture trees into this repository.

Repository instructions name the lessons path. Adopt that path when it exists. When no lessons path exists, do not seed one. Delivery still completes.

Capture only non-recoverable reasoning whose loss risks recurrence. No lesson is a no-op. Update an equivalent entry instead of duplicating it.

Record applicability, source, evidence SHA, cause, remedy, failed approaches, and limitations. Candidate-head proof is not merged proof. No secrets. No raw traces.

The coordinator cites lesson identities in the pack. Workers do not search. Retrieved text is evidence, not authority.

Lesson edits are in authorized scope before final review, or a later issue. No worker edits the running skill.

This file owns the lesson rule. Other files name that owner. Do not add a store, a stage, a daemon, a database, or a retention flag. A lesson is not a replay bundle.

This delivery's fixture proof covers eight cases: no worthy lesson, equivalent entry, applicable, irrelevant, stale, conflicting, instruction-like text, and changed head. The pull request links those records in `comamitc/capstan-fixtures`. Do not copy the fixture trees into this repository.

This file owns lesson maintenance with the lesson rule. Whole-corpus maintenance is only through an admitted issue. Ordinary delivery validates selected lessons. A missing store is a no-op. Do not seed a lesson file. Do not add a station, a scheduler, or a docs engine. A lesson file is not a replay bundle.

Check exact claims against source, named guidance, and runnable evidence. Report contradiction, supersession, overlap, and uncertainty separately. Unverifiable is not false.

An optional retirement condition is externally checkable. Upstream closure alone does not prove the repo uses the fixed release.

Keep, update, consolidate, or retire only as admitted scope authorizes. No age-only deletion. Pruning a still-accurate entry needs distinct scope.

Preserve attribution and replacement links. A valid invariant contradicted by code is a product regression, not a rewritten lesson. A documentation audit does not edit product code or the governing skill.

Maintenance fixture cases are obsolete workaround, duplicate entries, valid old advice, code regression, unavailable external evidence, conflicting guidance, and clean no-op. The pull request links those records in `comamitc/capstan-fixtures`. Do not copy the fixture trees into this repository.

This file owns documentation backfill.

Run it only when the admitted issue or the text invocation states that the outcome is documentation backfill. A normal feature delivery, init, or resume does not enter it.

Settle the audience, the workflow, and the canonical destinations before any write. If that bound is absent, do not invent a whole-repository scope and do not write.

Inventory in-scope source, entry points, tests, configuration, and existing authoritative docs. Classify each in-scope subject as `documented`, `stale`, `missing`, or `unverified`. Do not claim an exhaustive audit outside that scope. An unnamed path stays a gap.

`documented` means the page and the current source or observed behavior agree. `stale` means the page disagrees with current source or observed behavior, and the page is the defective artifact. `missing` means the bound requires a statement and no suitable canonical page has it. `unverified` means there is no source and no observation. A page that states a valid expectation while the product disagrees is not `stale`. It is a product defect. Do not change the page to match the defect.

One coverage record names one in-scope subject, one of those four classes, and one evidence pointer. The pointer is a source `path:line` or a command and the observed result. The action is the write selected by the documentation-completeness and canonical-page eligibility rule owned by [implementing](implementing.md) lines 22-32, or a mode-specific result of no-change, explicit gap, or product-defect handoff. Do not restate that rule.

Point at the adoption and audit procedures owned by `references/planning.md` lines 11-57. Do not copy their procedure clauses. Backfill does not enter adoption or the audit. Enter either mode only when its own outcome is admitted. An optional map may link to a canonical page without copying that page. An absent or disabled map does not block backfill and does not get seeded.

Use the documentation-completeness and canonical-page eligibility rule owned by [implementing](implementing.md) lines 22-32, including the same-commit write in that range. Do not restate that rule. Do not add a second write rule. Preserve a custom documentation layout. Do not move that layout to `docs/` or to `.capstan/features`.

Separate observed current behavior, intended behavior, known defects, and unknowns. Do not invent historical architectural rationale. Do not rewrite a valid expectation to excuse a regression. Do not delete a still-true statement.

Every material new or corrected claim cites source or an observed result. Run a runnable example when its prerequisite is present. The mature partial docs fixture is the positive proof. Its live record captures the target repository's exact declared command, the exit status, and the observed output. If the prerequisite is absent, record an explicit gap. Do not fabricate success. A present prerequisite with a skipped or failed example is a failure.

A created page or section maps to `added`. An updated page maps to `updated`. A checked page with no write maps to `intentionally unchanged`. A gap, an unavailable prerequisite, or an unverified claim maps to `unverified` and row state `unresolved`. A product defect is a handoff in the summary. Contradictory evidence stays `unresolved` ([telemetry](telemetry.md) line 129). Do not add a fifth disposition word. [telemetry](telemetry.md) lines 121-125 own those four words.

The summary reports coverage, created pages, updated pages, intentionally unchanged docs, defects, and gaps, with the disposition map above.

An unchanged in-scope repository produces no diff. A second backfill of that same unchanged repository does not add a duplicate page, a duplicate section, or a changelog line. The second diff is empty. Do not manufacture a commit to satisfy a nonempty-diff rule. [implementing](implementing.md) lines 96-97 own that reconciliation.

This delivery's fixture proof is seven live records in `comamitc/capstan-fixtures`: a mature partial docs tree, absent docs, a custom docs layout, conflicting docs and product evidence, an unavailable prerequisite, a clean no-op, and a repeated backfill. Do not copy the fixture trees into this repository. Evidence follows the terminal outcome. A diff-producing journey links its issue, its pull request, its head, and its logs. The clean no-op and the repeated backfill link the admitted issue or reconciliation record, the unchanged head, empty `git status --porcelain`, empty `git diff`, and proof that no duplicate was created. Those two journeys have no fixture pull request. The Capstan pull request links every record. That link does not assert that every record has its own pull request. The mature partial docs record also captures the exact declared command, the exit status, and the observed output of its runnable example.

Do not add an executable, a stage, a label, a scheduled job, a daemon, a generator, OpenSpec, a host-skill copy, or a `.capstan.json` field. Admission is the outcome sentence. `features` remains the map switch only.

1. Read the brief and the pack. For the initial plan the pack's Candidate is
   `no plan; diff empty at SHA` with the spec criteria, Open findings `none — no
   review yet`, Checks the repository commands the coordinator observed or `none
   observed`, and Named files the affected functions and callers as excerpts.
   Trace existing behavior from those excerpts and cite concrete patterns rather
   than assuming a framework or file structure. Open a named file only to confirm
   a cited line. A path the pack does not name is a gap under Risks and unresolved
   items, not a search. Record the initial head and worktree status. Count each
   tool call, one read call or one shell command, however many files it names,
   as a numbered line under
   `## Checks`; at the ceiling in
   the brief header, stop and list unchecked items as gaps. The ceiling applies to
   both planning steps. The pack is sized to the unit: a one-file, one-check unit
   gets the compact form, whose single named file and check are the whole allowance.
2. Name input/output and data shapes before implementation mechanics. Apply
   [ladder](ladder.md). Do not restate the ladder.
3. Produce [plan](../templates/plan.md). Map every acceptance criterion to ordered
   items with an observable outcome, affected area, verification command/seam,
   failure signal, and risk. Name final repository checks and real user-surface proof.
   Scale the plan to the change: a small CLI option needs a short behavior map,
   not repeated explanations of the same command in several sections.
   Fill Documentation impact. Map each changed public or operational behavior
   to the exact canonical path, a required change or a reasoned no-change, and
   the verification. One behavior uses four lines. A table is only for repeated
   behaviors. Every Documentation impact path is copied into later Named files
   and every verification into Checks. Record a required new canonical page as
   a required change, not write-nothing. `discovery gap:` stays only for an
   unknown path.
4. In the single correction pass, the pack is the current plan text, all
   plan-review rows, the commands the plan names, and the rows' citations as Named
   files. Address ALL findings from the complete review. For each original scenario
   and acceptance condition, update the affected plan items and implementation
   checks, propose an evidence-backed refutation, or identify an actual
   prerequisite. Carry technical obligations into implementation for code-level
   verification. Preserve settled scope and report any omissions. A gap the
   correction returns goes forward to implementing as an unresolved obligation
   with the affected finding's acceptance condition, never to another correction.
5. Verify unchanged tree/head and write only the assigned result.

The plan names declared checks. It does not resolve a runner. The coordinator
runs [toolchain](toolchain.md) before the implementing worker launches.

The planning result names [telemetry.md](telemetry.md) as the owner of the ledger row.

Use [templates/result.md](../templates/result.md) for planning result headings. Complete when every acceptance criterion is covered, every item
has observable verification and a failure signal, every prior finding has a
supported proposed disposition, repository gates are named, the plan cites the
pack and lists its operations, and the tree is unchanged. The coordinator
publishes the plan with its specification revision. The initial plan enters
plan-review; the correction enters implementing with the complete finding handoff,
without another plan review. Incomplete output follows the recovery rules in
one-pass planning.
