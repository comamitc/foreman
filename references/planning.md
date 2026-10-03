# Planning — fresh primary, read-only

Before dispatch, the coordinator applies [one-pass planning](plan-convergence.md),
reads [finding resolution](findings.md) for the correction, and writes the pack;
the worker reads the brief and the pack only.

[contract](contract.md) owns feature-map resolution and heading shape.

[implementing](implementing.md) owns the feature-map write.

[modes/feature-map-adoption.md](modes/feature-map-adoption.md) ("This file owns feature-map adoption") owns feature-map adoption. Trigger: the admitted issue or the text invocation states that outcome.

[modes/feature-map-audit.md](modes/feature-map-audit.md) ("This file owns the feature-map audit") owns the feature-map audit. Trigger: the admitted issue or the text invocation states that outcome.

[modes/adr.md](modes/adr.md) ("This file owns the ADR rule") owns the ADR rule. Trigger: repository instructions or the admitted issue require an ADR.

[modes/lessons.md](modes/lessons.md) ("This file owns the lesson rule") owns the lesson rule and lesson maintenance. Trigger: repository instructions name a lessons path, or the admitted issue or the text invocation states lesson maintenance.

[modes/verification-path.md](modes/verification-path.md) ("This file owns verification-path adoption") owns verification-path adoption. Trigger: the admitted issue or the text invocation states that outcome.

[modes/performance-proof.md](modes/performance-proof.md) ("This file owns performance proof") owns performance proof. Trigger: an admitted acceptance criterion or an applicable existing repository budget states a performance requirement.

[modes/documentation-backfill.md](modes/documentation-backfill.md) ("This file owns documentation backfill") owns documentation backfill. Trigger: the admitted issue or the text invocation states that outcome.

1. Read the brief and the pack. For the initial plan the pack's Candidate is
   `no plan; diff empty at SHA` with the spec criteria, Open findings `none — no
   review yet`, Checks the repository commands the coordinator observed or `none
   observed`, and Named files the affected functions and callers as excerpts.
   Trace existing behavior from those excerpts and cite concrete patterns rather
   than assuming a framework or file structure. Open a named file only to confirm
   a cited line. A path the pack does not name is a gap under Risks and unresolved
   items, not a search. Record the initial head and worktree status. Count each
   tool call, one read call or one shell command, however many files it names,
   as a numbered line under `## Checks`, except a host-instruction read ([references/harnesses/shared.md](harnesses/shared.md) "A host-instruction read is not an operation");
   at the ceiling in the brief header, stop and list unchecked items as gaps. The ceiling applies to
   both planning steps. The pack is sized to the unit: a one-file, one-check unit
   gets the compact form, whose single named file and check are the whole allowance.
2. Name input/output and data shapes before implementation mechanics. Apply
   [ladder](ladder.md). Do not restate the ladder.
3. Produce [plan](../templates/plan.md). Map every acceptance criterion to ordered
   items with an observable outcome, affected area, verification command/seam,
   failure signal, and risk. Name final repository checks and real user-surface proof.
   Size proof to the change; [references/ladder.md](ladder.md) ("## Check") owns the limit.
   A Markdown-only change uses the simplest observable text checks that discriminate a real defect.
   A multi-stage proof pipeline needs a stated reason in the plan.
   A stated reason does not waive the simplest-check sentence for a Markdown-only change.
   An Ordered items row for non-trivial logic names the test tier of its check
   inside its "Verification command and failure signal" cell; a Markdown-only or
   exempt row names the Markdown-only rule or the implementing exemption in that
   cell instead of a tier. [references/implementing.md](implementing.md) step 2
   owns the exemption.
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
   [One-pass planning](plan-convergence.md) ("The correction returns only changed plan content") owns what the correction returns, the merge, and publication.
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
