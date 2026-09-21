<!-- capstan:review OWNER/REPO#N -->
<!-- Use capstan:plan-review for a plan review. -->
# Review census

Specification / plan revision:
Reviewed head / base SHAs (code review):
Risk assessment:
Coverage (criteria, plan items, diff, affected callers, prior repairs):
Unchanged tree/head verification:
Initial plan / single review artifact / correction launch/outcome (when applicable):

## Spec

Findings, or none with the evidence examined.

## Standards

Findings, or none with the rules examined.

## Correctness

Findings, or none with the paths/invariants examined.

## Simplicity

Findings, or none with the alternatives examined.

## Finding format

For each actionable finding: local ID, origin review/ID, axis, severity, location,
original failure scenario, acceptance condition, concrete evidence, and proposed
correction. Local IDs belong only to this census; origin links preserve lineage.
In code review, blocker and major are blocking; minor is non-blocking. In plan
review, separate actual prerequisites from implementation obligations; severity
alone does not stop implementation. Use
[finding resolution](../references/findings.md). Remove this instruction in output.

## Prior-finding verification

For every prior actionable finding: origin, primary's proposed change/refutation,
candidate location, independent replay/trace and result, disposition, and evidence
at this revision/head. Explain new scenarios and split/merged lineage. Use “none”
only when no prior findings exist, including planning findings in the first code
review. Claims of “addressed” are not verification.

## Verdict

Plan review: approve or one correction of the complete feedback set; list actual
prerequisites and implementation obligations separately. Code review: approve or
fix, blocking census count, and unresolved risks.
