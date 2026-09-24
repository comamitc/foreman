# Codex adapter

Native counter: `item.completed` with `item.type` `command_execution`, not
operations: cross-check telemetry. One completed item is one shell command that
reached the item log. Review attempt 1 at `1af7446` listed 17 shell attempts;
the raw JSONL has 16 completed `command_execution` items. The absent event is the
pre-execution failure (the shell could not create a heredoc temp file; exit 1
before the command ran).

`references/harnesses/shared.md` owns the silent-check rule. This command-log fact is not that rule.

`item.started` duplicates a start. `agent_message` items
are not operations. Result delivery is a completed item only when it is itself a
shell command.

```sh
codex exec -C WORKTREE -s workspace-write -c approval_policy='"never"' \
  --add-dir RESULT_DIR --json --output-last-message RESULT - < LAUNCH_FILE
```

`references/harnesses/codex.md` owns the stdin rule. Other files name this owner and do not restate this procedure.

When the supervisor cannot pass stdin, the Codex launch uses a shell redirect of the launch file. The recipe above is that redirect: `- < LAUNCH_FILE`.

A launch that uses `-` and produces no output and no `thread.started` event because stdin was not attached is a hung worker, not a silent check. Kill it and relaunch with the shell redirect. Do not wait out the worker timeout.

For a commit, the verified metadata grant on Codex 0.153.4 is
`-s workspace-write` plus `--add-dir` on both git paths: `<repo>/.git` and
`<repo>/.git/worktrees/capstan+N`. Probed 2026-09-22T22:32Z in
`.worktrees/capstan+10`: `touch` and `rm` with no flags exited 0 on both paths.
`--add-dir` on `.git` alone is not the grant. Help verified on `codex-cli 0.153.4`.
`exec --help` has no cost flag. Add `--model MODEL` and
`-c model_reasoning_effort='"EFFORT"'` when configured. For pure inspection,
prefer `-s read-only`. 0.153.4 has no tool or turn flag, so the brief ceiling and
worker's numbered operation list are the controls. Never grant the whole home
directory. Do not use dangerous bypass flags or `unsafe_autonomy` to repair sandbox denials.

Observed JSONL includes `thread.started`, `item.completed`, and `turn.completed`.
Record Codex `turn.completed` usage as its token fields. The latter reports usage
such as input_tokens, cached_input_tokens, output_tokens. Live `--json` turn
`01a0caf9-a2b4-7ce3-aabc-1603e76df0a5` has no dollar field in
`turn.completed.usage`. The matching session rollout has event types `token_count`
and `token_usage_record` and no dollar cost key. Cost stays `unknown`. A newer CLI
that later reports a dollar field in `turn.completed` or in that session rollout
has that field copied as `reported`. Do not pass `--output-schema`; worker results
are Markdown. A provider JSON change does not invalidate valid work.
