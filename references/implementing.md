# Implementing — fresh primary, write

The coordinator extracts the [finding resolution](findings.md) closure-row
requirements into the pack; the worker reads the brief and the pack.

[contract](contract.md) owns feature-map resolution and heading shape.

[modes/feature-map-adoption](modes/feature-map-adoption.md) ("This file owns feature-map adoption") owns feature-map adoption.

[modes/documentation-backfill](modes/documentation-backfill.md) ("This file owns documentation backfill") owns documentation backfill.

[review](review.md) owns what counts as a required map update.

[modes/feature-map-audit](modes/feature-map-audit.md) ("This file owns the feature-map audit") owns the feature-map audit.

[modes/adr](modes/adr.md) ("This file owns the ADR rule") owns the ADR rule.

When a map is present and [review](review.md) requires a map update, the plan names the feature file and the index line. The implementing pack includes those paths as Named files. Write that update in the same commit as the behavior.

When a delivery has no map, or the change does not require a map update, write no feature file and no index line.

This file owns documentation completeness and assesses public interfaces, user workflows, configuration/setup requirements, migrations, and operational recovery changes for a required Canonical document. Internal-only changes do not mechanically require a Canonical document. That limit does not skip a correction when a public statement becomes false.

Add a new page or section only when necessary and in admitted scope. Do not require feature-map adoption. When the repository has no convention, planning names the smallest destination.

An existing canonical page is an existing `README.md`, an existing file under `docs/`, an existing config example, or the target repository's existing root agent-instructions file. Prefer that existing page when it is a suitable destination. When no suitable existing destination exists, and the addition is necessary and admitted, write the smallest new page or section that planning names. Correct existing public documentation whenever this diff makes a stated setup step, command, workflow, feature, flag, env var, limit, usage, limitation, or invariant false. That false-statement condition applies to correcting existing documentation. It does not decide canonical-document eligibility. The agent-instructions file is `AGENTS.md`, or `CLAUDE.md` when no `AGENTS.md` exists; a `CLAUDE.md` symlink to `AGENTS.md` is the same file, and the write goes to `AGENTS.md`. The plan names that page. The implementing pack includes it as a Named file.

The pack names the agent-instructions file as a `path:line-range` covering only the affected statement or the required section's location, never the whole file, with the anchor [pack](pack.md) ("Citation rule") requires. In that file, correct the statement this diff makes false. Add a section only when the admitted spec requires one. Do not restructure the file, rewrite unrelated text, or restate the diff.

Write the correction in the same commit as the behavior. Do not delete a still-true statement to avoid the update.

Do not create a docs tree or a generator. A README section is allowed when the plan names it.

The new page rule does not override the agent-instruction section rule or the ban on creating `CONTEXT.md`, `CLAUDE.md`, or `AGENTS.md`.

Do not create `CONTEXT.md`, `CLAUDE.md`, or `AGENTS.md`. Do not write `CONTEXT.md` or a host skill. Do not add a pre-merge docs harness, an OpenSpec dependency, or a Foreman-owned docs generator. A target repository's already-declared docs check stays a declared check.

The coordinator runs [toolchain](toolchain.md) before this worker launches.

1. Read the brief and the pack: the plan sections [pack](pack.md) ("Implementing: the plan's identity lines") names, every carried finding row
   with its proposed disposition including unfinished correction work, the rule
   extract, the commands the plan names plus the final gates, and the plan's
   affected files and tests as Named files. Map ALL carried findings to
   implementation tasks/checks or evidence-backed refutations. Complete this
   mapping before affected code is written. Reconcile existing work before
   repeating interrupted steps.
2. Implement plan items in order. Show each required check failing for the
   intended reason without the change, or with the defect restored, before
   trusting it, and passing with the change.
   One run of a check is the red observation for every case whose failure that run shows for its stated reason; a case needs a separate fault-injection run only when no earlier run shows it failing.
   Planted defects for different cases may share one run when each defect changes only its own case's behavior and the output names each failing case.
   A shared red run of a heavy check keeps the order [references/planning.md](planning.md) ("Mark each declared check heavy or not heavy") owns.
   At a Claude write station, [references/harnesses/claude.md](harnesses/claude.md) ("A heavy check at a write station gets no allow entry") owns who makes a red, green, or bite run of a heavy check.
   Record the red or fault-injection observation under Acceptance proof;
   [references/review.md](review.md) owns the discriminating-check rule.
   [references/ladder.md](ladder.md) ("## Check") owns the check's derivation,
   its placement at the owning module's interface, its tier, and the owned-mock rule.
   Documentation, configuration, deletion, generated, operational, and trivial changes
   may use stronger appropriate proof instead; explain when a failing test adds no value.
   In any repository, when the change breaks an existing test that reaches past
   a module's interface, rewrite that test at the interface instead of patching
   it. Before removing the old test, show the rewritten test failing on a defect
   the old test caught, and record that run under Acceptance proof; the
   controlled reversible fault under "**Bite:**" in
   [references/findings.md](findings.md) is the proof shape. Leave other
   existing tests alone unless test cleanup is the admitted task.
3. Run each item's verification. Keep scope narrow; commit coherent changes.
   Write only the paths the plan names. A path the plan does not name is a gap
   reported under Risks and unresolved items, not a write.
   A capture under `.foreman/proof/N/` that "Visual proof:" below directs is a named path.
   [triage](triage.md) ("When `.foreman/vocabulary.md` exists, read it after repository instructions") owns how triage reads `.foreman/vocabulary.md`, and [contract](contract.md) ("## Compat read path") owns the old-form file.
   Implementation writes the file.
   A settlement is repository-scoped when the term names a standing behavior,
   role, or artifact of the repository, and later deliveries need the same
   meaning. A settlement is delivery-scoped when it binds only this issue, this
   pull request, or this change. Keep a delivery-scoped decision in the admitted
   spec. Do not copy it into `.foreman/vocabulary.md`. The plan names
   `.foreman/vocabulary.md` when the delivery settles a repository-scoped term.
   The implementation commit for a repository-scoped term creates or updates
   `.foreman/vocabulary.md` in the same commit as the behavior. Use one `**Term**:` entry per term. Include
   the meaning and the rejected alternative that the triage walk recorded.
   Do not edit `CONTEXT.md`.
   Keep #20's per-issue
   Vocabulary and Decisions sections.
   Follow [ladder](ladder.md) before introducing new code. Do not restate the
   ladder. Preserve human changes and do not silently stage unrelated files.
4. Prove each carried finding's original acceptance condition against the code,
   or propose a refutation with concrete evidence. Record unfinished obligations
   explicitly; technical failures stay in implementing recovery, not planning or `fix`.
   Run all declared final checks except a silent check and exercise the real user
   surface. Use the exact invocation the brief carries, in the order [references/planning.md](planning.md) ("Mark each declared check heavy or not heavy") owns.
   At a Claude write station, [references/harnesses/claude.md](harnesses/claude.md) ("A heavy check at a write station gets no allow entry") owns which of these checks the worker runs.
   For a silent check, record the coordinator
   result in the form `references/harnesses/shared.md` states. Record actual
   commands, working directories, exit statuses, and output/evidence paths,
   each check's head SHA as
   [templates/result.md](../templates/result.md) ("## Checks") defines it, and
   the resulting head SHA.
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
   diagram only where it clarifies the change. When
   `review_policy.residual_effect_approval` is `false`, Blast Radius is
   decision support, not a numeric risk score or an approval workflow.
   [pre-merge.md](pre-merge.md) ("Risk tier:") owns the `Risk tier:` line,
   which is decision support for the merger. When it is
   `true`, residual effects or unknown reversibility route readiness through
   the residual-effect approval in [pre-merge.md](pre-merge.md) step 4. A
   reversible change
   does not bypass required approval, existing checks, independent secondary
   review, or Foreman's prohibition on merge and deploy.
   Report risks honestly.
   Visual proof: the coordinator decides whether a change needs visual proof from the three-dot diff `git diff BASE...HEAD` against the resolved base. Proof is required when the diff changes a behavior a person reaches through a screen, a command's output, or a running app; a file-extension list alone does not settle it. When the coordinator cannot settle it, proof is required. The coordinator judges the first implementing result before the first code review, and judges again before it writes the PR text. When proof is required, the coordinator first looks for the target's capture path: a feature file's `Driving it` section ([contract](contract.md) ("`Driving it` states the repository commands and the observable end state.")) or the evidence-capture step of a verification path ([verification-path](modes/verification-path.md) ("Record these seven steps")). When the coordinator finds no capture path, it launches no capture attempt; [verification-path](modes/verification-path.md) ("Missing usable tooling is a capability gap.") owns the gap treatment, and the Verification part below reports the gap. When it finds one and the delivery has no capture, it launches one implementing write attempt whose allowed writes are `.foreman/proof/N/` and whose brief names that capture path. A failed capture attempt with an available path follows step 4 ("technical failures stay in implementing recovery, not planning or `fix`."). [contract](contract.md) ("Permit only `git`, `gh`") owns the permitted tools; the worker runs no capture tool beyond those commands. The write worker captures "after" at the candidate head, and captures "before" at the resolved base when the path allows it. It commits the captures on `foreman/N` under `.foreman/proof/N/`, and each capture's file name contains the full head SHA it came from. A later head needs no recapture. [security](security.md) ("Inspect each artifact for credentials before posting.") applies to each capture before its commit.

   Verification gets a visual-proof part. An image is a Markdown image whose URL is `https://github.com/OWNER/REPO/blob/<SHA>/.foreman/proof/N/<file>?raw=true`, with `<SHA>` a commit that contains the file; a relative path does not render in a PR body. Terminal output appears inline as a fenced `text` transcript. A recording, made only when the capture path produces one, appears as a link, not an embed. When proof is not required, the part is one line: `Visual proof: not required` and its basis. When proof is required but missing, the part states the gap and its reason, such as "no capture path in target". Missing or not-required visual proof is not an input of [pre-merge](pre-merge.md) ("Risk tier: before each ready projection") and does not change the risk tier. It does not withhold `foreman:ready-to-deploy`, whose projection [contract](contract.md) ("## Stage projection") owns. It adds no `foreman:blocked` overlay and no blocker type; [contract](contract.md) ("A blocker adds only `foreman:blocked`;") and [recovery](recovery.md) ("## Blocked overlays") own the overlay and its kinds.
   Finish everything the pack supports; the result cites the pack.

For any effective blocking obligation carried from review, include the red/green/bite
row in the closure-row format the pack carries from
[finding resolution](findings.md); planned or proxy tests are insufficient.

The implementing result names [telemetry.md](telemetry.md) as the owner of the ledger row and the policy row.

Use [templates/result.md](../templates/result.md) for common and implementing result headings. Complete when the diff is nonempty and
in scope, the brief's exact declared-check invocations
pass, every carried finding has an evidenced proposed disposition, the user-visible
result is demonstrated, commits contain the intended change, and the tree is clean.
A no-op or already-delivered issue is reconciled with the
coordinator; do not manufacture a change to satisfy the nonempty criterion.

Coordinator independently checks evidence;
[references/harnesses/shared.md](harnesses/shared.md) ("The coordinator accepts a same-head check record")
owns whether it runs a declared check again. It applies the closure proof gate
for every carried effective blocker. [references/publication.md](publication.md)
owns publication. Implementing is not complete, and no review starts, until
every coordinator-run silent check declared for it has exited 0. A silent-check
failure is implementing recovery, not `fix`.
