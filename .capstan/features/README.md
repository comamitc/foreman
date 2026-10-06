# Capstan feature map

User-facing Capstan features, one file each. [contract](../../references/contract.md) ("Each feature file uses only these four H2 headings") owns the heading shape and map resolution.

- [Issue delivery](issue-delivery.md): invoke Capstan with an issue URL or number; it ends at an open merge-ready PR unless it stops for review exhaustion, a human action, or cancellation.
- [Text invocation](text-invocation.md): invoke Capstan with prose; it creates one issue, then delivers it.
- [Batch invocation](batch-invocation.md): invoke Capstan with two or more issues; it delivers them one at a time in dependency order.
- [Status](status.md): invoke Capstan with exactly `status`; it prints a read-only report.
- [Architect](architect.md): invoke Capstan with `architect`, optionally followed by paths; it prints a read-only graded report.
- [Guardrails](guardrails.md): invoke Capstan with `guardrails`, optionally followed by paths; it prints a read-only report of guardrails and graded tests.
- [Learn](learn.md): invoke Capstan with `learn`, optionally followed by `repo OWNER/REPO` and `since YYYY-MM-DD` pairs; it prints a read-only report of ranked Capstan-process proposals from every run on this machine.
- [Help](help.md): invoke Capstan with `help`, optionally followed by a question; it prints a read-only answer that cites the owning file and the invocation to send next, or a menu of topics.
- [Init](init.md): invoke Capstan with exactly `init`; it writes an absent `.capstan.json`, left uncommitted, and ensures the Capstan labels.
- [Improvement invocation](improvement-invocation.md): an issue or text that states the improvement outcome.
- [Feature-map adoption](feature-map-adoption.md): an issue or text that states the feature-map adoption outcome.
- [Feature-map audit](feature-map-audit.md): an issue or text that states an audit of the configured feature map.
- [Documentation backfill](documentation-backfill.md): an issue or text that states documentation backfill and names the audience and the workflow.
- [Verification-path adoption](verification-path-adoption.md): an issue or text that states verification-path adoption and names the target repository and one user operation.
- [Lesson maintenance](lesson-maintenance.md): an issue or text that states lesson maintenance.
- [Correction](correction.md): an issue or text that states the correction outcome.
