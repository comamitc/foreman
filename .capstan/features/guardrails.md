# Guardrails

## Sub-features
- A read-only inventory of this repository's guardrails, each with whether it runs and its run evidence or the reason none exists, plus observations of CI jobs that run the same command on the same trigger; [guardrails](../../references/modes/guardrails.md) ("## Procedure") owns the inventory step.
- A tier summary and grading of this repository's test files, or those under named paths, against Foreman's check rules, including user-facing behaviors with no end-to-end path; [guardrails](../../references/modes/guardrails.md) ("## Finding sources") owns the finding sources.
- Findings ranked by severity, then the coverage limits; [guardrails](../../references/modes/guardrails.md) ("## Report") owns the report shape.

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes, and invoke it from a workspace inside the repository's git work tree.
[guardrails](../../references/modes/guardrails.md) ("This file owns the guardrails invocation") owns the procedure.

## Driving it
Invocation: invoke Foreman with `guardrails`, alone or followed by paths in the repository, for example `guardrails tests`.
End state: Foreman prints one report and stops. Its first line names the work tree and its HEAD SHA. No test suite, build, hook, or workflow ran, and `git status --porcelain` output, labels, issues, comments, branches, worktrees, workflow runs, and evidence files are unchanged.

## Gotchas
- A path that does not exist prints an unknown-path line, and nothing is graded.
- A token outside the path-token grammar [architect](../../references/modes/architect.md) ("## Argument grammar") owns makes the invocation text intake; see [text invocation](text-invocation.md).
- Paths narrow which test files and behaviors are graded; the guardrail inventory always covers the whole work tree.
- `guardrails .` grades the same scope as `guardrails` alone.
- A guardrail with no readable run history is listed under Coverage as a gap, never as passing; when no GitHub repository resolves, every CI workflow is a gap.
- Local pre-commit hooks are read, never run, and always land under Coverage gaps, because Git keeps no record of hook runs.
- Jobs that run the same command on the same trigger are listed under Observations, never as findings.
- Behaviors are found from the README and manifests, not from the tests, so a command with no tests can still be reported; a behavior neither declares is not found.
- Outside a git work tree it prints that no repository resolved.
- It runs no test, starts no worker, and applies no recommendation.
