# Visual proof

## Sub-features
- The decision whether a change needs visual proof; [implementing](../../references/implementing.md) ("Visual proof: the coordinator decides whether a change needs visual proof") owns it.
- Capture through the target's own capture path and commit under `.foreman/proof/N/`; [implementing](../../references/implementing.md) ("Visual proof:") owns it.
- The visual-proof part of the pull-request Verification section; [implementing](../../references/implementing.md) ("Verification gets a visual-proof part.") owns it.

## How to get to it (user POV)
Deliver an issue as [Issue delivery](issue-delivery.md) describes, with a change that a person reaches through a screen, a command's output, or a running app.

## Driving it
Invocation: invoke Foreman with the URL or number of an issue whose change touches a screen, a command's output, or a running app.
End state: the PR Verification section has a visual-proof part, with captures committed under `.foreman/proof/N/`, or a line stating the gap and its reason, or `Visual proof: not required` and its basis.

## Gotchas
- Visual proof does not change the risk tier, `foreman:ready-to-deploy`, or the blocked overlay; [implementing](../../references/implementing.md) ("Missing or not-required visual proof is not an input of") owns that rule.
- Foreman runs no capture tool of its own; [implementing](../../references/implementing.md) ("the worker runs no capture tool beyond those commands") owns that rule.
