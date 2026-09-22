# Implementing — fresh primary, write

The coordinator extracts the [finding resolution](findings.md) closure-row
requirements into the pack; the worker reads the brief and the pack. Planning
handoff is permission to implement, not independent approval of the corrected
design or closure of its findings.

1. Read the brief and the pack: the current plan text, every carried finding row
   with its proposed disposition including unfinished correction work, the rule
   extract, the commands the plan names plus the final gates, and the plan's
   affected files and tests as Named files. A write station may read named files
   fully and run the named checks and declared final gates; it has no numeric
   ceiling. A path the pack does not name is a gap reported under Risks and
   unresolved items, not a search. A one-file, one-check item gets a compact pack
   whose single named file and check bound the reads. Map ALL carried findings to
   implementation tasks/checks or evidence-backed refutations. Complete this
   mapping before affected code is written. Reconcile existing work before
   repeating interrupted steps.
2. Implement plan items in order. Use a failing behavior check where meaningful,
   prove it fails for the intended reason, then make the smallest change and rerun.
   Documentation, configuration, deletion, generated, and operational changes may
   use stronger appropriate proof instead; explain when a failing test adds no value.
3. Run each item's verification. Keep scope narrow; commit coherent changes.
   Use the planning simplicity ladder before introducing new code. Preserve human
   changes and do not silently stage unrelated files.
4. Prove each carried finding's original acceptance condition against the code,
   or propose a refutation with concrete evidence. Record unfinished obligations
   explicitly; technical failures stay in implementing recovery, not planning.
   Run all declared final checks and exercise the real user surface. Record actual
   commands, exit statuses, output/evidence paths, and the resulting head SHA.
5. Prepare PR text with Why, Scope, Tradeoffs, Blast Radius, and Verification.
   Report risks honestly and verify a clean worktree containing the intended commits.
   Finish everything the pack supports; the result cites the pack.

For any effective blocking obligation carried from review, include the red/green/bite
row in the closure-row format the pack carries from
[finding resolution](findings.md); planned or proxy tests are insufficient.

Add `## Acceptance proof`, `## Finding closure proofs`, `## Finding dispositions`,
`## Resulting head`, and `## PR content` to common result headings. Complete when the diff is nonempty and
in scope, declared checks
pass, every carried finding has an evidenced proposed disposition, the user-visible
result is demonstrated, commits contain the intended change, and the tree is clean.
A no-op or already-delivered issue is reconciled with the
coordinator; do not manufacture a change to satisfy the nonempty criterion.

Coordinator independently checks evidence and applies the closure proof gate for
every carried effective blocker, then pushes the exact issue branch without
force, and finds or creates one non-draft PR on base `main` whose written body
contains both the identity marker `Capstan: owner/repo#N` and a separate line
`Closes #N`. `N` is the delivery issue number in the pull request's repository.
The created title is the subject, a space, then `(#N)`. `N` is not the
pull-request number. The #12 shape is
`Replace the repository tour with one coordinator-written pack per worker launch (#12)`.
The marker stays the identity check. A title suffix is not a substitute for the
marker. A wrong title does not retarget branch `capstan/N` or worktree
`.worktrees/capstan+N`. The keyword is `Closes #N` only. Do not use
`Fixes`. Do not use `owner/repo#N` as the close keyword. Do not close the issue
at create. Observe a push rejection before deciding how to integrate remote
human work; delegate any needed commit/repair to a worker. Read back
PR/head/body after create. Read the title back after create. If the suffix is
missing or different, repair it with `gh pr edit` on the same pull request. Do
not open a second pull request. If the title already ends with ` (#N)` for that
issue, leave it unchanged and do not double the suffix. If `Closes #N` is
missing, add that line on the same pull request. If the body already contains
`Closes #N` for that issue, leave it and do not write the keyword a second
time. Shipping this text does not rewrite already-merged pull requests.
The rule applies to pull requests Capstan creates or next edits after the text
is in force. Then review.
Attempt failures use recovery inside implementing rather than the review fix label.
