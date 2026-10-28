# Architect

## Sub-features
- A read-only report that grades this repository, or named paths in it, against rules Foreman ships; [architect](../../references/modes/architect.md) ("## Rubric") owns the rubric rows.
- A feature-map result: an adoption recommendation when no map resolves, a disabled note when the map is disabled, or the entry points no feature file covers with an audit recommendation.
- Findings ranked by severity, then the coverage limits; [architect](../../references/modes/architect.md) ("## Report") owns the report shape.

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes, and invoke it from a workspace inside the repository's git work tree.
[architect](../../references/modes/architect.md) ("This file owns the architect invocation") owns the procedure.

## Driving it
Invocation: invoke Foreman with `architect`, alone or followed by paths in the repository, for example `architect references/modes`.
End state: Foreman prints one report and stops. Its first line names the work tree and its HEAD SHA. `git status --porcelain` output, labels, issues, comments, branches, worktrees, and evidence files are unchanged.

## Gotchas
- A path that does not exist prints an unknown-path line, and nothing is graded.
- A token outside the argument grammar [architect](../../references/modes/architect.md) ("## Argument grammar") owns makes the invocation text intake; see [text invocation](text-invocation.md).
- Paths narrow which findings are reported, not which rules apply: every rubric row and the feature map are still graded, reading repository files outside the paths where a row needs them, and a row that does not apply to the paths is listed with its reason under Coverage.
- `architect .` grades the whole work tree, the same as `architect` alone.
- Untracked files that are not ignored are graded; ignored files are listed under Coverage as not read.
- Outside a git work tree it prints that no repository resolved.
- It starts no worker and applies no recommendation.
