# Capstan feature map

User-facing Capstan features, one file each. [contract](../../references/contract.md) ("Each feature file uses only these four H2 headings") owns the heading shape and map resolution.

- [Issue delivery](issue-delivery.md): invoke Capstan with an issue URL or number; it ends at an open merge-ready PR unless it stops for review exhaustion, a human action, or cancellation.
- [Text invocation](text-invocation.md): invoke Capstan with prose; it creates one issue, then delivers it.
- [Batch invocation](batch-invocation.md): invoke Capstan with two or more issues; it delivers them one at a time in dependency order.
- [Status](status.md): invoke Capstan with exactly `status`; it prints a read-only report.
- [Improvement invocation](improvement-invocation.md): an issue or text that states the improvement outcome.
- [Feature-map adoption](feature-map-adoption.md): an issue or text that states the feature-map adoption outcome.
- [Feature-map audit](feature-map-audit.md): an issue or text that states an audit of the configured feature map.
- [Documentation backfill](documentation-backfill.md): an issue or text that states documentation backfill and names the audience and the workflow.
- [Verification-path adoption](verification-path-adoption.md): an issue or text that states verification-path adoption and names the target repository and one user operation.
- [Lesson maintenance](lesson-maintenance.md): an issue or text that states lesson maintenance.
