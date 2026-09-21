# Fresh headless workers

Read this only when spawning. Verify the selected installed CLI's `--version`
and `--help` before using a recipe. Recipes below were help-checked on 2026-09-21;
model-only JSON probes succeeded for all four. A probe is not proof that a task's
filesystem/command permissions work: verify those for its exact workspace first.
Local CLI behavior is authoritative when a newer release changes flags.

## Shared launch procedure

1. Resolve role/configuration using the contract. Null model/effort omits those
   flags intentionally; explicit unsupported effort is a visible configuration
   failure, not silently omitted. Record actual reported model or `default/unknown`.
2. Prepare owner-only brief and result paths outside the product tree. The short
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
   Inspect the result and repository independently. If the worker cannot write an
   external result under its protection mode, accept Markdown in stdout, persist it
   as coordinator evidence, and verify it; do not weaken safety just for formatting.

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
stations). For read stations restrict tools to Read/Glob/Grep plus specifically
allowed inspection/check commands and use stdout for results. Deny external
mutation commands in the brief and CLI policies where supported. Do not use a
blanket shell allow rule merely to make a denied command disappear. Claude's tool
permissions are not a claim of OS containment. If stronger installed sandbox
controls are configured, retain them. Never use bypassPermissions or skip-permission
flags without explicit unsafe_autonomy.

Observed JSON fields: `session_id`, `result`, `is_error`, `permission_denials`,
`duration_ms`, `usage`, `modelUsage`, `total_cost_usd`. A successful probe returned
`{"type":"result","subtype":"success","result":"CAPSTAN_PROBE_OK"}`.
Inspect permission denials even if the process exits zero.

## Codex CLI

```sh
codex exec -C WORKTREE -s workspace-write -c approval_policy='"never"' \
  --add-dir RESULT_DIR --json --output-last-message RESULT - < LAUNCH_FILE
```

Help verified on 0.153.4. Add `--model MODEL` and
`-c model_reasoning_effort='"EFFORT"'` when configured. Confirm the chosen model
accepts the value. For pure inspection, prefer `-s read-only`; the coordinator can
persist the final Markdown response. For writes, verify linked-worktree git
metadata is writable under the sandbox. Grant that precise metadata path only
when needed; never grant the whole home directory. `--ignore-user-config` can
isolate unrelated defaults while retaining auth, but does not prove all discovered
skills are absent. Do not use dangerous bypass flags to repair sandbox denials.

Observed JSONL includes `thread.started`, `item.completed`, and `turn.completed`.
The latter reports usage such as input_tokens, cached_input_tokens, output_tokens.
Cost was not reported in the probe: record `unknown`. Do not pass `--output-schema`;
worker results are Markdown. A provider JSON change does not invalidate valid work.

## Grok Build

```sh
grok --cwd WORKTREE --prompt-file LAUNCH_FILE --permission-mode dontAsk \
  --sandbox workspace-write --output-format json --no-subagents
```

Help verified on 1.0.34. Add `--model MODEL` and `--reasoning-effort EFFORT` when
configured. Verify installed sandbox profile support before use. Use explicit
`--allow` rules for the inspected task commands and workspace edits; dontAsk
denies operations not preapproved. For read stations select the installed
read-only profile and a read-only tool set. Keep result capture in stdout if an
outside path cannot be allowed narrowly. Diagnose denied access with current help;
do not switch to always-approve or bypassPermissions without unsafe_autonomy.

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

Help verified on 18.2.6. Add `--model MODEL` and `--thinking EFFORT` when configured;
help lists off/minimal/low/medium/high/xhigh/max/auto. Include repository conventions
explicitly in the brief when discovery is disabled. Allow the result directory
with `--add-dir RESULT_DIR` if needed.

OMP defaults can permit every tool. Explicitly choose write mode, which permits
file writes but prompts for exec. For unattended test/git commands, use a temporary
evidence-only `--config` overlay with exact task-specific `bash.patterns` allow
rules and a narrow `--tools` list. Consult installed help and the official
[approval documentation](https://github.com/can1357/oh-my-pi/blob/main/docs/approval-mode.md)
for its actual pattern syntax. Read stations can use `--tools read,grep,find` and
return Markdown in stdout. These controls are approval policy, not OS containment;
use an existing external workspace sandbox if available. Never use auto-approve
or yolo without unsafe_autonomy, including an inherited yolo default.

Observed NDJSON includes `session`, `message_end`, `turn_end`, and `agent_end`.
Assistant messages report model/provider and usage/cost. Count each completed
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
