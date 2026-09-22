# Planning — fresh primary, read-only

Before dispatch, the coordinator applies [one-pass planning](plan-convergence.md),
reads [finding resolution](findings.md) for the correction, and writes the pack;
the worker reads the brief and the pack only.

`features` is the optional feature-map field. Resolution order is invocation,
then `CAPSTAN_FEATURES`, then the `.capstan.json` field `features`, then
`.capstan/features` when that directory contains `README.md`. `features: null`
disables the map. A missing explicit path is recorded in `run.md`. The run
continues with no map.

When a map is present, observation reads the map `README.md` only and records
its path in `run.md`. Planning cites only the feature files the issue can
affect. The brief contains those paths. The worker is not told to read the
other feature files.

Each feature file uses only these four H2 headings and no harness name:
`Sub-features`, `How to get to it (user POV)`, `Driving it`, `Gotchas`.
`Driving it` states the repository commands and the observable end state. A
harness name, a host skill path, or another section does not satisfy the shape.
No Launch, Doctor, Evidence, Cleanup, or Helpers section.

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
runs the preflight below before the implementing worker launches.

Take commands from the plan's named checks, then the repository's documented runner.
Do not detect a language. Do not invent a second runner.
Run preflight before worker launch.
The preflight records the command, the tool path, and the provenance.
A preflight failure is visible.
A preflight failure does not spend a worker turn on discovery.
This is a ban on worker-side discovery.
The brief carries the exact invocation.
A worker that substitutes a global tool has not followed the brief.
The worker runs that invocation.
The worker does not discover a command, a runner, or a tool path.

The three-step precedence is this order.
First, use the recorded toolchain when the identity matches.
Identity is the lockfile or manifest bytes, not a language version.
A mismatch invalidates only the recorded toolchain.
Resolution then uses the declared runner on `PATH`.
Second, use the declared runner on `PATH`.
Do not skip that `PATH` step.
Third, create one task-scoped environment only if that `PATH` step fails.
The fallback tool is the repository's own declared tool.
Do not limit that tool to a lockfile.
A manifest-only repository is included.
Do not assume a package manager is global.
Do not create a task environment when the `PATH` step succeeds.
Record the choice as provenance.

A single executable with no lockfile gets that executable and no new environment.
No declared check leaves the repo unchanged.
A declared `pipenv run` when no global `pipenv` exists uses these three steps.
A non-Python runner that is absent from `PATH` uses these three steps.
Neither is a virtualenv special case.
When a task environment is created, put it at `toolchain/` under the evidence root.
Do not implement #10 deletion. Do not re-run `lyric-utils#764`.

Add `## Plan`, `## Acceptance mapping`, and `## Revision response` to the common
result headings. Complete when every acceptance criterion is covered, every item
has observable verification and a failure signal, every prior finding has a
supported proposed disposition, repository gates are named, the plan cites the
pack and lists its operations, and the tree is unchanged. The coordinator
publishes the plan with its specification revision. The initial plan enters
plan-review; the correction enters implementing with the complete finding handoff,
without another plan review. Incomplete output follows the recovery rules in
one-pass planning.
