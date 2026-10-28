# Correction

## Sub-features

- Mistake classes and friction classes from earlier deliveries, each seen in two or more deliveries and cited by occurrence.
- An inventory of existing guardrails before any new check.
- One triage question: fix each item now or file it as an issue.
- Enforcement at the highest level that works, proven against a real past occurrence and registered where later deliveries run it.
- Rules placed in a standards file with a rule-and-enforcer table, and pruning proposals; [correction](../../references/modes/correction.md) ("This file owns correction") owns these rules.

## How to get to it (user POV)

Install Foreman as [README](../../README.md) ("Install and invoke") describes, and state in an issue or in a text invocation that the outcome is correction.

## Driving it

Invocation: invoke Foreman with the URL or number of an issue that states the correction outcome, or with text that states it.
End state: after you answer the triage question, items picked to file later are open issues with their evidence, and items picked to fix now pass the normal pipeline, which ends at the merge-ready PR gate. With nothing picked to fix now, the run stops after filing with no PR; the issue keeps its triage stage label, and a marked summary on it lists the filed issues.

## Gotchas

- A one-off finding is not a class.
- Issues are filed only for items the invoker picked to file later, and not for a duplicate of an open issue.
- Pruning is proposed, not applied without a pick.
- The instruction file gets only a pointer to the standards file.
- An existing standards file is reused; a new `CONTRIBUTING.md` is created only when none exists.
- Resuming a filing-only run reports its summary and files nothing again.
