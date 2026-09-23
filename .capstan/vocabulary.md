**Repository-scoped term**: a meaning later deliveries in this repository will need. Rejected: a decision that binds only this issue.

**Delivery-scoped decision**: a settlement that binds only this issue or this change. Rejected: copying it into `.capstan/vocabulary.md`.

**Vocabulary file**: `.capstan/vocabulary.md`. Rejected: `CONTEXT.md` or a host skill.

**Rung**: one step on the ladder. The first rung that holds is the one that gets written. Rejected: writing a lower rung and justifying it.

**Higher rung**: the earlier stop. Existing code is higher than a new helper. A native feature is higher than a new dependency. Rejected: treating a new file as higher than existing code.

**Never-cut list**: validation, data-loss handling, security, accessibility, and admitted requirements. These are not simplifications. Rejected: deleting a guard to hit a line-count target.

**Ceiling comment**: one line naming a known limit and the condition that would justify replacing it. Rejected: a new abstraction for that limit.

**Declared check**: a verification command the plan or the repository conventions already name. Rejected: a command Capstan invents from a file extension.

**Toolchain**: the resolved invocation for a declared check, plus the task environment when the repo's own tool requires one. Rejected: a global package manager assumed to be on `PATH`.

**Identity**: the bytes of the lockfile or manifest that produced the toolchain. Not a language version. Rejected: a language-version pin.

**Provenance**: which precedence step supplied the invocation. Rejected: a model judgment with no recorded step.

**Init**: the explicit setup procedure that writes an absent `.capstan.json` and ensures the Capstan label set. Rejected: a Capstan binary or a delivery station.

**Observed harness**: a harness CLI that answered its documented help command on `PATH` during this init. Rejected: a harness named without that answer.

**Feature map**: `README.md` plus one Markdown file per user-facing feature. Rejected: a host skill directory or a stored source analysis.

**User-facing feature**: a behavior a person reaches through a screen, a command, or a job. Rejected: an internal module with no person-facing reach path.

**Reported cost**: a dollar figure present in the installed CLI's own event or session record for that attempt. Rejected: a public list price.

**Estimate**: a number produced from a price table, a credit balance delta, or an operator default. Capstan does not record one as cost. Rejected: writing an estimate into the cost cell.

**Linked worktree git directory**: `<repo>/.git/worktrees/capstan+N`, where Git writes `index.lock` for `capstan/N`. Rejected: the worktree root.

**Common git directory**: the directory `git rev-parse --git-common-dir` prints, where objects are written. Rejected: the worktree's `.git` file.

**Metadata grant**: the smallest host flag that makes those two paths writable for a commit. Not a permission bypass. Rejected: `unsafe_autonomy` or a home-directory grant.

**Contributor instruction file**: text a harness loads because this checkout is the working tree. It is not the target repository's instructions during a delivery into another repository. Rejected: station procedure.

**Skill package**: this repository root. The install symlink points at it. Rejected: a per-host copy of `SKILL.md`.

**Host manifest**: a plugin or marketplace file an installer requires before it will load the skill. `agents/openai.yaml` is not one. It is Codex presentation metadata. Rejected: a dot-folder per harness.

**Bot claim**: a pull-request comment or review from a non-human author. It is not yet a finding. Rejected: a hardcoded login list.

**Dismissal**: a published reason that the claim is noise, out of scope, already fixed, or not reproducible on the current head. Rejected: silence.
