## Nested host

The direct-worker `codex exec` recipe is in [codex.md](codex.md) ("kind `codex-write`").

The `codex exec` recipe above is the direct worker. It stays as written. This
subsection is the sandboxed interactive Codex coordinator that launches a
protected Grok child or a protected Codex child. This file owns that nested-host
launch.

Preserve the real `HOME`. Do not repurpose `HOME`. Put mutable runtime state in a
private owner-only `CODEX_HOME` and a private owner-only `GROK_HOME`, scoped to
the invocation or the run. Give needed auth read-only access to the original
store. Do not copy auth into a writable file. Do not edit the original auth or
the original config. Keep a private config snapshot read-only. Never grant all
of `~/.codex`, all of `~/.grok`, or the home directory writable.

The outer interactive host selects a Codex native permission profile with
invocation-scoped config: `-c default_permissions="capstan-runtime"` names the
profile and `-c permissions=<inline-profile>` defines it. The interactive
`codex --help` on 0.153.4 exposes no `--permission-profile` flag; do not claim
one. `codex sandbox -P` selects a profile only for direct sandbox commands and
does not launch the interactive host. The verified profile extends `:workspace`
and grants write only on the private runtime directory. Legacy writable roots
accept directories. An exact file path fails on Codex 0.153.4 because the host
creates a synthetic `.git` path and a synthetic `.codex` path under that file.
Do not combine a permission profile with legacy sandbox settings. Do not pass
`-s`, `--add-dir`, or `sandbox_workspace_write.writable_roots` on that profile
invocation. Omit legacy `sandbox_mode` from the private Codex config snapshot.
The direct-worker recipe still uses `-s` and `--add-dir`.

Give every nested child its own writable `TMPDIR`. Do not share the parent's
`TMPDIR`. The synthetic bwrap mount-registry lock lives under `TMPDIR`. A shared
lock fails nested Codex with registry-lock EROFS.

Keep each child's sandbox. Do not use a bypass flag or `unsafe_autonomy`. The
verified Codex child used `-s read-only`. The verified Grok child used
`--sandbox read-only` and `--permission-mode dontAsk` from
`references/harnesses/grok.md`. Do not copy one host's sandbox flag onto the
other.

For native async execution, print or capture the structured `tools.exec_command`
return. Retain `session_id`. Continue that session with `tools.write_stdin`.
Outer JavaScript cell completion is not child-exit proof. A later namespace-local
process scan is not child-exit proof. Reconcile a lost handle with the
interactive host's owned terminal inventory and stop interface (`/ps` and
`/stop`). Do not use tmux. Do not use an out-of-sandbox relay.

Verified on Codex CLI 0.153.4 and Grok 1.0.34 (probe evidence: commit 4769b12).
