# Claude Code adapter

Native counter: `num_turns` (assistant turns), not operations: a turn may batch
several tool calls, and the json result carries no tool-call count. The worker's
list is the count.

```sh
claude -p --permission-mode acceptEdits --output-format json \
  --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
  --add-dir RESULT_DIR --add-dir BRIEF_DIR < LAUNCH_FILE
```

This file owns the write-station grant. Pass `--add-dir` for the `RESULT_DIR`
subdirectory, the `BRIEF_DIR` subdirectory, and each evidence subdirectory the
pack names for reading. Do not pass the evidence root. Do not pass `$HOME`.

Use the worktree as cwd. Add `--model MODEL` and `--effort EFFORT` only when
configured. Use `--setting-sources ''` to exclude unrelated project/user settings
when required task/auth settings have been supplied explicitly. The installed CLI
advertises low/medium/high/xhigh/max; verify model support too. `acceptEdits`
approves file edits, not every shell command. For read stations use
`--permission-mode plan`, `--tools Read,Bash`, `--allowedTools` listing exactly
`Bash(git status *)`, `Bash(git rev-parse *)`, `Bash(git diff *)`, and
`--disallowedTools` spellings `Bash(grep -r*)`, `Bash(grep -R*)`,
`Bash(grep --recursive*)`, `Bash(grep --dereference-recursive*)`, `Bash(rg *)`,
and `Bash(find *)`, with `--permission-prompts none`; return results in stdout.
Deny rules beat allow rules. Probed 2026-09-22 at `1af7446`: recursive-form denies let the exact check
run and denied `grep -rn`, listed in `permission_denials`. `dontAsk` returned
nothing within five minutes in the 2026-09-22 probe; do not use it. No turn-cap
flag exists; the brief ceiling is the control. Never use bypassPermissions or
skip-permission flags without explicit unsafe_autonomy. Claude 2.1.278 is not a
verified metadata grant. `--add-dir` on both `<repo>/.git` and
`<repo>/.git/worktrees/capstan+N` under `--permission-mode acceptEdits` was denied
as a sensitive file. Issue https://github.com/comamitc/capstan/issues/102 reports
a Claude 2.1.282 commit with `acceptEdits`, allowed `git add` and `git commit`,
and empty `permission_denials`. This host did not reproduce that result. Do not
set `unsafe_autonomy`.

Observed JSON fields: `session_id`, `result`, `is_error`, `permission_denials`,
`duration_ms`, `num_turns`, `usage`, `modelUsage`, `total_cost_usd`. A successful
probe returned `{"type":"result","subtype":"success","result":"CAPSTAN_PROBE_OK"}`.
Inspect permission denials even if the process exits zero.
