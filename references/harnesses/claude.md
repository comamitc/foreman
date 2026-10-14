# Claude Code adapter

Native counter: `num_turns` (assistant turns), not operations: a turn may batch
several tool calls. Tool-call count evidence: #12. The worker's
list is the count.

```sh
claude -p --permission-mode acceptEdits --output-format json \
  --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
  --add-dir RESULT_DIR --add-dir BRIEF_DIR \
  --permission-prompts none \
  --allowedTools 'Bash(git add *)' 'Bash(git commit *)' 'Bash(git status *)' 'Bash(git diff *)' 'Bash(git log *)' 'Bash(git rev-parse *)' 'Bash(git show *)' 'Bash(git restore -- *)' \
  --disallowedTools 'Bash(git checkout *)' 'Bash(git reset --hard *)' 'Bash(git push *)' 'Bash(gh *)' \
  < LAUNCH_FILE
```

The coordinator writes this launch, the read-station form below, and the write probe with the launch builder `scripts/launch.sh write` (kinds `claude-write`, `claude-read`, `claude-write-probe`), and checks a run script with `scripts/launch.sh check`. These recipes stay the specification: where the builder differs, the builder is wrong.

This file owns the write-station grant. Pass `--add-dir` for the `RESULT_DIR`
subdirectory, the `BRIEF_DIR` subdirectory, and each evidence subdirectory the
pack names for reading. Do not pass the evidence root. Do not pass `$HOME`.

The coordinator grants host-directed files read-only. Before the launch probe it reads `~/.claude/CLAUDE.md`, the source, and takes each inline code span whose whole content is a path that starts with `~/` or `/`, one level deep: it does not follow paths named inside the files it grants, and it ignores fenced code blocks. For each named path, E is the path with a leading `~` replaced by `$HOME`, and R is the output of `realpath E`, which resolves every symlink. The first reason that applies skips the path: `missing` when `test -e E` fails; `directory` when R is a directory; `not a regular file` when R is not a regular file; `unreadable` when R is not readable; `inside the worktree` when R is at or under the `realpath` of the worktree; `unsafe path` when E or R holds a character other than a letter, a digit, `/`, `.`, `_`, `-`, `+` or `@`, or an empty, `.` or `..` segment. Otherwise E gets one `--allowedTools` entry of the form `Read(//ABSOLUTE/PATH)`, a single file: `/home/u/notes.md` becomes `Read(//home/u/notes.md)`. When R differs from E, R gets a second entry for the same file. A path named twice is taken once. Nothing else is granted for host files: no `--add-dir` for `$HOME`, the evidence root, or the directory of a host file, and no write access. Read stations and other harnesses take no such entry. Host-grant probe evidence: `references/harnesses/claude.md` at `cd38fa1`.

The coordinator records one ledger notes line before the launch probe. With a grant it is `Host grant: E, E2 -> R2; skipped P (REASON), …`, where `E2 -> R2` is a path granted with its resolved target, P is a skipped path as the source names it, and the skipped part is left out when nothing is skipped. With no grant it is `Host grant: no host-directed files; skipped P (REASON), …` when every named path is skipped, `Host grant: no host-directed files; source names no path` when the source names none, and `Host grant: no host-directed files; source missing`, `source not a regular file`, or `source unreadable` when `test -e`, `test -f`, or `test -r` on the source fails, checked in that order. A skipped path or source does not block delivery. `scripts/launch.sh grant` applies this rule and prints this line.

With no grant, the write probe uses the write-probe prompt in [references/harnesses/shared.md](shared.md) unchanged. With a grant, this prompt replaces it, with PATHS the granted E values joined by `, `: `Launch probe. Run exactly one command: git add --refresh -- . Then use the Read tool once on each of these files: PATHS. Use no other tool and run nothing else. If the command exits 0 and every Read succeeds, reply with exactly CAPSTAN_PROBE_OK. Otherwise reply with the exit code and stderr of the command and the path of each Read that failed.` That probe passes only when the shared pass conditions hold with `git add --refresh -- .` as the one command, and also: the `input.file_path` values of the Read `tool_use` events are exactly PATHS, each once; the `id` of each Read has one `tool_result` with that `tool_use_id` whose `is_error` is not true; no other tool is used; and `permission_denials` is empty. The ledger notes line above is the probe's record of its grant, including `no host-directed files`.

Before any output of a run under a host grant is written, the streaming redaction step of [references/security.md](../security.md) rule 6 also removes host-file text. It replaces with `[host file content removed]` the `content` of each `tool_result` that answers a Read and whose `is_error` is not true, and the `tool_use_result` of that event. It replaces with `[removed]` each assistant `text` or `thinking` block and the `result` field unless it is exactly `CAPSTAN_PROBE_OK`, and each field that carries a tool's arguments, whether it is named `input`, `tool_input`, or `wire_tool_inputs` or otherwise, other than a Bash `command` and a `file_path`. It keeps each tool name, `id`, `tool_use_id`, `is_error`, `file_path`, and `permission_denials` entry.

Bite restore is `git restore -- <path>`. `git checkout` is not the restore path. The coordinator adds one `--allowedTools` entry for each declared check, verbatim. Bite-restore probe evidence: PR #111.

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
Deny rules beat allow rules.
Read-station deny probe evidence: commits 5542194 and 1af7446. `dontAsk` returned
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
`duration_ms`, `num_turns`, `usage`, `modelUsage`, `total_cost_usd`.
Probe JSON example: `references/harnesses/claude.md` at `cd38fa1`.
Inspect permission denials even if the process exits zero.
[references/telemetry.md](../telemetry.md) owns usage reporting.

## Claude Code host

The `claude -p` recipe above is the worker. It stays as written. This
subsection is the interactive Claude Code coordinator that launches it. Start
the worker as a background task, not as one foreground call that holds the
session until the worker exits. Observe it with the host's wait mechanism, such
as the background task's exit notice. At each observation, read the worktree
head, new commits, and whether the result file exists.
[references/telemetry.md](../telemetry.md) owns the host status line.
