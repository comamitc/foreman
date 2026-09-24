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

Use [templates/result.md](../templates/result.md) for planning result headings. Complete when every acceptance criterion is covered, every item
has observable verification and a failure signal, every prior finding has a
supported proposed disposition, repository gates are named, the plan cites the
pack and lists its operations, and the tree is unchanged. The coordinator
publishes the plan with its specification revision. The initial plan enters
plan-review; the correction enters implementing with the complete finding handoff,
without another plan review. Incomplete output follows the recovery rules in
one-pass planning.
