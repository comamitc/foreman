# Status

## Sub-features
- A read-only report of this repository's open issues that carry a Foreman stage label or the `foreman:blocked` overlay.
- For each listed issue: stage, blocker, marked PR, the live gate when it is ready-to-deploy, and the resume invocation; [status](../../references/modes/status.md) ("## Report") owns the report shape.

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes, and invoke it from a workspace inside the repository.
[status](../../references/modes/status.md) ("This file owns the status invocation") owns the procedure.

## Driving it
Invocation: invoke Foreman with exactly `status`, lowercase, and nothing else.
End state: Foreman prints one report and stops; labels, comments, issues, worktrees, branches, and evidence files are unchanged.
With no matching open issue, the report says that no open issue carries a Foreman stage label or `foreman:blocked`.

## Gotchas
- `status` with any other text enters text intake, subject to its checks; see [text invocation](text-invocation.md).
- Contradictory labels are reported, not repaired.
- An incomplete read prints a retrieval-incomplete line and no partial table.
- Outside a resolvable repository it prints that no repository resolved and asks for nothing.
- It starts no worker and runs no triage or init.
