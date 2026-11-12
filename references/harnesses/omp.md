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

Help verified on 18.4.2. Add `--model MODEL` and `--thinking EFFORT` when configured;
help lists off/minimal/low/medium/high/xhigh/max/auto. With discovery disabled,
the pack carries the rule extract; do not paste conventions into the brief. Allow
the result directory with `--add-dir RESULT_DIR` if needed. Explicitly choose write
mode, which permits file writes but prompts for exec. For unattended test/git commands,
use a temporary evidence-only `--config` overlay with exact task-specific
`bash: patterns:` rules, where each overlay item is `match` plus `approval`
(`allow`, `prompt`, `deny`) with `*` wildcards only, and a narrow `--tools` list. Read stations use
`--tools=read,bash` and an evidence-only overlay. For a seat of a non-empty `review_policy.voters`, that overlay also sets `retry.modelFallback: false`, because omp's model fallback (`retry.fallbackChains` in the operator's omp configuration) otherwise answers with another model. A seat launch whose events include `retry_fallback_applied`, or, for a seat with a set `model`, whose last assistant message reports a model or provider other than that model, is a failed seat under [recovery](../recovery.md) ("failed seat:"), never a vote or a passed probe. For a seat whose `model` is `null`, the model and provider that message reports are that seat's resolved model.
That comparison is lexical only: it folds case, trims surrounding whitespace, and joins a separately reported provider and model as `provider/model`, and a reported model that still differs is other than that model.
Through a router such as Jev, omp reports the requested alias: comamitc/jev-router@0886e0fbbf351e00c4d48c31a7c4348043bbc203 `integrations/omp/README.md` ("omp shows the route's answer under the model you picked"); [telemetry](../telemetry.md) ("Neither the requested model nor the reported model is a routed backend by itself") owns what that report establishes.
Never use auto-approve or yolo
without unsafe_autonomy, including an inherited yolo default.

Observed NDJSON includes `session`, `message_end`, `turn_end`, `tool_execution_start`,
`tool_execution_end`, and `agent_end`. Assistant messages
report model/provider and token usage. [references/telemetry.md](../telemetry.md) owns usage reporting. Count each completed assistant message once;
later aggregate events can repeat the same messages. The probe initially produced
thinking-only output before a final text response; inspect actual result text, not
merely exit zero. Unknown formats retain redacted raw output and unknown usage
without blocking delivery.

No user-question tool is verified on this host; [triage](../triage.md) ("Question delivery:") owns delivery from a session with none.
