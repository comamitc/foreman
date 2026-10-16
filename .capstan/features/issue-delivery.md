# Issue delivery

## Sub-features
- Delivery from an issue URL, or from an issue number that resolves in the current checkout.
- Resume: the same invocation resumes the delivery.
- Overrides in the invocation, such as the worker roles or a wall budget.
- Triage questions; [triage](../../references/triage.md) ("An ask is one numbered round of the current frontier.") owns them.
- Stage labels from `capstan:triage` to `capstan:ready-to-deploy`, and the `capstan:blocked` overlay.
- Optional `.capstan.json` configuration; [README](../../README.md) ("Configuration") lists the fields.
- Opt-in residual-effect approval; [pre-merge](../../references/pre-merge.md) owns it.
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
- Real-run evidence checklist: [pack](../../references/pack.md) ("Real-run evidence checklist") owns that rule.
- Review findings in the coordinator's own evidence: [code-review convergence](../../references/review-convergence.md) ("## Coordinator-evidence findings") owns that rule.
- Citations in plans and packs: [pack](../../references/pack.md) ("Citation rule") owns that rule.
- A delivery's summary discloses finding classes and friction that recurred in two or more earlier deliveries and suggests the correction mode; [telemetry](../../references/telemetry.md) ("This section owns earlier deliveries") owns that rule.
- A spec dependency can stop a delivery before it starts; [contract](../../references/contract.md) ("## Start condition") owns that rule.
- Cross-repository requests: [triage](../../references/triage.md) ("A criterion that is not verifiable in this repository is an Ask") owns the criterion rule; [contract](../../references/contract.md) ("## Start condition") owns dependencies.
- Post-merge checks: [triage](../../references/triage.md) ("Visit every stated outcome as a node") owns the classification; [end of run](../../references/end-of-run.md) ("`## Post-merge checks` section contains that section copied verbatim") owns the ready-to-deploy summary heading.
- Trusted comments after the spec: [pre-merge](../../references/pre-merge.md) ("Newer trusted comments") owns the check.
- Codex read launches: [Codex adapter](../../references/harnesses/codex.md) ("The read recipe, for kinds") owns the recipe, and ("owns the Codex read-station result rule") owns the read-station result rule.
- Write-station shell commands and evidence-check runs: [brief template](../../templates/brief.md) ("## Worker constraints") owns that rule.
- Denied spec publish: [triage](../../references/triage.md) ("A denied spec publish is a host permission refusal") owns that rule.
- Probe capture: [shared harness](../../references/harnesses/shared.md) ("A run script that `scripts/launch.sh write` writes takes `--capture DIR`") owns how a run script captures its run.
