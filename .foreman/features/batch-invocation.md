# Batch invocation

## Sub-features
- One invocation that names two or more issues in one repository.
- Dependency order among the issues in the batch.
- Triage of every issue before any issue enters unattended delivery.
- Per-issue branch, worktree, labels, ledger, spec, PR, and ready gate.
- Opt-in boundary pass; [boundary pass](../../references/modes/boundary-pass.md) ("## Triggers") owns when it runs.

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes.
[batch invocation](../../references/modes/batch-invocation.md) ("This file owns batch invocation order") owns the procedure.

## Driving it
Invocation: invoke Foreman with two or more distinct issues as issue URLs or issue numbers, separated by spaces or commas, with nothing else but allowed overrides, for example `12, 14`.
End state: the issues are delivered one at a time in dependency order. Each stops at `capstan:ready-to-deploy` or a `capstan:blocked` overlay and gets its own summary. One final message lists every issue with its outcome and attempt table.

## Gotchas
- Prose that mentions issues is not a batch; [contract](../../references/contract.md) ("## Identity and authority") governs it.
- [contract](../../references/contract.md) ("## Start condition") owns the dependency source; [batch invocation](../../references/modes/batch-invocation.md) ("The invocation has no dependency syntax") owns the invocation form.
- [contract](../../references/contract.md) ("## Start condition") owns when a dependent starts and the blocker it gets when it does not.
- Dependencies in another repository: [batch invocation](../../references/modes/batch-invocation.md) ("including every entry in another repository") owns their ordering.
- Issues from more than one repository start nothing.
