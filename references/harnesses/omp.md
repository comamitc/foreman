# Oh My Pi adapter

Native counter: `tool_execution_end`; `turn_end` is turns, not operations:
cross-check telemetry for a tool call that reached execution end. A call that
fails before execution, and result delivery that is only an assistant message,
may be absent.

```sh
omp --cwd WORKTREE -p --mode json --approval-mode write \
  --no-extensions --no-skills --no-rules --no-lsp --no-pty \
  --max-time 60m @LAUNCH_FILE
```

Help verified on 18.2.8. Add `--model MODEL` and `--thinking EFFORT` when configured;
help lists off/minimal/low/medium/high/xhigh/max/auto. With discovery disabled,
the pack carries the rule extract; do not paste conventions into the brief. Allow
the result directory with `--add-dir RESULT_DIR` if needed. Explicitly choose write
mode, which permits file writes but prompts for exec. For unattended test/git commands,
use a temporary evidence-only `--config` overlay with exact task-specific
`bash: patterns:` rules, where each overlay item is `match` plus `approval`
(`allow`, `prompt`, `deny`) with `*` wildcards only, and a narrow `--tools` list. Read stations use
`--tools=read,bash` and an evidence-only overlay. Never use auto-approve or yolo
without unsafe_autonomy, including an inherited yolo default.

Observed NDJSON includes `session`, `message_end`, `turn_end`, `tool_execution_start`,
`tool_execution_end`, and `agent_end`. Assistant messages
report model/provider and token usage. [references/telemetry.md](../telemetry.md) owns usage reporting. Count each completed assistant message once;
later aggregate events can repeat the same messages. The probe initially produced
thinking-only output before a final text response; inspect actual result text, not
merely exit zero. Unknown formats retain redacted raw output and unknown usage
without blocking delivery.
