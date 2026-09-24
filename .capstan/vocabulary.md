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

**Host session**: the interactive session that invoked Capstan. Its interface is the coordinator's visible final message. Rejected: a worker transcript or a host plugin.

**Stage analysis**: the station-attempt table and two wall totals defined by #29. Rejected: a second host-specific wording.

**Text invocation**: an explicit Capstan invocation that is prose, not an issue URL, not an in-repo issue number, and not another GitHub URL. It creates one issue and then starts that issue's delivery. Rejected: a filesystem path or the surrounding transcript.

**Provisional title**: the issue title set to the first non-empty line of a text invocation, kept only while the live title still equals that line. Rejected: a title taken from the surrounding transcript, or a title a person already changed.

**Delivery identity**: `owner/repo#N` of the issue the delivery runs. A text invocation does not replace it. Rejected: a hashed text branch name.

**Blocked overlay**: the `capstan:blocked` label Capstan adds beside the stage label. Rejected: a label named `blocked`, or a GitHub issue dependency.

**Publication boundary**: the point after local code review converges and base freshness is confirmed, when Capstan first pushes the exact reviewed candidate and creates or reconciles the pull request. Rejected: every implementing or fix completion.

**Local CI**: the declared checks run on the local machine during the local loop, including tests and the other commands the plan or repository conventions already name. Rejected: a GitHub Actions replay or a workflow parser.

**Fetched base**: the SHA `git fetch` stored for `origin/<resolved base>` in this run, immediately before the worktree is created. Rejected: local `main`, or an `origin/main` ref from an earlier run.

**Rule owner**: the single file that states a behavioral rule. Other files name it and do not restate the rule. Rejected: a second full copy.

**Stub result**: a worker exit that is not a captured result. The rule owner is `references/harnesses/shared.md`. Rejected: treating exit 0, a commit SHA, or a stall percent as station completion.

**Invoker ask**: a question to the person who invoked this run, required before ready when a decision removes or replaces an existing user-visible surface. Rejected: treating the issue Decisions section as that confirmation. The rule owner is `references/triage.md`.

**Silent check**: a declared check that can stay silent longer than the selected harness's command-log window. The rule owner is `references/harnesses/shared.md`. Rejected: missing streamed output treated as a stall, or a second copy of that rule.

**Host adapter**: the file that states one harness's launch flags and usage extraction. Rejected: all hosts' flags in the shared harness file.
