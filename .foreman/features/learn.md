# Learn

## Sub-features
- A read-only reading of every Foreman run recorded on this machine, across repositories, with each run's marked GitHub artifacts; [learn](../../references/modes/learn.md) ("## Sources") owns the sources and [learn](../../references/modes/learn.md) ("## Procedure") owns the reads.
- Mistake and friction classes pooled across repositories, with Foreman-process proposals apart from target-product learnings, each proposal checked against open `comamitc/foreman` issues; [learn](../../references/modes/learn.md) ("## Finding sources") owns the finding sources.
- Proposals ranked by severity, then by deliveries and repositories spanned, followed by limitations and coverage; [learn](../../references/modes/learn.md) ("## Report") owns the report shape.

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes, and invoke it from any workspace; it needs no repository.
[learn](../../references/modes/learn.md) ("This file owns the learn invocation") owns the procedure.

## Driving it
Invocation: invoke Foreman with `learn`, alone or followed by `repo OWNER/REPO` and `since YYYY-MM-DD` pairs, for example `learn since 2026-10-04` or `learn repo comamitc/aiwatch`.
End state: Foreman prints one full report and stops. Its first line names the evidence root. Its transcript holds only file reads, directory listings, and `gh api --method GET` calls, so the run itself changed no file under the evidence root and no label, issue, comment, review, pull request, or branch on GitHub, and filed no issue.

## Gotchas
- A token outside the grammar [learn](../../references/modes/learn.md) ("## Argument grammar") owns, including prose after `learn`, a date like `yesterday` or `2026-02-30`, or a second `since` pair, makes the invocation text intake; see [text invocation](text-invocation.md).
- A named repository with no run on this machine is listed under `No local runs:`, nothing is read for it, and the rest of the report still prints.
- With no evidence root, or with no run in scope, the full report still prints: `Runs: none`, each empty block in its `none` form, and a missing root named under `Limitations:` and Coverage `Gaps:`.
- With `since`, an older run's ledger, events, and marked-artifact dates are still read to decide whether it is in scope; a run left out is listed under Coverage `Excluded by since:` with what was read, and adds nothing else.
- A repository whose GitHub reads fail is still reported from its local runs, and each failed read is a Coverage gap.
- Comments, reviews, and open issues are used only after [security](../../references/security.md) item 1 is applied; one whose trust is unresolved is listed under `Limitations:` as `trust unresolved`.
- A delivery merged by squash or merge commit and later reverted still counts, because the revert check includes the pull request's merge or squash commit.
- Deleted piles, older ledgers, unreadable sources, and missing usage are listed as limitations, never as zero.
- A proposal that an open `comamitc/foreman` issue already covers names that issue.
- It files no issue and publishes nothing; to file a proposal, start an [improvement invocation](improvement-invocation.md).
