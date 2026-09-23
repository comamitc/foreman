# Shared launch procedure

Verify the selected installed CLI's `--version` and `--help` before using its
adapter. Recipes were help-checked on 2026-09-22; model-only JSON probes
succeeded for all four on 2026-09-21 and read-station recipes were behavior-probed
on 2026-09-22. A probe is not proof that a task's filesystem/command permissions
work: verify those for its exact workspace first. Local CLI behavior is authoritative
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
   native counter under its own name from the selected host file as cross-check
   telemetry. No native counter is the operation count, and none is compared
   with the ceiling. A completed event can be absent when a command fails before
   execution. Result delivery is a native tool event only when the worker runs
   it as a tool call; a final message alone is not one. Inspect the result and
   repository independently. If the worker cannot write an external result under
   its protection mode, accept Markdown in stdout, persist it as coordinator
   evidence, and verify it; do not weaken safety just for formatting.

## Diagnosis and fallback

Use a fresh secondary for independent diagnosis; include original errors, current
head/findings, and prior attempts, not just a proposed explanation. After the
specified repeated failure, try the configured fallback once if available. If it
is unavailable, record why and give a fresh primary a materially different
hypothesis. Recover without switching to broader permissions implicitly.
