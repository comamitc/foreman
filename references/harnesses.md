# Fresh headless workers

Read this only when spawning. Verify the selected installed CLI's `--version`
and `--help` before using a recipe. Recipes below were help-checked on 2026-09-22
(Claude 2.1.278, Codex 0.153.4, Grok 1.0.34, OMP 18.2.8); model-only JSON probes
succeeded for all four on 2026-09-21 and the read-station recipes below were
behavior-probed on 2026-09-22. A probe is not proof that a task's
filesystem/command permissions work: verify those for its exact workspace first.
Local CLI behavior is authoritative when a newer release changes flags.

Resolve declared checks before the launch procedure in this file.

Take commands from the plan's named checks, then the repository's documented runner.
Do not detect a language. Do not invent a second runner.
Run preflight before worker launch.
The preflight records the command, the tool path, and the provenance.
A preflight failure is visible.
A preflight failure does not spend a worker turn on discovery.
This is a ban on worker-side discovery.
The brief carries the exact invocation.
A worker that substitutes a global tool has not followed the brief.
The worker runs that invocation.
The worker does not discover a command, a runner, or a tool path.

The three-step precedence is this order.
First, use the recorded toolchain when the identity matches.
Identity is the lockfile or manifest bytes, not a language version.
A mismatch invalidates only the recorded toolchain.
Resolution then uses the declared runner on `PATH`.
Second, use the declared runner on `PATH`.
Do not skip that `PATH` step.
Third, create one task-scoped environment only if that `PATH` step fails.
The fallback tool is the repository's own declared tool.
Do not limit that tool to a lockfile.
A manifest-only repository is included.
Do not assume a package manager is global.
Do not create a task environment when the `PATH` step succeeds.
Record the choice as provenance.

A single executable with no lockfile gets that executable and no new environment.
No declared check leaves the repo unchanged.
A declared `pipenv run` when no global `pipenv` exists uses these three steps.
A non-Python runner that is absent from `PATH` uses these three steps.
Neither is a virtualenv special case.
When a task environment is created, put it at `toolchain/` under the evidence root.
Do not implement #10 deletion. Do not re-run `lyric-utils#764`.

## Shared launch procedure

1. Resolve role/configuration using the contract. Null model/effort omits those
   flags intentionally; explicit unsupported effort is a visible configuration
   failure, not silently omitted. Record actual reported model or `default/unknown`.
2. Prepare owner-only brief, pack, and result paths outside the product tree. The
   brief names the pack as the worker's required and only reading and, at read
   stations, the numeric turn ceiling; the pack is sized to the unit. An operation
   is one tool call: one read call or one shell command, however many files it
   names. Several tool calls in one assistant turn count separately. The ceiling
   is an upper bound, not an expected count: Named files entries plus Checks plus
   5 (brief, pack, head and status before and after, result delivery). One command
   that reads several named files is one operation and finishes under that bound.
   The worker's numbered list under `## Checks` is the operation count. The short
   launch prompt says: read this absolute brief, perform it, write the result to
   this absolute path. Put the launch prompt in an evidence file or stdin; do not
   expand the entire brief into argv. Read security before persistence/capture.
3. Use existing CLI controls for the narrowest unattended access the station needs.
   Inspect effective user/project settings for unsafe overrides without exposing
   secrets. Exclude unrelated plugins/skills/tools where the host supports it.
   Permission approval and filesystem sandboxing are distinct; disclose limitations.
4. Start a new process without continue/resume flags for each station. Run from the
   issue worktree and grant only necessary result/git-metadata paths. Record owned
   process/session and supervise output. On POSIX, an installed `timeout --signal=TERM --kill-after=10s 60m`
   can bound a process; verify its help or use the coordinator's process manager.
   Replace example 60m limits with the resolved worker_timeout_min, capped by
   remaining run budget. Timeout exit 124 is recovery evidence, not proof of no side effects.
5. Capture redacted raw output plus the Markdown result. Record wall time and exit.
   Record the worker's operation count (its numbered lines under `## Checks`)
   against the brief ceiling. That list is authoritative. Record each harness
   native counter under its own name from the table below as cross-check
   telemetry. No native counter is the operation count, and none is compared
   with the ceiling. A completed event can be absent when a command fails before
   execution. Result delivery is a native tool event only when the worker runs
   it as a tool call; a final message alone is not one. Inspect the result and
   repository independently. If the
   worker cannot write an external result under its protection mode, accept
   Markdown in stdout, persist it as coordinator evidence, and verify it; do not
   weaken safety just for formatting.

| Harness | Native counter | Relation to operations |
| --- | --- | --- |
| Claude Code | `num_turns` (assistant turns) | not operations: a turn may batch several tool calls, and the json result carries no tool-call count. The worker's list is the count. |
| Codex | `item.completed` with `item.type` `command_execution` | not operations: cross-check telemetry. One completed item is one shell command that reached the item log. Review attempt 1 at `1af7446` listed 17 shell attempts; the raw JSONL has 16 completed `command_execution` items. The absent event is the pre-execution failure (the shell could not create a heredoc temp file; exit 1 before the command ran). `item.started` duplicates a start. `agent_message` items are not operations. Result delivery is a completed item only when it is itself a shell command. |
| OMP | `tool_execution_end`; `turn_end` is turns | not operations: cross-check telemetry for a tool call that reached execution end. A call that fails before execution, and result delivery that is only an assistant message, may be absent. `turn_end` is not operations. The worker's list is the count. |
| Grok | `--max-turns N` (agent turns) | not operations. Backstop at `ceiling + 2`. Operations stay `unknown` unless `stopReason` shows the cap. The worker's list is the count. |

The examples use resolved `WORKTREE`, `RESULT_DIR`, `RESULT`, and `LAUNCH_FILE`
placeholders. Substitute shell-quoted absolute paths. Add only verified model and
effort flags. An environment allowlist can start with `env -i PATH="$PATH" HOME="$HOME" LANG=C.UTF-8`;
add required authentication/network variables individually. Never redefine HOME.

## Claude Code

```sh
claude -p --permission-mode acceptEdits --output-format json \
  --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
  --add-dir RESULT_DIR < LAUNCH_FILE
```

Use the worktree as cwd. Add `--model MODEL` and `--effort EFFORT` only when
configured. Use `--setting-sources ''` to exclude unrelated project/user settings
when required task/auth settings have been supplied explicitly. The installed
CLI advertises low/medium/high/xhigh/max; verify model support too.

`acceptEdits` approves file edits, not every shell command. Add `--allowedTools`
entries for inspected task-specific commands (for example `Bash(git status *)`,
`Bash(git diff *)`, the actual test command, and needed commit commands at write
stations). For read stations use `--permission-mode plan`, `--tools Read,Bash`
(no Glob, Grep, Edit, Write), `--allowedTools` listing exactly `Bash(git status *)`,
`Bash(git rev-parse *)`, `Bash(git diff *)`, and each pack check command verbatim,
`--disallowedTools 'Bash(grep -r*)' 'Bash(grep -R*)' 'Bash(grep --recursive*)'
'Bash(grep --dereference-recursive*)' 'Bash(rg *)' 'Bash(find *)'`, and
`--permission-prompts none`; return results in stdout. Deny rules beat allow
rules, so a deny that covers every grep also denies an exact grep check named
in the pack: probed 2026-09-22 at `1af7446`, that policy denied both the pack
check and `grep -rn`; the recursive-form denies above let the exact check run
and denied `grep -rn`, listed in `permission_denials`. Plan mode auto-approves
read-only shell commands, and so did `manual` with `--permission-prompts none`
even under `--setting-sources ''`, so the deny rules are the control for
searches; spellings they do not name, such as `-nr`, are excluded only by the
brief and the Named files list, as with Codex.
`dontAsk` returned nothing within five minutes in the 2026-09-22 probe; do not use it.
No turn-cap flag exists; the brief ceiling is the control. Deny external mutation commands in the
brief and CLI policies where supported. Do not use a blanket shell allow rule
merely to make a denied command disappear. Claude's tool permissions are not a
claim of OS containment. If stronger installed sandbox controls are configured,
retain them. Never use bypassPermissions or skip-permission flags without
explicit unsafe_autonomy. Claude 2.1.278 is not a verified metadata grant.
`--add-dir` on both `<repo>/.git` and `<repo>/.git/worktrees/capstan+N` under
`--permission-mode acceptEdits` was denied as a sensitive file. The next
harness is Codex. Do not set `unsafe_autonomy`.

Observed JSON fields: `session_id`, `result`, `is_error`, `permission_denials`,
`duration_ms`, `num_turns`, `usage`, `modelUsage`, `total_cost_usd`. A successful
probe returned `{"type":"result","subtype":"success","result":"CAPSTAN_PROBE_OK"}`.
Inspect permission denials even if the process exits zero.

## Codex CLI

```sh
codex exec -C WORKTREE -s workspace-write -c approval_policy='"never"' \
  --add-dir RESULT_DIR --json --output-last-message RESULT - < LAUNCH_FILE
```

For a commit, the verified metadata grant on Codex 0.153.4 is
`-s workspace-write` plus `--add-dir` on both git paths: `<repo>/.git` and
`<repo>/.git/worktrees/capstan+N`. Probed 2026-09-22T22:32Z in
`.worktrees/capstan+10`: `touch` and `rm` with no flags exited 0 on both
paths. `--add-dir` on `.git` alone is not the grant.

Help verified on `codex-cli 0.153.4`. `exec --help` has no cost flag. Add `--model MODEL` and
`-c model_reasoning_effort='"EFFORT"'` when configured. Confirm the chosen model
accepts the value. For pure inspection, prefer `-s read-only`: it executes
model-generated shell commands in a read-only sandbox, and the worker reads files
through those commands. 0.153.4 has no tool or turn flag, so the brief ceiling
and the worker's numbered operation list are the controls. Record completed
`command_execution` items as cross-check telemetry, not as the operation count.
Probed 2026-09-22: the three
named commands ran, and so did one unasked `cat` of a user instruction file; the
sandbox bounds writes, not reads. The coordinator can persist
the final Markdown response from stdout. For a commit, use only the metadata
grant above. Never grant the whole home directory. `--ignore-user-config` can
isolate unrelated defaults while retaining auth, but does not prove all discovered
skills are absent. Do not use dangerous bypass flags or `unsafe_autonomy` to
repair sandbox denials.

Observed JSONL includes `thread.started`, `item.completed`, and `turn.completed`.
The latter reports usage such as input_tokens, cached_input_tokens, output_tokens.
Live `--json` turn `01a0caf9-a2b4-7ce3-aabc-1603e76df0a5` has no dollar field in
`turn.completed.usage`. The matching session rollout has event types `token_count`
and `token_usage_record` and no dollar cost key. Cost stays `unknown`. A newer
CLI that later reports a dollar field in `turn.completed` or in that session
rollout has that field copied as `reported`. Do not pass `--output-schema`;
worker results are Markdown. A provider JSON change does not invalidate valid work.

## Grok Build

```sh
grok --cwd WORKTREE --prompt-file LAUNCH_FILE --permission-mode dontAsk \
  --sandbox workspace --output-format json --no-subagents
```

Help verified on 1.0.34. Add `--model MODEL` and `--reasoning-effort EFFORT` when
configured. `--sandbox` takes an installed profile name, not Codex's `-s` value.
The built-in write profile is `workspace`. `workspace-write` is not a Grok profile;
passing it exits before the model starts. Do not add a custom profile to make that
spelling work. Grok 1.0.34 has no `--add-dir`. `--sandbox workspace` returned
`Permission denied` on the worktree git path. That is not a verified metadata
grant. The next harness is Codex. Do not set `unsafe_autonomy`. Keep
`--sandbox workspace`. Use explicit
`--allow` rules for the inspected task commands and workspace edits; dontAsk
denies operations not preapproved. For read stations use `--sandbox read-only`
(accepted on 1.0.34), `--permission-mode dontAsk`, `--allow` rules for the exact
pack commands, `--deny 'Bash(grep -r*)' --deny 'Bash(grep -R*)'
--deny 'Bash(grep --recursive*)' --deny 'Bash(grep --dereference-recursive*)'
--deny 'Bash(rg *)' --deny 'Bash(find *)'`, and `--max-turns` at `ceiling + 2`
as a backstop for the opening and closing text turns. Probed 2026-09-22: dontAsk
alone let a `grep -rn` run in the read-only sandbox; a deny covering every grep
refused it but also refused the exact pack check allowed beside it, since deny
beats allow; the recursive-form denies above let the exact check run and
refused `grep -rn` with `deny rule on bash matching "grep -r*"`. Unnamed
spellings are excluded only by the brief and the Named files list. `--tools` takes built-in tool names that help
1.0.34 does not enumerate; record them from the linked permissions documentation
before relying on tool selection. Keep result capture in stdout if an outside path cannot
be allowed narrowly. Diagnose denied access with current help; do not switch to
always-approve or bypassPermissions without unsafe_autonomy.

Observed JSON fields: `text`, `stopReason`, `sessionId`, `usage`, `modelUsage`,
`total_cost_usd`. The probe returned text CAPSTAN_PROBE_OK and reported usage/cost.
Official [permissions](https://docs.x.ai/build/features/permissions) distinguish
approval rules from the filesystem/network sandbox; check both.

## Oh My Pi

```sh
omp --cwd WORKTREE -p --mode json --approval-mode write \
  --no-extensions --no-skills --no-rules --no-lsp --no-pty \
  --max-time 60m @LAUNCH_FILE
```

Help verified on 18.2.8. Add `--model MODEL` and `--thinking EFFORT` when configured;
help lists off/minimal/low/medium/high/xhigh/max/auto. With discovery disabled,
the pack carries the rule extract; do not paste conventions into the brief. Allow
the result directory with `--add-dir RESULT_DIR` if needed.

OMP defaults can permit every tool. Explicitly choose write mode, which permits
file writes but prompts for exec. For unattended test/git commands, use a temporary
evidence-only `--config` overlay with exact task-specific `bash.patterns` allow
rules and a narrow `--tools` list. Consult installed help and the official
[approval documentation](https://github.com/can1357/oh-my-pi/blob/main/docs/approval-mode.md)
for its actual pattern syntax. Read stations use `--tools=read,bash` (no `grep`,
`glob`, `edit`, `write`; `find` is a CLI subcommand, not a tool) plus a temporary
evidence-only `--config` overlay whose `bash.patterns` allow exactly the pack's
commands, and return Markdown in stdout. On 18.2.8 each pattern item is `match`
plus `approval` (`allow`, `prompt`, `deny`) with `*` wildcards only, nested as
`bash: patterns:` in the overlay. Probed 2026-09-22 with `--approval-mode write`
over an inherited yolo default: `git rev-parse HEAD` matched an allow rule and
ran; `grep -rn` missed and returned "requires approval but no interactive UI
available". These controls are approval policy, not
OS containment; use an existing external workspace sandbox if available. Never
use auto-approve or yolo without unsafe_autonomy, including an inherited yolo default.

Observed NDJSON includes `session`, `message_end`, `turn_end`, `tool_execution_start`,
`tool_execution_end`, and `agent_end`. Record `tool_execution_end` as cross-check
telemetry, not as the operation count. `turn_end` counts turns. Assistant
messages report model/provider and usage/cost. Count each completed
assistant message once; later aggregate events can repeat the same messages.
The probe initially produced thinking-only output before a final text response;
inspect actual result text, not merely exit zero. Unknown formats retain redacted
raw output and unknown usage without blocking delivery.

## Diagnosis and fallback

Use a fresh secondary for independent diagnosis; include original errors, current
head/findings, and prior attempts, not just a proposed explanation. After the
specified repeated failure, try the configured fallback once if available. If it
is unavailable, record why and give a fresh primary a materially different
hypothesis. Recover without switching to broader permissions implicitly.
