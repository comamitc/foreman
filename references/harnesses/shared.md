# Shared launch procedure

Verify the selected installed CLI's `--version` and `--help` before using its
adapter.
Recipe probe evidence: `references/harnesses/shared.md` at `cd38fa1`.
A probe is not proof that a task's filesystem/command permissions
work: the launch probe below verifies those in the issue worktree. Local CLI behavior is authoritative
when a newer release changes flags.

1. Resolve role/configuration using the contract. Null model/effort omits those
   flags intentionally; explicit unsupported effort is a visible configuration
   failure, not silently omitted. Record actual reported model or `default/unknown`.
2. Prepare owner-only brief, pack, and result paths outside the product tree. The
   brief names the pack as the worker's required task reading and, at read
   stations, the numeric turn ceiling; the pack is sized to the unit.
   The coordinator runs the pack check, `scripts/launch.sh pack PACK --worktree WORKTREE`, on each pack after its last edit and before the launch that uses it, and launches only after it exits 0; on exit 1 it adds each entry the error names and runs it again. [pack](../pack.md) ("Pack check:") owns what the check requires.
   A worker inherits its host's instructions: the files its harness loads from the operator's host configuration and the files they direct it to read.
   A brief never forbids reading them and never contradicts them.
   A brief contradicts host instructions when the worker cannot follow both at its station: a brief sentence forbids what a host instruction requires there, or requires what a host instruction forbids.
   A host instruction that differs from a Foreman delivery's completion endpoint or fetch-then-worktree order is not a brief defect: [references/contract.md](../contract.md) ("A host or user instruction file does not change") fixes both, and the brief states them as fixed.
   A conflict between a brief and host instructions is a brief defect: under [references/recovery.md](../recovery.md) ("## Observe, diagnose, retry"), amend the brief and relaunch the unfinished portion in the same station.
   An operation is one tool call: one read call or one shell command, however many
   files it names. Several tool calls in one assistant turn count separately. The
   ceiling is an upper bound, not an expected count: Named files entries plus
   Checks plus 7 (brief, pack, head before, status before, head after, status after, result delivery).
   A host-instruction read is not an operation: the worker lists it under `## Checks` as an unnumbered "Host-instruction read:" line, outside the ceiling.
   Before the read-station launch, observe how many lines one host read returns. If
   that page does not cover the pack, add one operation per page and name that count
   in the brief. Do not discover the count after the review starts.
   The worker's numbered list under `## Checks` is the operation count. The short
   launch prompt says: read this absolute brief, perform it, and write the result to
   this absolute path. `references/harnesses/codex.md` owns the stdin rule.
   `references/harnesses/grok.md` owns the read-only result rule.
   `references/harnesses/codex.md` owns the Codex read-station result rule. This
   file names those owners and does not restate those procedures. Where
   `references/harnesses/grok.md` or the Codex read-station result rule applies,
   use that owner's prompt instead of the write sentence in this paragraph. Put
   the launch prompt in an evidence file or
   stdin; do not expand the entire brief into argv. Read security before
   persistence/capture.
3. Use existing CLI controls for the narrowest unattended access the station needs.
   Inspect effective user/project settings for unsafe overrides without exposing
   secrets. Exclude unrelated plugins/skills/tools where the host supports it.
   Permission approval and filesystem sandboxing are distinct; disclose limitations.
4. Start a new process without continue/resume flags for each station. Run from the
   issue worktree, or from the working directory the station's recipe names: [references/harnesses/codex.md](codex.md) ("The read recipe, for kinds") owns the Codex read recipe. [references/harnesses/claude.md](claude.md) owns the Claude
   write-station grant. Record owned
   process/session and supervise output. On POSIX, an installed `timeout --signal=TERM --kill-after=10s 60m`
   can bound a process; verify its help or use the coordinator's process manager.
   Replace example 60m limits with the resolved worker_timeout_min, capped by
   remaining run budget. Timeout exit 124 is recovery evidence, not proof of no side effects.
   Every worker launch, including a launch probe, runs as a background process
   this run owns, never as one foreground call that holds the host until the
   worker exits. The coordinator resumes on its host's wake signal, which
   [claude.md](claude.md) ("## Claude Code host") or
   [codex-nested-host.md](codex-nested-host.md) ("## Nested host") names. The
   timeout above bounds it; [references/recovery.md](../recovery.md) ("Stop/hand off owned processes explicitly on cancel") owns stopping it.
   [references/telemetry.md](../telemetry.md) owns the host status line.

A silent check is a declared check that can stay silent longer than the selected harness's command-log window. That window is the harness's own. This rule adds no Foreman number or timeout. The worker_timeout_min bound and timeout exit 124 above still apply to the station process. They are not this check's result.

The coordinator runs a silent check. The worker brief does not tell the worker to start it.

Before the coordinator starts one, it looks at the worker process it already recorded for this station. Recognition succeeds only when that process has a live child whose command line equals the declared check invocation already written in the brief. The coordinator does not parse worker prose. If recognition succeeds, the coordinator does not start a second process. It does not signal, restart, or kill the recognized process, and it does not wrap that process in timeout. It waits until that process exits. Silence is not an exit. The command it records is the declared invocation that matched. The exit code and output are the ones that process produced. An empty captured stream is not a percent and is not an exit code.

That wait is not a foreground call. The coordinator did not start the recognized process and is not that process's parent, so it starts one background process this run owns that exits when the recognized process exits, and resumes on the host's wake signal (step 4 above). The worker_timeout_min bound applies to that wait process only; the recognized process stays unwrapped. The exit code and output come from the station's captured raw output (step 5 below) of the worker's run of the declared invocation. When that capture holds no exit code for it, the result records the exit code as not observed.

If recognition fails, the coordinator starts the check itself as a background process and waits for its exit on the host's wake signal (step 4 above). It does not ask the worker to start it. When it starts the check follows [references/planning.md](../planning.md) ("Mark each declared check heavy or not heavy").

A worker that is already running the check does not restart it, does not kill it, and does not treat missing streamed output as a stall. The check is complete only when the process exits. The recorded result is that exit code.

The station result records the coordinator's command, that exit code, and a summary of the output. A worker sentence that the check stalled at a percent is not a check result.
5. Capture redacted raw output plus the Markdown result. Record wall time and exit.
   Before the summary, copy the supervisor record's process start and process
   exit into the station-end ledger row; Worker wall is their difference. Wall
   time or uptime on the exit notice does not fill start, end, or Worker wall. It
   does not authorize `unknown` while that record still has them.
   [references/telemetry.md](../telemetry.md) owns the row fields ("The attempt table has these columns, in this order"),
   `unknown`, and the wall totals.
   Record the worker's operation count (its numbered lines under `## Checks`)
   against the brief ceiling. Record each harness
   native counter under its own name from the selected host file as cross-check
   telemetry. No native counter is the operation count, and none is compared
   with the ceiling. A completed event can be absent when a command fails before
   execution. Result delivery is a native tool event only when the worker runs
   it as a tool call; a final message alone is not one. Inspect the result and
   repository independently. If the worker cannot write an external result under
   its protection mode, accept Markdown in stdout, persist it as coordinator
   evidence, and verify it; do not weaken safety just for formatting.
   [claude.md](claude.md) ("Under a host grant the station result is the result file") owns the result of a Claude write station under a host grant.
   A run script that `scripts/launch.sh write` writes takes `--capture DIR`,
   `--events FILE`, `--delivery`, `--station` and `--attempt`, and `--redact-env NAME`
   for each credential variable the launch environment carries whose name the
   builder's pattern does not match. Its run script writes the **probe capture**
   for every kind, probe or station: `DIR/stdout` and `DIR/stderr` redacted before
   they are written, `DIR/exit` with the harness exit status, and `DIR/stream` with
   each redacted stdout record and its arrival time. FILE is the delivery's
   `events.jsonl`; [references/telemetry.md](../telemetry.md) ("appends each worker `tool-call` line when that call completes") owns what the run script appends to it.
   A failure of the harness side, the stdout redactor,
   or the stdout writer is a required-capture failure: the script writes
   `DIR/capture-error` and exits 70, the probe or station fails, and the record
   names the missing capture. A failure of the stream, the tool-call stage, or the
   `events.jsonl` append is a telemetry-only failure: `DIR/stdout` stays complete,
   the script writes `DIR/telemetry-error` and exits with the harness status, and
   the gap is a `telemetry-gap` under [references/telemetry.md](../telemetry.md) ("Gap rule").
   The coordinator starts the script and judges the result from those files. A
   launch on a prose recipe is still captured and redacted by the coordinator
   before anything is written, as step 2 requires.
   [references/telemetry.md](../telemetry.md) ("A Grok or Oh My Pi worker") owns tool-call durations for prose recipes.

`references/harnesses/shared.md` owns result acceptance. This is the only statement of the rule.

The coordinator has a captured result only when the captured text meets both conditions. The text contains every heading that the current station reference already names. The text contains the pack path named in the brief. The station reference already names those headings, including the headings it takes from `templates/result.md`. This rule does not add a heading list.

The captured text is the Markdown result file. When the worker cannot write that file, the captured text is the Markdown final message the coordinator persists from stdout. The same two conditions apply to that persisted message.

Worker claims do not meet the conditions. A process exit of 0 does not meet the conditions. Text that only names the unwritable path, a commit SHA, or a stall percent does not meet the conditions. That text is a stub result. A stub result is not a captured result.

When the text is a stub result, the coordinator starts same-station recovery for a missing, weak, or malformed result. `references/recovery.md` owns that recovery. The coordinator does not change the stage label. The coordinator does not publish a plan, a review census, or a pull request from that attempt.

The coordinator reads the captured text and the brief. The coordinator does not start a program to make this decision.

The coordinator accepts a same-head check record. It makes this decision for each declared check after it has a captured implementing, fix, or pre-merge repair result. The record is that check's entry under the result's `## Checks`, and it is a same-head check record only when it gives the command, the working directory, the exit status, and the head SHA; the command equals the exact invocation the brief carries for that check ([references/toolchain.md](../toolchain.md) ("The brief carries the exact invocation.")); the working directory is the issue worktree or the directory the brief names for that check; and the head SHA ([templates/result.md](../../templates/result.md) ("## Checks") defines it) equals the issue worktree's `HEAD`, which the coordinator reads with `git rev-parse HEAD` in the worktree when it accepts the result. The coordinator does not run that check again, and the record stands for that check in [references/publication.md](../publication.md) ("a rerun of affected local CI before the first push"). When the head moved, the record is missing, or any of those four fields is absent, `unknown`, or does not match, the coordinator runs the check itself with the brief's invocation in the directory the brief names for that check, or in the issue worktree when the brief names none. Which of these runs it makes, and in what order, follows [references/planning.md](../planning.md) ("Mark each declared check heavy or not heavy"). An accepted record with a nonzero exit status is a failed check under [references/recovery.md](../recovery.md) ("failed behavior/test/type/lint/build"), and the coordinator does not run the check again to confirm the failure. A silent check has no worker record; the coordinator runs it as above. [references/findings.md](../findings.md) ("does not satisfy this gate or that type-check run") owns whether a worker record satisfies the closure proof gate. The review station's own check runs and pre-merge GitHub checks are unchanged.

## Launch probe

This section owns the launch probe. A launch probe is not a help or version check. It is not the toolchain preflight; [references/toolchain.md](../toolchain.md) owns preflight, which proves a declared check's command. The launch probe proves a role's harness launch.

Run it once per invocation, before that invocation's first worker launch. For a fresh run that is at `ready`, after the worktree is reconciled. A resumed invocation runs it before its first worker launch, whatever stage it resumes at. Do not run it again before later stations in the same invocation. Probe the configured primary and secondary. Probe the fallback only when recovery first selects it, before its first launch, with the recipe kind of the role it fills.

Launch each probe with steps 1–4 above and the exact recipe the station would use: the same flags, model, effort, sandbox or permission mode, isolated home, the working directory that recipe names ([references/harnesses/codex.md](codex.md) ("The read recipe, for kinds") owns the Codex read recipe), and the complete grant, including each per-check allow entry the coordinator adds for the run's declared checks. Build a Claude write probe, a Claude read probe, or a Codex read probe with `scripts/launch.sh write`, with `--kind claude-write-probe`, `--kind claude-read`, or `--kind codex-read-probe` and the station's inputs, which is the same builder the station uses. Any other probe uses its prose recipe. The primary uses its harness's write-station recipe. The secondary uses its read-station recipe. Put the prompt in an owner-only launch file under `briefs/` and attach it through the recipe's stdin path. `references/harnesses/codex.md` owns the stdin rule. A Codex probe with no `thread.started` event is that owner's hung launch.

Read-probe prompt: `Launch probe. Run no command. Reply with exactly FOREMAN_PROBE_OK.`
Claude read-probe prompt: `Launch probe. Run exactly one command as its own Bash call and let the permission system decide: bash <<'EOS'` / `echo foreman-probe-heredoc` / `EOS`. `The permission system is expected to deny it. Whether it runs or is denied, do not retry it, run nothing else, and reply with exactly FOREMAN_PROBE_OK. The coordinator judges the outcome from the event record.` It replaces the read-probe prompt for a Claude read probe.
Codex read-probe prompt: `Launch probe. Run exactly one command: cat <<'EOS'` / `foreman-probe-heredoc` / `EOS`. `If it exits 0, reply with exactly FOREMAN_PROBE_OK. Otherwise reply with its exit code and stderr. Do not retry it and run nothing else.` It replaces the read-probe prompt for a Codex read probe.
Write-probe prompt: `Launch probe. Run exactly one command: git add --refresh -- . If it exits 0, reply with exactly FOREMAN_PROBE_OK. Otherwise reply with its exit code and stderr. Run nothing else.`
For a Claude write probe, [references/harnesses/claude.md](claude.md) ("The coordinator grants host-directed files") owns the prompt, pass signal, and redaction that a host grant adds.

`git add --refresh -- .` creates the worktree's `index.lock`, which a commit needs, and fails with `Unable to create '…/index.lock'` when the grant cannot write it. It stages nothing.

Before the write probe, the coordinator runs `git status` once so the index's stat data is current. Then, before and after the probe, it records HEAD, `git status --porcelain=v1 --untracked-files=all` run with `GIT_OPTIONAL_LOCKS=0`, the SHA-256 of the index file's bytes at `git rev-parse --git-path index`, and whether `git rev-parse --git-path index.lock` exists. Identical records with no lock mean no residue. A difference fails the probe and is recovery evidence.

A probe built with `scripts/launch.sh write` writes the probe capture of step 5 above, and the coordinator judges the pass conditions from it.

A probe passes only when all of these hold: the process exits 0; the reported model response is exactly `FOREMAN_PROBE_OK`; the harness's own event record shows the commands the worker ran, and the harness reports these permission denials: for a write probe exactly one command, `git add --refresh -- .`, with exit 0, and no permission denial; for a Claude read probe exactly one command, the heredoc of the Claude read-probe prompt, denied, and exactly one permission denial, for that command; for a Codex read probe exactly one command, the here-document of the Codex read-probe prompt, with exit 0, and no permission denial; and, for the write probe, no residue remains. The model's reply alone does not prove that a command ran. The Claude signals are the `tool_use` and `tool_result` events, then the `result` event with `is_error` false and an empty `permission_denials`; for a Claude read probe they are exactly one Bash `tool_use` with that heredoc command, its `tool_result` with `is_error` true, no other tool, and a `result` event with `is_error` false whose `permission_denials` holds exactly one entry, for that command. A command that runs and a worker that attempts no command each fail the Claude read probe. The Codex signals are `thread.started`, exactly one `command_execution` item with its exit code, for a write probe and for a read probe, `turn.completed`, and the last-message file. Probe-response evidence: #154. Claude read-probe evidence: #308. Codex read-probe evidence: #314. [references/telemetry.md](../telemetry.md) owns the ledger row.

Any other outcome is a probe failure, including a process that exits with no result event. Its raw error is the exit status, the redacted stderr, and the redacted tail of stdout. Record it. No station worker of any role launches, and the run does not advance, until a new probe of the failed role's harness passes or a fallback that recovery selects for that role passes its probe. Recovery may launch a diagnosis worker only under a harness and recipe kind whose probe passed in this invocation; the fresh secondary in "Diagnosis and fallback" uses its read-station recipe. If no probe passed, no diagnosis worker launches. [references/recovery.md](../recovery.md) routes the failure. The stage label stays.

## Diagnosis and fallback

Use a fresh secondary for independent diagnosis; include original errors, current
head/findings, and prior attempts, not just a proposed explanation. After the
specified repeated failure, try the configured fallback once if available. If it
is unavailable, record why and give a fresh primary a materially different
hypothesis. Recover without switching to broader permissions implicitly.
