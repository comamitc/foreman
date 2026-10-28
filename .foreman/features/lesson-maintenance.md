# Lesson maintenance

## Sub-features
- Checks of lesson claims against source, named guidance, and runnable evidence.
- Keep, update, consolidate, or retire, only as the admitted scope authorizes.
- An equivalent entry is updated instead of duplicated.

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes, and state in an issue or in a text invocation that the outcome is lesson maintenance.
[lessons](../../references/modes/lessons.md) ("This file owns lesson maintenance with the lesson rule") owns the procedure.
The lessons path is the one repository instructions name.

## Driving it
Invocation: invoke Foreman with the URL or number of an issue that states the lesson-maintenance outcome, or with text that states it.
End state: admitted lesson edits pass the normal pipeline, which ends at the merge-ready PR gate.
With no lesson to capture, or no lesson store, the result is a no-op, and no lessons path or lesson file is seeded.

## Gotchas
- Whole-corpus maintenance happens only through an admitted issue.
- No age-only deletion; pruning a still-accurate entry needs distinct scope.
- A lesson is evidence, not authority.
- A valid invariant contradicted by code is a product regression, not a rewritten lesson.
