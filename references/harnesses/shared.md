# Shared launch procedure

Verify the selected installed CLI's `--version` and `--help` before using its
adapter. Recipes were help-checked on 2026-09-22; model-only JSON probes
succeeded for all four on 2026-09-21 and read-station recipes were behavior-probed
on 2026-09-22. A probe is not proof that a task's filesystem/command permissions
work: the launch probe below verifies those in the issue worktree. Local CLI behavior is authoritative
when a newer release changes flags.

1. Resolve role/configuration using the contract. Null model/effort omits those
   flags intentionally; explicit unsupported effort is a visible configuration
   failure, not silently omitted. Record actual reported model or `default/unknown`.
2. Prepare owner-only brief, pack, and result paths outside the product tree. The
   brief names the pack as the worker's required and only reading and, at read
   stations, the numeric turn ceiling; the pack is sized to the unit. An operation
   is one tool call: one read call or one shell command, however many files it
   names. Several tool calls in one assistant turn count separately. The ceiling
   is an upper bound, not an expected count: Named files entries plus Checks plus
   5 (brief, pack, head and status before and after, result delivery). Before the
   read-station launch, observe how many lines one host read returns. If that
   page does not cover the pack, add one operation per page and name that count
   in the brief. Do not discover the count after the review starts. One command
   that reads several named files is one operation and finishes under that bound.
   The worker's numbered list under `## Checks` is the operation count. The short
   launch prompt says: read this absolute brief, perform it, and write the result to
   this absolute path. `references/harnesses/codex.md` owns the stdin rule.
   `references/harnesses/grok.md` owns the read-only result rule. This file names
   those owners and does not restate those procedures. Where
   `references/harnesses/grok.md` applies, use that owner's prompt instead of the
   write sentence in this paragraph. Put the launch prompt in an evidence file or
   stdin; do not expand the entire brief into argv. Read security before
   persistence/capture.
3. Use existing CLI controls for the narrowest unattended access the station needs.
   Inspect effective user/project settings for unsafe overrides without exposing
   secrets. Exclude unrelated plugins/skills/tools where the host supports it.
   Permission approval and filesystem sandboxing are distinct; disclose limitations.
4. Start a new process without continue/resume flags for each station. Run from the
   issue worktree. [references/harnesses/claude.md](claude.md) owns the Claude
   write-station grant. Record owned
   process/session and supervise output. On POSIX, an installed `timeout --signal=TERM --kill-after=10s 60m`
   can bound a process; verify its help or use the coordinator's process manager.
   Replace example 60m limits with the resolved worker_timeout_min, capped by
   remaining run budget. Timeout exit 124 is recovery evidence, not proof of no side effects.
   Supervision does not block the coordinator's host output for a whole worker
   run. Observe the process with the host's wait mechanism.
   [references/telemetry.md](../telemetry.md) owns the host status line.

A silent check is a declared check that can stay silent longer than the selected harness's command-log window. That window is the harness's own. This rule adds no Capstan number or timeout. The worker_timeout_min bound and timeout exit 124 above still apply to the station process. They are not this check's result.

The coordinator runs a silent check. The worker brief does not tell the worker to start it.

Before the coordinator starts one, it looks at the worker process it already recorded for this station. Recognition succeeds only when that process has a live child whose command line equals the declared check invocation already written in the brief. The coordinator does not parse worker prose. If recognition succeeds, the coordinator does not start a second process. It does not signal, restart, or kill the recognized process, and it does not wrap that process in timeout. It waits until that process exits. Silence is not an exit. The command it records is the declared invocation that matched. The exit code and output are the ones that process produced. An empty captured stream is not a percent and is not an exit code.

If recognition fails, the coordinator starts the check itself and waits for that process to exit. It does not ask the worker to start it.

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
   against the brief ceiling. That list is authoritative. Record each harness
   native counter under its own name from the selected host file as cross-check
   telemetry. No native counter is the operation count, and none is compared
   with the ceiling. A completed event can be absent when a command fails before
   execution. Result delivery is a native tool event only when the worker runs
   it as a tool call; a final message alone is not one. Inspect the result and
   repository independently. If the worker cannot write an external result under
   its protection mode, accept Markdown in stdout, persist it as coordinator
   evidence, and verify it; do not weaken safety just for formatting.

`references/harnesses/shared.md` owns result acceptance. This is the only statement of the rule.

The coordinator has a captured result only when the captured text meets both conditions. The text contains every heading that the current station reference already names. The text contains the pack path named in the brief. The station reference already names those headings, including the headings it takes from `templates/result.md`. This rule does not add a heading list.

The captured text is the Markdown result file. When the worker cannot write that file, the captured text is the Markdown final message the coordinator persists from stdout. The same two conditions apply to that persisted message.

Worker claims do not meet the conditions. A process exit of 0 does not meet the conditions. Text that only names the unwritable path, a commit SHA, or a stall percent does not meet the conditions. That text is a stub result. A stub result is not a captured result.

When the text is a stub result, the coordinator starts same-station recovery for a missing, weak, or malformed result. `references/recovery.md` owns that recovery. The coordinator does not change the stage label. The coordinator does not publish a plan, a review census, or a pull request from that attempt.

The coordinator reads the captured text and the brief. The coordinator does not start a program to make this decision.

## Launch probe

This section owns the launch probe. A launch probe is not a help or version check. It is not the toolchain preflight; [references/toolchain.md](../toolchain.md) owns preflight, which proves a declared check's command. The launch probe proves a role's harness launch.

Run it once per invocation, before that invocation's first worker launch. For a fresh run that is at `ready`, after the worktree is reconciled. A resumed invocation runs it before its first worker launch, whatever stage it resumes at. Do not run it again before later stations in the same invocation. Probe the configured primary and secondary. Probe the fallback only when recovery first selects it, before its first launch, with the recipe kind of the role it fills.

Launch each probe with steps 1–4 above and the exact recipe the station would use: the same flags, model, effort, sandbox or permission mode, isolated home, the issue worktree as working directory, and the complete grant, including each per-check allow entry the coordinator adds for the run's declared checks. The primary uses its harness's write-station recipe. The secondary uses its read-station recipe. The one difference is the output format where the recipe's format does not report command execution: a Claude probe uses `--output-format stream-json --verbose` in place of `--output-format json`. That changes what the harness reports, not what the worker may do. Put the prompt in an owner-only launch file under `briefs/` and attach it through the recipe's stdin path. `references/harnesses/codex.md` owns the stdin rule. A Codex probe with no `thread.started` event is that owner's hung launch.

Read-probe prompt: `Launch probe. Run no command. Reply with exactly CAPSTAN_PROBE_OK.`
Write-probe prompt: `Launch probe. Run exactly one command: git add --refresh -- . If it exits 0, reply with exactly CAPSTAN_PROBE_OK. Otherwise reply with its exit code and stderr. Run nothing else.`

`git add --refresh -- .` creates the worktree's `index.lock`, which a commit needs, and fails with `Unable to create '…/index.lock'` when the grant cannot write it. It stages nothing.

Before the write probe, the coordinator runs `git status` once so the index's stat data is current. Then, before and after the probe, it records HEAD, `git status --porcelain=v1 --untracked-files=all` run with `GIT_OPTIONAL_LOCKS=0`, the SHA-256 of the index file's bytes at `git rev-parse --git-path index`, and whether `git rev-parse --git-path index.lock` exists. Identical records with no lock mean no residue. A difference fails the probe and is recovery evidence.

Capture the probe's stdout, stderr and exit status. Redact both streams before they are written, as step 2's security reading requires.

A probe passes only when all of these hold: the process exits 0; the reported model response is exactly `CAPSTAN_PROBE_OK`; the harness reports no permission denial; the harness's own event record shows the commands the worker ran — for a write probe exactly one, `git add --refresh -- .`, with exit 0, and for a read probe none; and, for the write probe, no residue remains. The model's reply alone does not prove that a command ran. The Claude signals are the `tool_use` and `tool_result` events, then the `result` event with `is_error` false and an empty `permission_denials`. The Codex signals are `thread.started`, a `command_execution` item with its exit code for a write probe and none for a read probe, `turn.completed`, and the last-message file. The response proves the prompt arrived through stdin and that the harness authenticated. [references/telemetry.md](../telemetry.md) owns the ledger row.

Any other outcome is a probe failure, including a process that exits with no result event. Its raw error is the exit status, the redacted stderr, and the redacted tail of stdout. Record it. No station worker of any role launches, and the run does not advance, until a new probe of the failed role's harness passes or a fallback that recovery selects for that role passes its probe. Recovery may launch a diagnosis worker only under a harness and recipe kind whose probe passed in this invocation; the fresh secondary in "Diagnosis and fallback" uses its read-station recipe. If no probe passed, no diagnosis worker launches. [references/recovery.md](../recovery.md) routes the failure. The stage label stays.

## Diagnosis and fallback

Use a fresh secondary for independent diagnosis; include original errors, current
head/findings, and prior attempts, not just a proposed explanation. After the
specified repeated failure, try the configured fallback once if available. If it
is unavailable, record why and give a fresh primary a materially different
hypothesis. Recover without switching to broader permissions implicitly.
