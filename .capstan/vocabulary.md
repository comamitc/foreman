**Repository-scoped term**: a meaning later deliveries in this repository will need. Rejected: a decision that binds only this issue.

**Delivery-scoped decision**: a settlement that binds only this issue or this change. Rejected: copying it into `.capstan/vocabulary.md`.

**Vocabulary file**: `.capstan/vocabulary.md`. Rejected: `CONTEXT.md` or a host skill.

**Rung**: one step on the ladder. The first rung that holds is the one that gets written. Rejected: writing a lower rung and justifying it.

**Higher rung**: the earlier stop. Existing code is higher than a new helper. A native feature is higher than a new dependency. Rejected: treating a new file as higher than existing code.

**Never-cut list**: validation, data-loss handling, security, accessibility, and admitted requirements. These are not simplifications. Rejected: deleting a guard to hit a line-count target.

**Ceiling comment**: one line naming a known limit and the condition that would justify replacing it. Rejected: a new abstraction for that limit.

**Declared check**: a verification command the plan or the repository conventions already name. Rejected: a command Capstan invents from a file extension; an evidence check the coordinator writes from plan text, even when the plan quotes its command.

**Toolchain**: the resolved invocation for a declared check, plus the task environment when the repo's own tool requires one. Rejected: a global package manager assumed to be on `PATH`.

**Identity**: the bytes of the lockfile or manifest that produced the toolchain. Not a language version. Rejected: a language-version pin.

**Provenance**: which precedence step supplied the invocation. Rejected: a model judgment with no recorded step.

**Init**: the explicit setup procedure that writes an absent `.capstan.json` and ensures the Capstan label set. The init invocation is exactly `init`. The rule owner is `references/contract.md` ("### Init"). Rejected: a Capstan binary, a delivery station, or a read-only invocation.

**Observed harness**: a harness CLI that answered its documented help command on `PATH` during this init. Rejected: a harness named without that answer.

**Feature map**: `README.md` plus one Markdown file per user-facing feature. Rejected: a host skill directory or a stored source analysis.

**User-facing feature**: a behavior a person reaches through a screen, a command, or a job. Rejected: an internal module with no person-facing reach path.

**Estimate**: a usage figure produced from a price table, a credit balance delta, or an operator default. Capstan records none. Rejected: writing an estimate into a usage cell.

**Ledger**: `ledger.md`, the retained local record of totals and check outcomes. Always written. The rule owner is `references/telemetry.md`. Rejected: a switch that disables it.

**Pile**: briefs, results, worker captures, check scripts and logs, the task toolchain, and `events.jsonl`. Exact paths: `briefs/`, `results/`, `workers/`, `checks/`, `toolchain/`, `tooling/`, and `events.jsonl`. Rejected: `ledger.md`.

**Deletion switch**: `evidence.delete_pile`. It authorizes success-path removal of the pile and this run's worktree. It never authorizes removal of the ledger. Rejected: a second flag.

**Check outcome**: the head, command, exit, and pass or fail signal. Not the script body. Rejected: treating `checks/fix-4-red.py` as the record.

**Unknown**: the required state when a number was never reported, or was deleted before the ledger contained it. Not zero. Rejected: an estimate.

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

**Text invocation**: an explicit Capstan invocation that is prose, not an issue URL, not an in-repo issue number, not another GitHub URL, and not a batch invocation's issue list, not the status invocation, not the init invocation, not a help invocation. It creates one issue and then starts that issue's delivery. Rejected: a filesystem path or the surrounding transcript.

**Provisional title**: the issue title set to the first non-empty line of a text invocation, kept only while the live title still equals that line. Rejected: a title taken from the surrounding transcript, or a title a person already changed.

**Delivery identity**: `owner/repo#N` of the issue the delivery runs. A text invocation does not replace it. Rejected: a hashed text branch name.

**Blocked overlay**: the `capstan:blocked` label Capstan adds beside the stage label. Rejected: a label named `blocked`, or a GitHub issue dependency.

**Denied spec publish**: an outcome of the triage spec publish. The rule owner is `references/triage.md` ("A denied spec publish is a host permission refusal"). Rejected: a GitHub API error from a command that ran.

**Publication boundary**: the point after local code review converges and base freshness is confirmed, when Capstan first pushes the exact reviewed candidate and creates or reconciles the pull request. Rejected: every implementing or fix completion.

**Local CI**: the declared checks run on the local machine during the local loop, including tests and the other commands the plan or repository conventions already name. Rejected: a GitHub Actions replay or a workflow parser.

**Fetched base**: the SHA `git fetch` stored for `origin/<resolved base>` in this run, immediately before the worktree is created. Rejected: local `main`, or an `origin/main` ref from an earlier run.

**Rule owner**: the single file that states a behavioral rule. Other files name it and do not restate the rule. Rejected: a second full copy.

**Stub result**: a worker exit that is not a captured result. The rule owner is `references/harnesses/shared.md`. Rejected: treating exit 0, a commit SHA, or a stall percent as station completion.

**Invoker ask**: a triage question. The rule owner is `references/triage.md`. Rejected: a second copy of that rule.

**Silent check**: a declared check that can stay silent longer than the selected harness's command-log window. The rule owner is `references/harnesses/shared.md`. Rejected: missing streamed output treated as a stall, or a second copy of that rule.

**Preflight proof**: the proof preflight runs for the brief's command before worker launch. The rule owner is `references/toolchain.md`. Rejected: a second copy of that procedure.

**Host adapter**: the file that states one harness's launch flags and usage extraction. Rejected: all hosts' flags in the shared harness file.

**Canonical document**: a durable product document that states user-visible or operational behavior. Rejected: a historical delivery artifact, a host transcript, or a new `docs/changes` tree.

**Documentation backfill**: a delivery mode admitted only when an issue or a text invocation states that outcome. `references/modes/documentation-backfill.md` ("This file owns documentation backfill") owns the mode. Rejected: ordinary delivery or init.

**Discriminating check**: a check that fails when the defect it claims to cover is present, and passes when the defect is corrected. Rejected: a check that restates the implementation's constant, mocks away the failure it names, or reads source text or field presence as a proxy for behavior.

**Residual effect**: a consequence of a change that reverting its code does not undo, such as an applied migration, changed or deleted data, a sent message, or another external write. The rule owner is `references/implementing.md`. Rejected: leaving the term undefined, or a numeric or tiered risk score.

**Review correction**: a trusted human reviewer's request to change a Capstan-delivered pull request, cited by URL and verified against its revision. The rule owner is `references/modes/improvement.md` ("This file owns the improvement invocation"). Rejected: untrusted or unverified feedback, a scan of repository history, or repetition treated as authority.

**No-new-violations guard**: a repository-native check that fails on any new violation and lists each grandfathered existing violation with its rationale. It is not a count ceiling. The rule owner is `references/modes/improvement.md` ("This file owns the improvement invocation"). Rejected: a count-only ceiling, an enlarged baseline, or a second lint stack.

**Verification path**: a target repository's documented, repeatable way to set up isolated state, drive one user operation, assert the observable result, capture evidence, and reset. It is not a generic Capstan driver. The rule owner is `references/modes/verification-path.md` ("This file owns verification-path adoption"). Rejected: a Capstan executable, runner, or driver, a new feature-map heading, or a tool registry.

**Performance requirement**: an admitted acceptance criterion, or an applicable existing repository budget, that names a user operation, a metric, and a threshold. The rule owner is `references/modes/performance-proof.md` ("This file owns performance proof"). Rejected: a universal frame, latency, or memory limit, or agent wall time or cost.

**Host status line**: one coordinator-posted line in the invoking host session for one event-table event or one changed supervision observation. It names the delivery, station, event, and one observed fact. The rule owner is `references/telemetry.md`. Rejected: a plugin, a notification command, a status-line API, or a worker-posted line.

**Launch probe**: one run of a role's exact launch recipe with a trivial prompt, in the issue worktree with the real grants, before an invocation's first worker launch, or before a fallback's first launch after recovery selects it. The rule owner is `references/harnesses/shared.md` ("## Launch probe"). Rejected: a help or version check; the toolchain preflight.

**Stable anchor**: a heading's exact text or a verbatim phrase of the target rule, named next to the owner-file link. Rejected: a line number.

**Mode file**: a file under `references/modes/` that holds one mode's rules and states its trigger in its first paragraph. The coordinator loads it only when that trigger holds. Rejected: a station, a stage, or a file workers read directly.

**Global non-goals**: the one contract section that lists the generic things Capstan never adds. It applies to every Capstan file and mode file. Rejected: per-paragraph non-goal tails.

**Batch invocation**: one invocation that names two or more issues in one repository and delivers them sequentially in dependency order. The rule owner is `references/modes/batch-invocation.md` ("This file owns batch invocation order"). Rejected: parallel delivery; stacked PRs.

**Start condition**: what must hold before a delivery starts. The rule owner is `references/contract.md` ("## Start condition"). Rejected: a batch ordering edge.

**Companion issue**: the issue in another repository that carries the half of a request this repository cannot verify. The rule owner is `references/triage.md` ("A criterion that is not verifiable in this repository is an Ask").

**Post-merge check**: a stated outcome that needs a merge, deploy, operator action, or elapsed time to observe. It is recorded for the operator. The rule owner is `references/triage.md` ("Visit every stated outcome as a node"). Rejected: a start condition; a step Capstan runs.

**Status invocation**: the explicit invocation `status`. It prints a read-only report of open issues that carry a Capstan stage label or the `capstan:blocked` overlay, and mutates nothing. The rule owner is `references/modes/status.md` ("This file owns the status invocation"). Rejected: a host status line (one event line during a run); a delivery.

**Read-only invocation**: an explicit invocation that a row in the keyword table of `references/contract.md` ("## Read-only invocations") names. It prints one report and mutates nothing. The rule owner is `references/contract.md` ("## Read-only invocations"). Rejected: a delivery, a text invocation, or a host status line.

**Architect invocation**: the explicit read-only invocation `architect`, optionally followed by paths. It grades the repository's agent-readiness against Capstan-owned rules and prints one ranked report. The rule owner is `references/modes/architect.md` ("This file owns the architect invocation"). Rejected: a delivery, a feature-map audit, or rules from outside Capstan.

**Guardrails invocation**: the explicit read-only invocation `guardrails`, optionally followed by paths. It inventories the repository's CI workflows, declared checks, and hooks with whether each runs, grades its tests against Capstan's check rules, and prints one ranked report. The rule owner is `references/modes/guardrails.md` ("This file owns the guardrails invocation"). Rejected: running the checks, a coverage percentage, or a Capstan test runner.

**Learn invocation**: the explicit read-only invocation `learn`, optionally followed by `repo OWNER/REPO` and `since YYYY-MM-DD` pairs. It reads every Capstan run on this machine across repositories and prints ranked Capstan-process proposals, with target-product learnings apart. The rule owner is `references/modes/learn.md` ("This file owns the learn invocation"). Rejected: filing issues, publishing anywhere, or a replay benchmark.

**Help invocation**: the explicit read-only invocation `help`, optionally followed by a question. It answers from the installed package and cites the owning file. The rule owner is `references/modes/help.md` ("This file owns the help invocation"). Rejected: starting the work a question asks for, filing an issue, or a GitHub-hosted guide.

**Host instructions**: instruction files a worker's harness loads from the operator's host configuration whatever the brief says, such as `~/.codex/AGENTS.md` or `~/.claude/CLAUDE.md`, and files they direct the worker to read. A brief does not forbid or contradict them. Rejected: a contributor instruction file; pack content.

**Evidence check**: a script or multi-step command the coordinator writes for a pack's `## Checks` from plan text, kept outside the repository; it stays an evidence check when the plan quotes its command. It is bitten against known-good text and a planted defect before a worker depends on it. The rule owner is `references/pack.md` ("An evidence check is bitten before the brief that depends on it launches"); `references/pack.md` ("An evidence check the initial plan writes") owns the bite at plan publication. Rejected: a declared check; a Capstan test runner.

**Coordinator-evidence finding**: a code-review finding in evidence the coordinator produced. The rule owner is `references/review-convergence.md` ("## Coordinator-evidence findings"). Rejected: "evidence-check finding".

**Verified delivery**: a delivery that reached `capstan:ready-to-deploy` with its live gate verified. The rule owner is `references/modes/improvement.md` ("Resource comparison."). Rejected: a merged PR, a draft, or an attempt that stopped blocked.

**Launch builder**: `scripts/launch.sh`. It writes and checks the run script for one Claude or Codex worker launch from structured inputs. Rejected: a builder that launches or supervises workers.

**Probe capture**: the record a run script that `scripts/launch.sh write` writes keeps about its own run, for a probe or a station. The rule owner is `references/harnesses/shared.md` ("A run script that `scripts/launch.sh write` writes takes `--capture DIR`"). Rejected: a capture the coordinator writes ad hoc per launch.

**Tool-call event**: an `events.jsonl` line with kind `tool-call` that times one coordinator worker process, check, or wait, or one tool call inside a Claude or Codex worker. The rule owner is `references/telemetry.md` ("Every event line is one JSON object"). Rejected: timing each coordinator `git` or `gh` read.

**Arrival time**: the UTC time the run script recorded when a line of the worker's redacted event stream arrived. It is the clock for worker tool-call durations. The rule owner is `references/telemetry.md` ("the arrival times of its start and end records"). Rejected: one clock reading for every line at harness exit.

**Policy row**: the `ledger.md` row that records one quoted repository rule, its applicability, how it was satisfied, its evidence and head, and its state. The rule owner is `references/telemetry.md`. Rejected: a policy-register file.

**Mandatory rule**: a quoted repository rule whose sentence contains one of the words `references/telemetry.md` lists. The rule owner is `references/telemetry.md`. Rejected: a risk score.

**Test tier**: the level at which a check exercises the change, highest first: end-to-end through the real entry point with real dependencies; integration at an API or data boundary against a real service; unit. The rule owner is `references/ladder.md` ("## Check"). Rejected: a tier the repository could reach only by adding infrastructure, a coverage target, or a mutation score.

**Module**: anything with an interface and an implementation, at any scale: a function, a file, a package. The rule owner is `references/ladder.md` ("## Module"). Rejected: a file or directory boundary alone; a layer named by the state it holds, such as a model or a store.

**Interface**: everything a caller must know to use a module correctly: signature, invariants, ordering, error modes, configuration. The rule owner is `references/ladder.md` ("## Module"). Rejected: the type signature alone.

**Seam**: the place where a module's interface lives, where behavior can be substituted without editing the caller. The rule owner is `references/ladder.md` ("## Module"). Rejected: an injection point or abstract interface added where nothing varies.

**Deep module**: a module with a small interface and substantial behavior behind it. The rule owner is `references/ladder.md` ("## Module"). Rejected: a shallow module whose interface is about as large as its behavior; a pass-through module.

**Ledger digest**: the SHA-256 of the final `ledger.md` bytes, published as `Ledger sha256: <hex>` in the marked summary. It is tamper-evident, not tamper-proof. The rule owner is `references/end-of-run.md`. Rejected: signing or attestation.

**Residual-effect approval**: the opt-in pre-merge gate that withholds `capstan:ready-to-deploy` until a human GitHub approval on the current head, when the PR's Blast Radius names residual effects or unknown reversibility. The field is `review_policy.residual_effect_approval`, default `false`. The rule owner is `references/pre-merge.md` (step 4). Rejected: a risk score or risk tier.

**Mistake class**: a recurring kind of review finding that occurred in two or more deliveries of one repository, cited by occurrence. The rule owner is `references/modes/correction.md` ("This file owns correction"). Rejected: a one-off finding.

**Friction signal**: evidence that a worker struggled without a finding: a pack gap, a repeated permission denial, a ceiling hit, a recovery attempt, or a defective evidence check. The rule owner is `references/modes/correction.md` ("This file owns correction"). Rejected: worker prose without a recorded artifact.

**Same-head check record**: a write worker's declared-check record that the coordinator accepts instead of running the check again. The rule owner is `references/harnesses/shared.md` ("The coordinator accepts a same-head check record"). Rejected: a worker sentence that checks passed.
