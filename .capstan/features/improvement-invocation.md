# Improvement invocation

## Sub-features
- On-demand analysis of a named batch of runs.
- Evidence-backed proposals, deduplicated against open issues.
- Review corrections named by PR, review, or comment URL.
- Replay of captured runs; [contract](../../references/contract.md) ("This file owns `evidence.retain_replay`") owns the capture switch.
- No-new-violations guard; [improvement](../../references/modes/improvement.md) ("This file owns the improvement invocation") owns these rules.

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes, and state in an issue or in a text invocation that the outcome is an improvement invocation.

## Driving it
Invocation: invoke Foreman with the URL or number of an issue that states the improvement outcome, or with text that states it.
End state: a published proposal stops at an open pull request; an analysis-only request stays a report.

## Gotchas
- An issue is published only after an explicit improvement invocation.
- A missing replay bundle, an off switch, or a failed capture is a named limitation, not a zero.
- A rejected or unsupported proposal makes no product change, and an unverified review correction changes nothing.
- It does not edit the installed or running skill.
