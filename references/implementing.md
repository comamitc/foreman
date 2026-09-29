# Implementing — fresh primary, write

The coordinator extracts the [finding resolution](findings.md) closure-row
requirements into the pack; the worker reads the brief and the pack. Planning
handoff is permission to implement, not independent approval of the corrected
design or closure of its findings.

[contract](contract.md) owns feature-map resolution and heading shape.

[modes/feature-map-adoption](modes/feature-map-adoption.md) ("This file owns feature-map adoption") owns feature-map adoption.

[modes/documentation-backfill](modes/documentation-backfill.md) ("This file owns documentation backfill") owns documentation backfill.

[review](review.md) owns what counts as a required map update.

[modes/feature-map-audit](modes/feature-map-audit.md) ("This file owns the feature-map audit") owns the feature-map audit.

[modes/adr](modes/adr.md) ("This file owns the ADR rule") owns the ADR rule.

When a map is present and [review](review.md) requires a map update, the plan names the feature file and the index line. The implementing pack includes those paths as Named files. Write that update in the same commit as the behavior.

When a delivery has no map, or the change does not require a map update, write no feature file and no index line.

This file owns documentation completeness and assesses public interfaces, user workflows, configuration/setup requirements, migrations, and operational recovery changes for a required Canonical document. Internal-only changes do not mechanically require a Canonical document. That limit does not skip a correction when a public statement becomes false.

Prefer an existing canonical page. Add a new page or section only when necessary and in admitted scope. Do not require feature-map adoption. Do not create a docs tree. When the repository has no convention, planning names the smallest destination.

An existing canonical page is an existing `README.md`, an existing file under `docs/`, an existing config example, or the target repository's existing root agent-instructions file. Prefer that existing page when it is a suitable destination. When no suitable existing destination exists, and the addition is necessary and admitted, write the smallest new page or section that planning names. Correct existing public documentation whenever this diff makes a stated setup step, command, workflow, feature, flag, env var, limit, usage, limitation, or invariant false. That false-statement condition applies to correcting existing documentation. It does not decide canonical-document eligibility. The agent-instructions file is `AGENTS.md`, or `CLAUDE.md` when no `AGENTS.md` exists; a `CLAUDE.md` symlink to `AGENTS.md` is the same file, and the write goes to `AGENTS.md`. The plan names that page. The implementing pack includes it as a Named file. A path the pack does not name is a gap, not a search.

The pack names the agent-instructions file as a `path:line-range` covering only the affected statement or the required section's location, never the whole file ([pack](pack.md)). In that file, correct the statement this diff makes false. Add a section only when the admitted spec requires one. Do not restructure the file, rewrite unrelated text, or restate the diff.

Write the correction in the same commit as the behavior. Do not delete a still-true statement to avoid the update.

Do not create a docs tree or a generator. A README section is allowed when the plan names it.

The new page rule does not override the agent-instruction section rule or the ban on creating `CONTEXT.md`, `CLAUDE.md`, or `AGENTS.md`.

Do not create `CONTEXT.md`, `CLAUDE.md`, or `AGENTS.md`. Do not write `CONTEXT.md` or a host skill. Do not add a pre-merge docs harness, an OpenSpec dependency, or a Capstan-owned docs generator. A target repository's already-declared docs check stays a declared check.

The coordinator runs [toolchain](toolchain.md) before this worker launches.

1. Read the brief and the pack: the plan sections [pack](pack.md) ("Implementing: the plan's identity lines") names, every carried finding row
   with its proposed disposition including unfinished correction work, the rule
   extract, the commands the plan names plus the final gates, and the plan's
   affected files and tests as Named files. A write station may read named files
   fully and run the named checks and declared final gates except silent checks,
   which `references/harnesses/shared.md` assigns to the coordinator; it has no numeric
   ceiling. A path the pack does not name is a gap reported under Risks and
   unresolved items, not a search. A one-file, one-check item gets a compact pack
   whose single named file and check bound the reads. Map ALL carried findings to
   implementation tasks/checks or evidence-backed refutations. Complete this
   mapping before affected code is written. Reconcile existing work before
   repeating interrupted steps.
2. Implement plan items in order. Use a failing behavior check where meaningful,
   prove it fails for the intended reason, then make the smallest change and rerun.
   Record the red or fault-injection observation under Acceptance proof;
   [references/review.md](review.md) owns the discriminating-check rule.
   Documentation, configuration, deletion, generated, operational, and trivial changes
   may use stronger appropriate proof instead; explain when a failing test adds no value.
3. Run each item's verification. Keep scope narrow; commit coherent changes.
   Triage reads the committed `.capstan/vocabulary.md` on `main` when it exists,
   after repository instructions and before a question. Implementation writes
   the file. An unmerged vocabulary edit is not evidence for a different issue.
   A settlement is repository-scoped when the term names a standing behavior,
   role, or artifact of the repository, and later deliveries need the same
   meaning. A settlement is delivery-scoped when it binds only this issue, this
   pull request, or this change. Keep a delivery-scoped decision in the admitted
   spec. Do not copy it into `.capstan/vocabulary.md`. The implementation commit
   for a repository-scoped term creates or updates `.capstan/vocabulary.md` in
   the same commit as the behavior. Use one `**Term**:` entry per term. Include
   the meaning and the rejected alternative that the triage walk recorded.
   Triage does not create the file. Do not edit `CONTEXT.md`.
   Keep #20's per-issue
   Vocabulary and Decisions sections.
   Follow [ladder](ladder.md) before introducing new code. Do not restate the
   ladder. Preserve human changes and do not silently stage unrelated files.
4. Prove each carried finding's original acceptance condition against the code,
   or propose a refutation with concrete evidence. Record unfinished obligations
   explicitly; technical failures stay in implementing recovery, not planning.
   Run all declared final checks except a silent check and exercise the real user
   surface. Use the exact invocation the brief carries. For a silent check, record the coordinator
   result in the form `references/harnesses/shared.md` states. Record actual
   commands, exit statuses, output/evidence paths, and the resulting head SHA.
5. Prepare PR text with Why, Scope, Tradeoffs, Blast Radius, and Verification.
   Blast Radius states reversibility, rollback or mitigation, affected
   surfaces, and human attention. It cites its basis: the diff, commands,
   checks, or observed behavior. Reversibility uses three states: a code
   revert undoes the change; residual effects remain; or unknown. Residual
   effects and unknown can apply together. A residual effect is one a code
   revert does not undo: an applied migration, changed or deleted data, a
   sent message, or another external write. Name each known residual effect,
   even when whether it can be undone is unknown. Write unknown when the
   basis does not settle whether an effect exists or can be undone. A
   rollback or mitigation is tested only when this delivery exercised it and
   the evidence is cited; otherwise mark it untested. A change with no
   residual effect may state its reversibility in one line. Human attention
   names specific files, decisions, effects, or unverified items, or states
   that nothing is needed beyond normal review. Generic advice such as
   "review carefully" does not satisfy it. Add a compact before/after or
   diagram only where it clarifies the change. Blast Radius is decision
   support, not a risk score or an approval workflow. A reversible change
   does not bypass required approval, existing checks, independent secondary
   review, or Capstan's prohibition on merge and deploy.
   Report risks honestly and verify a clean worktree containing the intended commits.
   Finish everything the pack supports; the result cites the pack.

For any effective blocking obligation carried from review, include the red/green/bite
row in the closure-row format the pack carries from
[finding resolution](findings.md); planned or proxy tests are insufficient.

The implementing result names [telemetry.md](telemetry.md) as the owner of the ledger row.

Use [templates/result.md](../templates/result.md) for common and implementing result headings. Complete when the diff is nonempty and
in scope, the brief's exact declared-check invocations
pass, every carried finding has an evidenced proposed disposition, the user-visible
result is demonstrated, commits contain the intended change, and the tree is clean.
A no-op or already-delivered issue is reconciled with the
coordinator; do not manufacture a change to satisfy the nonempty criterion.

Coordinator independently checks evidence and applies the closure proof gate for
every carried effective blocker. [references/publication.md](publication.md)
owns publication. Implementing is not complete, and no review starts, until
every coordinator-run silent check declared for it has exited 0. A silent-check
failure is implementing recovery, not `fix`. Then review.
Attempt failures use recovery inside implementing rather than the review fix label.
