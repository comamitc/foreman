# Correction

Run it only when the admitted issue or the text invocation states that the outcome is correction. A normal delivery, init, or resume does not enter it.

This file owns correction. Correction turns recurring mistakes and friction in this repository's earlier deliveries into enforcement in this repository.

Evidence. Earlier deliveries are this repository's issues whose body carries the marked `spec`. List open and closed issues with `gh`, every page, and keep those whose body contains the exact spec marker; do not rely on search to find the marker. The invocation may bound them by issue numbers or a date range; otherwise read all of them. That set is the window. Read it in two kinds:

- Mistakes: actionable findings in marked `plan-review` comments and marked `review` censuses, fix rounds in the attempt table, reverts of a delivery's commits on the integration base, and PR review comments from trusted authors under [security](../security.md).
- Friction: pack gaps naming the same file or fact a worker could not reach; repeated permission denials for the same command; read stations hitting their operation ceiling; recovery attempts; evidence checks reported defective. Read them from the `ledger.md` each marked summary publishes verbatim, the local `ledger.md` when its evidence root survives, and the marked station artifacts.

A source the window does not retain is a named limitation, not zero.

Classes. Group each kind into classes. A class counts once it occurred in two or more deliveries. Each class cites every occurrence by issue, census or ledger URL, and head SHA. A one-off finding is reported and is not a class.

Guardrails. Before proposing any check, inventory the repository's existing guardrails: CI workflows, declared check commands, and pre-commit hooks. Record whether each runs, with a run URL or the observed command and exit. An existing check that is unwired, skipped, or broken is the finding, and its fix wires or repairs it. A repository with no guardrail running its lint, typecheck, or test command is itself a finding. A guardrail finding cites the inventory and needs no second delivery.

Pruning. Propose, and do not automatically apply:

- dropping a rule whose mistake can no longer happen;
- deleting a steering line that changes no behavior;
- fixing a check that fires on good code;
- removing a rule that no delivery's review cited over the window.

Ask and filing. At triage, present the classes with their evidence, the guardrail findings, and the pruning proposals as one Ask round under [triage](../triage.md) step 3. The invoker picks which items this delivery fixes and which to file as separate issues. That answer is the approval. File each picked-for-later item as an issue in this repository, deduplicated against open issues, with its evidence. An open issue that already covers an item is named and not filed again. A correction invocation is the explicit request that authorizes these creations, as the improvement mode's rule does ([improvement](improvement.md) ("An issue is published only after an explicit improvement invocation")). An ordinary delivery still creates no issues.

Admitted spec. The items picked for now become the admitted spec: one acceptance criterion per item, citing its occurrences. The spec lists the filed and the deduplicated issues. The delivery runs the normal pipeline and ends at a merge-ready PR. When the invoker picks nothing to fix now, the run ends after filing, with no PR, at the existing user-cancellation stop.

Filing-only end. That answer is user cancellation after filing, a stop [SKILL.md](../../SKILL.md) ("Stop only at") already allows. File the picked-for-later items first. Publish no admitted spec, so [triage](../triage.md) ("Complete when at least one acceptance criterion is independently verifiable") stays incomplete and nothing projects ready: the issue keeps `capstan:triage` and gets no `capstan:ready-to-deploy` or `capstan:blocked`; no branch, worktree, or PR exists. Record the Ask answer and each filed or deduplicated issue URL as notes lines in `ledger.md`, append the `run-end` event as cancellation, and publish the marked summary by [telemetry](../telemetry.md) ("Any other marked summary"), with `none` as its PR URL. On resume, that marked summary, with each issue URL it lists read back, is completion: report its URL and stop again at user cancellation, with no second Ask round and no second filing. Without that summary, triage runs again, and deduplication against open issues names each issue already filed.

Enforcement. For each class fixed, mistake or friction, the plan picks the level by [ladder](../ladder.md) ("This section owns the enforcement order"). That order holds when [improvement](improvement.md) also loads. Every new check fails on a real past occurrence, at that occurrence's head or in a scratch reproduction, and passes on the fix. Every new or repaired check is registered where later deliveries run it: a CI workflow or the repository's documented check command. A check no later delivery would run does not count as enforcement.

Rule placement.

- A mechanical violation, such as a banned API, an import shape, or a file-location rule, gets a deterministic check, not prose.
- A judgement rule goes in a standards file that review reads. Use an existing one first: a file the repository instructions name for contribution or review conventions, otherwise an existing `CONTRIBUTING.md`, `.github/CONTRIBUTING.md`, or `docs/CONTRIBUTING.md`. Create a new `CONTRIBUTING.md` only when none exists. Two or more qualifying files are a question in the Ask round. The admitted spec records the chosen path.
- The always-loaded instruction file (`AGENTS.md` or `CLAUDE.md`) gets only a pointer to the standards file. Do not create an instruction file.
- A table in the standards file pairs each rule with its enforcer: a named check, or review.
- [pack](../pack.md) ("standards file whose rule table names") names that file as a source of quoted rules, so each rule gets a policy row.

Acceptance is the normal pipeline and reviewer evidence on the diff.

## Review

Block a class with fewer than two delivery occurrences.

Block a new check with no failing run on a real past occurrence.

Block a new or repaired check that no later delivery runs.

Block prose for a mechanical violation.

Block a rule body in the instruction file.

Block a pruning applied without the invoker's pick.

Block a new standards file when an existing one qualifies.

Block a filing-only end that leaves a PR, a stage label other than `capstan:triage`, or no marked summary.
