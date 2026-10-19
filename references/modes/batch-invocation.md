# Batch invocation

Load this file only when [contract](../contract.md) "## Identity and authority" parses the invocation as a batch invocation.

This file owns batch invocation order.

## Procedure

1. **List parsing.** The trigger is this parse.
   - An entry is an issue URL, or an issue number that resolves in the current checkout as [contract](../contract.md) "## Identity and authority" resolves one. Entries and overrides are separated by spaces or commas. The allowed overrides apply to every issue. A repeated issue counts once.
   - List order only breaks ties (rule 5). It never creates a dependency.
   - Boundary: if any token is not an entry or an allowed override, the invocation is not a batch list. This file does not apply, and [contract](../contract.md) "## Identity and authority" governs the invocation unchanged. This includes prose that contains issue numbers or issue URLs.
   - If the entries resolve to more than one repository, start nothing and ask for one repository.
   - Fewer than two distinct issues is not a batch.
2. **Dependency sources.** [contract](../contract.md) "## Start condition" owns the `Depends on #M` and `Depends on owner/repo#M` entries: their source, their scope, their resolution, and whether a delivery starts. The invocation has no dependency syntax. This file adds only ordering: an M in the set is an ordering edge for rule 5, and an M outside the set, including every entry in another repository, adds no edge.
   - A cycle among in-set edges is one triage Ask round under [triage](../triage.md) ("An ask is one numbered round of the current frontier."). The round names the cycle and recommends which `Depends on` edge to drop.
   - The answer is recorded as a Decision in the affected spec and republished under triage step 5.
3. **Triage first.** Every issue is walked before any issue enters unattended delivery.
   - Walk each issue in list order under [triage](../triage.md) ("A body that already contains Decisions and an empty Open questions section is still walked"), with all Ask rounds, cycle rounds included.
   - An issue whose body already has Decisions and empty Open questions is walked too. Its spec is reused only after the walk matches that body. A branch with no settlement is asked or defaulted.
   - Record each issue's walk in that issue's own ledger.
   - No issue enters unattended delivery until every issue's walk is recorded and every issue is ready.
4. **Per-issue identity.** Each issue keeps its own identity, branch `capstan/N`, worktree, labels, ledger, spec, PR and ready gate. Its PR targets the resolved integration branch.
5. **Delivery order.** Topological order, ties broken by list order.
6. **Start condition.** Each issue starts only as [contract](../contract.md) "## Start condition" allows. Check it when that issue's turn comes in delivery order.
   - An issue that does not start stops at its blocker, and unrelated issues continue. Rule 7 adds what a dependent of a blocked in-set prerequisite records.
7. **Blocked prerequisite.** This rule applies only when rule 6 stops a dependent because its condition under [contract](../contract.md) "## Start condition" is unfulfilled and the in-set prerequisite ended with a `capstan:blocked` overlay. The overlay explains the stop; it does not decide merge status.
   - Merging is beyond v1 authority, and the prerequisite's own blocker names what that issue needs.
   - The dependent's blocker handoff and its ledger record why: "prerequisite #M ended <overlay reason>".
   - This carries on to that dependent's own dependents: each is blocked on its direct prerequisite, the same way.
   - Unrelated issues continue.
   - No issue is left without a stop.
8. **Sequential delivery.** One coordinator. The next issue starts only after the current one reaches a stop. No concurrent write workers.
9. **Launch probe.** Owned by [shared](../harnesses/shared.md) ("Run it once per invocation"). Run it once for the batch, in the first delivered issue's worktree, before its first worker launch. Do not run it for later issues.
10. **End and final message.** Each issue's Capstan stop is `capstan:ready-to-deploy` or a `capstan:blocked` overlay: review exhaustion, or a reason in [recovery](../recovery.md) "## Blocked overlays".
    - Publish each issue's summary at that issue's stop. Use the summary rule in [end of run](../end-of-run.md) ("publish a marked issue summary"). This includes an issue stopped by a human-capability overlay before or during delivery.
    - Do not project `capstan:ready-to-deploy` for a blocked issue.
    - An issue that never started has a table of the stages it ran; bounds that were not observed are `unknown`.
    - The batch ends when every issue has a stop.
    - Emit the final message once, after the last issue's summary read-back. It lists issues in delivery order. Each issue has its outcome and its attempt table with the Total row and the date line, copied from its own read-back per [end of run](../end-of-run.md) "Emission follows the summary read-back".
    - [boundary pass](boundary-pass.md) ("## Triggers") owns any pass after this final message.
    - No issue appears without a table.
