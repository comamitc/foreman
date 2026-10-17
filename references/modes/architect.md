# Architect invocation

Load this file only when [contract](../contract.md) "## Read-only invocations" dispatches the `architect` keyword.

This file owns the architect invocation.

## Argument grammar

The invocation is `architect` followed by zero or more path tokens. A path token is relative to the invoking workspace's git work tree: it does not start with `/`, contains no `..` segment, and is not a URL (it contains no `://`). Any other token makes the invocation text intake, as [contract](../contract.md) "## Read-only invocations" states.

A path token that matches this grammar but names nothing in the work tree is an unknown path. Procedure step 3 reports it and grades nothing. It does not make the invocation text intake.

## Scope

The scope root is the invoking workspace's git work tree, read from local files. `gh repo view` only names the report's repository; it is not needed to grade.

With no path token, the scope is the whole work tree. Path tokens narrow the scope to the union of those files and directories; `.` names the whole work tree, so `architect .` grades the same scope as `architect` alone. Paths narrow the subject of findings, not the rubric: every row in "## Rubric" and "## Feature map" is graded for every scope, and grading reads repository context outside the scope where a row needs it, such as the root instruction files, the runner and manifest files, the vocabulary file, and the feature-map index. A finding is reported only when its subject is in the scope or governs it: a module or mistake class in the scope, the runner or verification path that covers it, an instruction file or vocabulary file that applies to it, or an entry point declared or implemented in it. A row that cannot apply to the scope is listed under the report's `Not applicable:` line with its reason.

## Procedure

The coordinator does every read and all grading in the invoking session. [contract](../contract.md) "## Read-only invocations" owns the rules this procedure follows. This file's stricter rule: the procedure runs only file reads, `git` read commands, and `gh repo view`; it does not run the repository's runner, tests, or build.

1. **Parse.** Split the trimmed invocation into tokens. Every token after `architect` is a path token.
2. **Repository.** Run `git rev-parse --show-toplevel` in the invoking workspace. If it fails, print `Capstan architect: no repository resolved.` and stop. Below, `W` is its output. Read the HEAD SHA with `git -C W rev-parse HEAD` and the work-tree state with `GIT_OPTIONAL_LOCKS=0 git -C W status --porcelain`. Run `gh repo view --json nameWithOwner --jq .nameWithOwner` in `W`; a failure leaves the report with no repository name and is not an error.
3. **Paths.** A path token whose `W/<token>` does not exist is an unknown path. If any exists, print `Capstan architect: unknown path <token>[, <token>…]; nothing graded.` listing each, and stop.
4. **Inventory.** List the scope's files with `git -C W ls-files --cached --others --exclude-standard`, followed by `-- <token>…` when there are path tokens: tracked files and untracked files that are not ignored. List the ignored files the same way with `git -C W ls-files --others --ignored --exclude-standard --directory`; they are not read, and the report names them under `Not read:`. Whatever the scope, read in full the root contributor instruction files, the README, the runner and manifest files at the root, the vocabulary file when one exists, and the feature-map index when a map resolves. Read the rest of the scope in full when it is small; otherwise sample it, and record how each sample was chosen. Record every source read in full, sampled, or not read, marking each untracked one, and every unreadable or partial source.
5. **Grade.** Apply every row of "## Rubric", then "## Feature map", as "## Scope" states. Record each finding with the fields the report needs, and each row or case that does not apply with its reason. Evidence is `path:line` relative to `W`.
6. **Rank.** Give each finding a severity from [review-convergence](../review-convergence.md) "Use this calibration in every code-review brief". Order findings by severity, highest first, then by row order in "## Rubric", with the feature-map finding last within its severity.
7. **Print.** Print the report under "## Report" once, then stop.

## Rubric

Grade only these rows. Each row's owner states the rule; this file names it and does not restate it. A finding's Rule is its row's owner file and quoted heading. Grading invents no other rubric.

| Row | Owner and anchor | Graded |
|---|---|---|
| Module | [ladder](../ladder.md) "## Module": "Red flags:", "Apply the deletion test", "Add a seam only where something actually varies", and "Assume the next contributor is an agent" | each module in scope |
| Enforcement | [ladder](../ladder.md) "## Enforcement" ("Pick the highest level that works") | each mistake class the scope lets an agent make, with the highest level that would rule it out |
| Toolchain | [toolchain](../toolchain.md) "Take commands from the plan's named checks, then the repository's documented runner." and "The worker does not discover a command, a runner, or a tool path." | whether one declared runner exists that covers the scope |
| Navigation: pointers | [vocabulary](../../.capstan/vocabulary.md) "Rule owner" ("Other files name it and do not restate the rule.") | whether the instruction files that apply to the scope hold pointers rather than rule bodies |
| Navigation: vocabulary | [triage](../triage.md) "# Triage — coordinator" ("When `.capstan/vocabulary.md` exists, read it after repository instructions" and "A missing file is recorded and does not block.") | whether `W/.capstan/vocabulary.md` exists |
| Verification path | [verification-path adoption](verification-path.md) "Record these seven steps" | whether a recorded verification path exists that covers the scope |

The Navigation: vocabulary row keeps triage's qualification that a missing vocabulary file does not block: its finding has the lowest severity in the calibration that Procedure step 6 cites, and its title says it does not block. A present vocabulary file makes no finding in this row.

The ladder's "This section applies only to a module the change adds or reshapes" governs deliveries. A Module finding only recommends a reshape; the issue body it proposes is the admitted task that would reshape the module.

## Feature map

Resolve the map as [contract](../contract.md) ("`features` is the optional feature-map field") specifies, from the environment and `W/.capstan.json`. This invocation carries no override. Exactly one case applies:

- **No map resolves**, including a missing explicit path: one Navigation finding. Its Fix is a ready-to-paste Capstan text invocation, in the host's explicit form from [README](../../README.md) "Install and invoke", stating that the outcome is feature-map adoption for this repository. [feature-map adoption](feature-map-adoption.md) ("This file owns feature-map adoption") owns that run.
- **Disabled** (`features: null`): the report's feature-map line says it is disabled by configuration. No adoption finding is made.
- **A map resolves**: one finding that lists each user-facing entry point no indexed feature file covers, such as a command, binary, route, or invocation the README or a manifest declares, each with its evidence. For a scope narrowed by path tokens, the entry points are those declared or implemented in the scope. Its Rule is [feature-map audit](feature-map-audit.md) ("newly user-facing behavior absent from a present map"). Its Fix is a ready-to-paste Capstan text invocation stating that the outcome is an audit of the configured feature map; [feature-map audit](feature-map-audit.md) ("This file owns the feature-map audit") owns that run. This check is coverage only. When every entry point is covered, there is no finding.

## Report

- The first line is `Capstan architect — W @ <HEAD SHA>`, then ` (<nameWithOwner>)` when step 2 resolved one.
- Then `Scope: whole work tree` or `Scope: ` and the path tokens; `Work tree: uncommitted changes present.` when `git status --porcelain` printed anything; and `Feature map: <path>`, `Feature map: disabled by configuration (features: null).`, or `Feature map: none resolved.`.
- Then one blank line and the findings in rank order. Each starts `N. [<severity>] <title>` and holds the five fields [contract](../contract.md) "## Read-only invocations" names, in its order. The Issue body is a fenced block.
- With no finding, the line `No findings.`
- The last block starts `Coverage:` and holds `Read in full:`; `Sampled:` with how each sample was chosen; `Not read:` with each source in the scope not read, the ignored files from Procedure step 4 included; `Not applicable:` with each rubric row or feature-map case that does not apply to the scope and its reason, or `none`; and `Gaps:` with each unreadable or partial source, or `none`. An untracked file is marked `(untracked)` wherever it is listed.

## Review

A finding whose Rule is not a row in "## Rubric", the feature-map adoption owner for the no-map case, or the feature-map audit anchor blocks. A rubric rule restated in this file instead of named by owner and anchor blocks. A report with no `Coverage:` block blocks. A rubric row or feature-map case skipped for a scope without a `Not applicable:` reason blocks. An inventory that drops untracked, non-ignored files in the scope without listing them in Coverage blocks. An architect run that changes a file, label, issue, comment, branch, or worktree blocks. A procedure step that can take the index lock blocks; [contract](../contract.md) "## Read-only invocations" ("Every read-only invocation follows these rules") owns the lock rule.
