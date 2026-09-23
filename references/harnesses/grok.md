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
on the worktree git path. That is not a verified metadata grant. The next harness
is Codex. Do not set `unsafe_autonomy`. Keep `--sandbox workspace`. For read stations
use `--sandbox read-only`, `--permission-mode dontAsk`, exact pack commands, and
`--deny 'Bash(grep -r*)'`, `--deny 'Bash(grep -R*)'`,
`--deny 'Bash(grep --recursive*)'`, `--deny 'Bash(grep --dereference-recursive*)'`,
`--deny 'Bash(rg *)'`, and `--deny 'Bash(find *)'`. Do not switch to always-approve or bypassPermissions
without unsafe_autonomy.

Observed JSON fields: `text`, `stopReason`, `sessionId`, `usage`, `modelUsage`,
`total_cost_usd`. Record Grok `total_cost_usd` when present. The probe returned text
CAPSTAN_PROBE_OK and reported usage/cost. Official
[permissions](https://docs.x.ai/build/features/permissions) distinguish approval
rules from the filesystem/network sandbox; check both.
