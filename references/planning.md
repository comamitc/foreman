# Planning — fresh primary, read-only

Before dispatch, the coordinator applies [one-pass planning](plan-convergence.md),
reads [finding resolution](findings.md) for the correction, and writes the pack;
the worker reads the brief and the pack only.

1. Read the brief and the pack. For the initial plan the pack's Candidate is
   `no plan; diff empty at SHA` with the spec criteria, Open findings `none — no
   review yet`, Checks the repository commands the coordinator observed or `none
   observed`, and Named files the affected functions and callers as excerpts.
   Trace existing behavior from those excerpts and cite concrete patterns rather
   than assuming a framework or file structure. Open a named file only to confirm
   a cited line. A path the pack does not name is a gap under Risks and unresolved
   items, not a search. Record the initial head and worktree status. Count each
   file read and command as a numbered line under `## Checks`; at the ceiling in
   the brief header, stop and list unchecked items as gaps. The ceiling applies to
   both planning steps. The pack is sized to the unit: a one-file, one-check unit
   gets the compact form, whose single named file and check are the whole allowance.
2. Name input/output and data shapes before implementation mechanics. Apply the
   simplicity ladder: need → existing code → standard library → platform → installed
   dependency → one line → minimum new code. Justify any new dependency or abstraction.
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

Add `## Plan`, `## Acceptance mapping`, and `## Revision response` to the common
result headings. Complete when every acceptance criterion is covered, every item
has observable verification and a failure signal, every prior finding has a
supported proposed disposition, repository gates are named, the plan cites the
pack and lists its operations, and the tree is unchanged. The coordinator
publishes the plan with its specification revision. The initial plan enters
plan-review; the correction enters implementing with the complete finding handoff,
without another plan review. Incomplete output follows the recovery rules in
one-pass planning.
