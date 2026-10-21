# Issue delivery

## Sub-features
- Delivery from an issue URL, or from an issue number that resolves in the current checkout.
- Resume: the same invocation resumes the delivery.
- Overrides in the invocation, such as the worker roles or a wall budget.
- Triage questions; [triage](../../references/triage.md) ("An ask is one numbered round of the current frontier.") owns them.
- Stage labels from `capstan:triage` to `capstan:ready-to-deploy`, and the `capstan:blocked` overlay.
- Optional `.capstan.json` configuration; [README](../../README.md) ("Configuration") lists the fields.
- Opt-in residual-effect approval; [pre-merge](../../references/pre-merge.md) owns it.
- Opt-in boundary pass; [boundary pass](../../references/modes/boundary-pass.md) ("## Triggers") owns when it runs.
- Local evidence under `${XDG_STATE_HOME:-$HOME/.local/state}/capstan/OWNER/REPO/N/` by default.
- Events and the ledger: [telemetry](../../references/telemetry.md) ("Create `events.jsonl` at run acceptance") owns the events file and the ledger.

## How to get to it (user POV)
Install Capstan as [README](../../README.md) ("Install and invoke") describes, then invoke it explicitly from the host's skill menu.
Frontmatter disables model invocation; if a host version ignores invocation metadata, verify its discovery behavior before use.
Prerequisites are git, authenticated `gh` with repository write access, and configured harness CLIs on `PATH`.

## Driving it
Invocation: invoke Capstan with the issue URL `https://github.com/OWNER/REPO/issues/N`, or with `N` from a checkout of that repository.
End state: an open PR from branch `capstan/N` whose body has the line `Capstan: OWNER/REPO#N`, and the issue labeled `capstan:ready-to-deploy`, meaning GitHub says the PR can merge immediately.
Other stops: `capstan:blocked` with reason `review-exhausted` (see [code-review convergence](../../references/review-convergence.md): "## Bounded rounds and recurrence", "## Coordinator-evidence findings"); one typed human action for missing credentials, permissions, purchase decisions, required approvals, a prerequisite to merge, consequential product choices, or budget decisions; or user cancellation.
The work happens in the worktree `.worktrees/capstan+N` of the target repository.
Repository check: `bash scripts/test-launch.sh` tests the coordinator's launch builder `scripts/launch.sh`; CI runs that check from [.github/workflows/check.yml](../../.github/workflows/check.yml).

## Gotchas
- Capstan never merges or deploys; `capstan:ready-to-deploy` is the live gate, not a deploy step.
- Run only one coordinator per issue at a time.
- Changing the issue title does not change the branch, the worktree, or the marked PR lookup.
- Issues by authors other than OWNER, MEMBER, or COLLABORATOR need confirmation; untrusted comments are excluded by default.
- A worktree is not a security sandbox.
- Removing or replacing a user-visible surface is asked in the run even when the issue states it; [triage](../../references/triage.md) ("removes or replaces an existing user-visible surface") owns that rule.
- With residual-effect approval on, GitHub forbids approving your own PR, so a solo repository needs a second human account.
- Triage runs a prototype instead of asking when running something answers a node; [triage](../../references/triage.md) ("settle it as Evidence by running a prototype") owns that rule.
- The initial plan carries the touched files' recent history as evidence; [planning](../../references/planning.md) ("runs the history sweep once") owns that rule.
- Check scripts that a plan writes are built to one rule; [planning](../../references/planning.md) ("A check script the plan writes") owns that rule.
- Design comparisons in plans: [planning](../../references/planning.md) ("Those designs are compared at equal reuse") owns that rule.
- Bite timing for evidence checks the initial plan writes: [pack](../../references/pack.md) ("An evidence check the initial plan writes") owns that rule.
- Per-item plants when an evidence check claims to preserve an inventory or a set of cases: [pack](../../references/pack.md) ("When an evidence check claims to preserve an inventory or a set of cases") owns that rule.
- Real-run evidence checklist: [pack](../../references/pack.md) ("Real-run evidence checklist") owns that rule.
- Review findings in the coordinator's own evidence: [code-review convergence](../../references/review-convergence.md) ("## Coordinator-evidence findings") owns that rule.
- Citations in plans and packs: [pack](../../references/pack.md) ("Citation rule") owns that rule.
- Pack check: [pack](../../references/pack.md) ("Pack check:") owns the rule, and [shared harness](../../references/harnesses/shared.md) ("The coordinator runs the pack check") owns when it runs.
- Owners of changed rule sentences: [CONTRIBUTING.md](../../CONTRIBUTING.md) ("**Section contradiction.**") owns the authoring obligation and review's comparison; [planning](../../references/planning.md) ("lists the owners that") owns the plan's owner list, and [pack](../../references/pack.md) ("states a rule on a behavior those criteria change") owns the planning pack's owner entries.
- Sentences a plan adds outside their rule owner: [plan template](../../templates/plan.md) ("## Sentences outside their rule owner") owns the plan's list, and [CONTRIBUTING.md](../../CONTRIBUTING.md) ("**Restated rule.**") owns review's comparison.
- Base cases and changed evidence checks in the bite: [pack](../../references/pack.md) ("A check group whose planned assertion requires") owns that rule.
- Later-round code-review Candidate and its fallback to the cumulative diff: [pack](../../references/pack.md) ("A code-review pack for round 2 and later instead carries") owns that rule.
- Shared red runs in implementing: [implementing](../../references/implementing.md) ("One run of a check is the red observation") owns that rule.
- A delivery's summary discloses finding classes and friction that recurred in two or more earlier deliveries and suggests the correction mode; [telemetry](../../references/telemetry.md) ("This section owns earlier deliveries") owns that rule.
- A spec dependency can stop a delivery before it starts; [contract](../../references/contract.md) ("## Start condition") owns that rule.
- Cross-repository requests: [triage](../../references/triage.md) ("A criterion that is not verifiable in this repository is an Ask") owns the criterion rule; [contract](../../references/contract.md) ("## Start condition") owns dependencies.
- Post-merge checks: [triage](../../references/triage.md) ("Visit every stated outcome as a node") owns the classification; [end of run](../../references/end-of-run.md) ("`## Post-merge checks` section contains that section copied verbatim") owns the ready-to-deploy summary heading.
- Trusted comments after the spec: [pre-merge](../../references/pre-merge.md) ("Newer trusted comments") owns the check.
- Codex read launches: [Codex adapter](../../references/harnesses/codex.md) ("The read recipe, for kinds") owns the recipe, and ("owns the Codex read-station result rule") owns the read-station result rule.
- Claude read launches: [Claude adapter](../../references/harnesses/claude.md) ("For read stations use") owns the read recipe, and ("Allowlist probe evidence") owns the commands its allowlist does not constrain.
- Write-station shell commands, evidence-check runs, check logs, and identical reruns: [brief template](../../templates/brief.md) ("## Worker constraints") owns that rule.
- Denied spec publish: [triage](../../references/triage.md) ("A denied spec publish is a host permission refusal") owns that rule.
- Denied coordinator steps: [recovery](../../references/recovery.md) ("## Denied coordinator step") owns the outcome; [Claude adapter](../../references/harnesses/claude.md) ("## Claude Code host") owns the host command shapes and the optional operator settings.
- Probe capture: [shared harness](../../references/harnesses/shared.md) ("A run script that `scripts/launch.sh write` writes takes `--capture DIR`") owns how a run script captures its run.
- Coordinator waits: [shared harness](../../references/harnesses/shared.md) ("including a launch probe") owns the worker-launch and launch-probe wait, and ("The coordinator runs a silent check") owns the silent-check wait; [pre-merge](../../references/pre-merge.md) ("Wait for pending checks with one background process") owns the CI wait.
- Worker check records: [shared harness](../../references/harnesses/shared.md) ("The coordinator accepts a same-head check record") owns when the coordinator accepts a write worker's declared-check record instead of running the check again.
- Heavy checks: [planning](../../references/planning.md) ("Mark each declared check heavy or not heavy") owns the mark and the check order, ("the plan declares a targeted test") owns targeted tests, and ("A plan item's verification command is never a heavy check") owns item verification; [toolchain](../../references/toolchain.md) ("A heavy check's exact invocation is") owns the heavy-check lock and its slots; [contract](../../references/contract.md) ("`heavy_checks.max_concurrent` is a positive integer") owns the heavy-check concurrency setting; [Claude adapter](../../references/harnesses/claude.md) ("A heavy check at a write station gets no allow entry") owns which heavy checks a Claude write station leaves to the coordinator.
