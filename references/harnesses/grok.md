# Grok adapter

Native counter: `--max-turns N` (agent turns), not operations. Backstop at
`ceiling + 2`. Operations stay `unknown` unless `stopReason` shows the cap. The
worker's list is the count.

```sh
grok --cwd WORKTREE --prompt-file LAUNCH_FILE --permission-mode dontAsk \
  --sandbox workspace --output-format json --no-subagents
```

Help verified on 1.0.34. Add `--model MODEL` and `--reasoning-effort EFFORT` when
configured. `--sandbox` takes an installed profile name, not Codex's `-s` value.
The built-in write profile is `workspace`. `workspace-write` is not a Grok profile.
Grok 1.0.34 has no `--add-dir`. `--sandbox workspace` returned `Permission denied`
on the worktree git path. That is not a verified metadata grant. It does not
replace the primary. A write station still launches Grok with `--sandbox workspace`
and explicit `--allow` rules for the workspace edits. `dontAsk` denies an
operation that is not preapproved. Do not use `workspace-write`. That spelling
exits before the model starts. Do not set `unsafe_autonomy`. Keep
`--sandbox workspace`. Codex may run only the commit, and only after Grok cannot
create `index.lock`. That row is a committer, not a primary. The product diff is
already Grok's. For read stations
use `--sandbox read-only`, `--permission-mode dontAsk`, exact pack commands, and
`--deny 'Bash(grep -r*)'`, `--deny 'Bash(grep -R*)'`,
`--deny 'Bash(grep --recursive*)'`, `--deny 'Bash(grep --dereference-recursive*)'`,
`--deny 'Bash(rg *)'`, and `--deny 'Bash(find *)'`. Do not switch to always-approve or bypassPermissions
without unsafe_autonomy.

`references/harnesses/grok.md` owns the read-only result rule. Other files name this owner and do not restate this procedure.

A Grok read-only launch uses `--sandbox read-only` and `--prompt-file LAUNCH_FILE`. The launch prompt tells the worker to return the station Markdown in the final message. The launch prompt does not ask for a write outside the worktree. The coordinator persists that message. The launch does not spend a turn on a write the sandbox will deny.

Grok 1.0.34 has no `--add-dir`. Do not grant the external result path. Do not switch the read station to `workspace`, `bypassPermissions`, or `unsafe_autonomy` to make that write succeed.

Observed JSON fields: `text`, `stopReason`, `sessionId`, `usage`, `modelUsage`,
`total_cost_usd`. [references/telemetry.md](../telemetry.md) owns usage reporting. The probe returned text
CAPSTAN_PROBE_OK and reported usage and cost. Official
[permissions](https://docs.x.ai/build/features/permissions) distinguish approval
rules from the filesystem/network sandbox; check both.
