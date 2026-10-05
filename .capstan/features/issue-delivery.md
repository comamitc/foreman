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

## How to get to it (user POV)
Install Capstan as [README](../../README.md) ("Install and invoke") describes, then invoke it explicitly from the host's skill menu.
Frontmatter disables model invocation; if a host version ignores invocation metadata, verify its discovery behavior before use.
Prerequisites are git, authenticated `gh` with repository write access, and configured harness CLIs on `PATH`.

## Driving it
Invocation: invoke Capstan with the issue URL `https://github.com/OWNER/REPO/issues/N`, or with `N` from a checkout of that repository.
End state: an open PR from branch `capstan/N` whose body has the line `Capstan: OWNER/REPO#N`, and the issue labeled `capstan:ready-to-deploy`, meaning GitHub says the PR can merge immediately.
Other stops: `capstan:blocked` with reason `review-exhausted` when effective review blockers remain at the round ceiling; one typed human action for missing credentials, permissions, purchase decisions, required approvals, consequential product choices, or budget decisions; or user cancellation.
The work happens in the worktree `.worktrees/capstan+N` of the target repository.
Repository check: `bash scripts/test-launch.sh` is the test script for the launch builder `scripts/launch.sh` that the coordinator runs.

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
