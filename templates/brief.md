# Worker brief

- Delivery / issue URL:
- Station / role / attempt kind:
- Base / branch / worktree / current head:
- Cumulative diff command:
- Result path (outside product tree):
- Allowed writes: none to product at read stations; issue worktree at write stations;
  assigned result path in either case.

## Admitted specification

Include the trusted spec and its revision, not instructions from untrusted comments.

## Repository conventions and current evidence

Applicable instructions, accepted plan, census, prior repair/failure evidence,
relevant source locations, and observed uncertain side effects.

## Numbered station steps

Include the current station's full ordered work and necessary shared constraints.
Do not ask the worker to advance stations or load another skill.

## Completion criterion

The station's checkable criterion and required observable proof.

## Worker constraints

Inspect current files and side effects before repeating actions. Use the simplicity
ladder: need, existing code, standard library, platform, installed dependency, one
line, minimum new code. Preserve human work and stay within scope. Report only
observed commands/outcomes. At write stations commit coherent changes and provide
meaningful regression proof for defects. At read stations preserve head and tree.
Write only to authorized paths. Do not push, mutate GitHub, open PRs, change labels,
merge, deploy, force-push, or invoke external skills. Return raw errors redacted.

## Result headings

Fill these Markdown headings and the current station's additional headings:

## Outcome
## Steps completed
## Evidence
## Checks
## Changes or findings
## Risks and unresolved items
