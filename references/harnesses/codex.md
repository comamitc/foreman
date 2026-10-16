# Codex adapter

Native counter: `item.completed` with `item.type` `command_execution`, not
operations: cross-check telemetry. One completed item is one shell command that
reached the item log.
Counter-gap example: `references/harnesses/codex.md` at `cd38fa1`.

`references/harnesses/shared.md` owns the silent-check rule. This command-log fact is not that rule.

`item.started` duplicates a start. `agent_message` items
are not operations.

```sh
codex exec -C WORKTREE -s workspace-write -c approval_policy='"never"' \
  --add-dir RESULT_DIR --json --output-last-message RESULT - < LAUNCH_FILE
```

The coordinator writes this launch with `scripts/launch.sh write` (kind `codex-write`). This recipe stays the specification. The nested host below stays prose. [references/harnesses/shared.md](shared.md) ("A run script that `scripts/launch.sh write` writes takes `--capture DIR`") owns this launch's capture.

The read recipe, for kinds `codex-read` and `codex-read-probe`, starts in `RESULT_DIR/work`, a private directory beneath the result directory:

```sh
env TMPDIR=RESULT_DIR/work/tmp codex exec -C RESULT_DIR/work -s workspace-write --skip-git-repo-check \
  -c 'sandbox_workspace_write.exclude_slash_tmp=true' -c approval_policy='"never"' \
  --json --output-last-message RESULT - < LAUNCH_FILE
```

`RESULT_DIR` is the directory of `RESULT`. `RESULT_DIR/work` is the only writable root: `/tmp` is excluded, and neither the worktree nor `RESULT_DIR` is a root, so a write to the product worktree or to `RESULT` fails. By canonical path, `RESULT_DIR` is not the worktree, not inside it, does not contain it, and is not `$HOME` or an ancestor of it. It is owned by the user and not writable by group or others, so `/tmp` itself is refused while a private directory beneath it is accepted. `RESULT` is not a symlink and does not resolve into `RESULT_DIR/work`; `write` and `check` refuse either. `scripts/launch.sh write` creates `RESULT_DIR/work` and `TMPDIR`, which is `RESULT_DIR/work/tmp`, owner-only (`drwx------`). The read recipe takes no `--add-dir`: under `workspace-write` an added directory is writable, so `write` refuses it. `--skip-git-repo-check` is required because `RESULT_DIR/work` is not a trusted git directory; without it the launch refuses ("Not inside a trusted directory"). The reviewer starts in `RESULT_DIR/work` and changes into the worktree to run the pack's checks. Codex does not load the worktree's `AGENTS.md` from there; the pack stays the task reading. The coordinator writes this launch with `scripts/launch.sh write` and checks it with `scripts/launch.sh check RUN_SCRIPT --worktree WORKTREE`; `check` needs the worktree because this run script does not name it. Both kinds produce the same argv and the same capture. This recipe stays the specification.

`-s read-only` plus `--add-dir` cannot give a writable `TMPDIR` (codex-cli 0.159.0, 2026-10-07; evidence: PR #241, `references/harnesses/codex.md` at `cd38fa1`).

`references/harnesses/codex.md` owns the Codex read-station result rule. Other files name this owner and do not restate this procedure.

A Codex read-station launch prompt tells the worker to return the station Markdown in its final message and to write no result file. `--output-last-message RESULT` is the only writer of `RESULT`; the read recipe keeps `RESULT` outside the worker's only writable root, so a worker write to it fails. The coordinator persists and verifies that file under the result acceptance that [references/harnesses/shared.md](shared.md) owns ("This is the only statement of the rule.").

Read-station result evidence: PR #254 ("Premise probe").

`references/harnesses/codex.md` owns the stdin rule. Other files name this owner and do not restate this procedure.

When the supervisor cannot pass stdin, the Codex launch uses a shell redirect of the launch file. Both recipes above use that redirect: `- < LAUNCH_FILE`.

A launch that uses `-` and produces no output and no `thread.started` event because stdin was not attached is a hung worker, not a silent check. Kill it and relaunch with the shell redirect. Do not wait out the worker timeout.

For a commit, the verified metadata grant on Codex 0.153.4 is
`-s workspace-write` plus `--add-dir` on both git paths: `<repo>/.git` and
`<repo>/.git/worktrees/capstan+N`. Metadata-grant probe evidence: #22.
`--add-dir` on `.git` alone is not the grant.
Help-check evidence: `references/harnesses/codex.md` at `cd38fa1`. Add `--model MODEL` and
`-c model_reasoning_effort='"EFFORT"'` when configured. For pure inspection,
use the read recipe. 0.153.4 has no tool or turn flag, so the brief ceiling and
worker's numbered operation list are the controls. Never grant the whole home
directory. Do not use dangerous bypass flags or `unsafe_autonomy` to repair sandbox denials.

A bwrap loopback or uid-map error with no `command_execution` item is a host-sandbox failure, not a worker defect. Probe once. Then name the same-harness rule in `references/contract.md`: if only one harness works, disclose `independence: same-harness`. Do not use bypass flags.

`turn.completed.usage` reports token fields such as `input_tokens`, `cached_input_tokens`, and `output_tokens`. [references/telemetry.md](../telemetry.md) owns usage reporting.
Do not pass `--output-schema`; worker results
are Markdown. A provider JSON change does not invalidate valid work.

[codex-nested-host.md](codex-nested-host.md) ("## Nested host") owns the nested-host launch.
