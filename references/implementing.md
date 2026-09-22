# Implementing — fresh primary, write

Read [finding resolution](findings.md). Planning handoff is permission to implement,
not independent approval of the corrected design or closure of its findings.

1. Read the implementation plan, complete plan-review census, correction/handoff,
   admitted spec, conventions, adjacent code/tests, and current status. Map ALL
   carried findings to implementation tasks/checks or evidence-backed refutations,
   including unfinished correction work. Complete this mapping before affected
   code is written. Reconcile existing work before repeating interrupted steps.
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

For any effective blocking obligation carried from review, include the red/green/bite
row from [finding resolution](findings.md); planned or proxy tests are insufficient.

Add `## Acceptance proof`, `## Finding closure proofs`, `## Finding dispositions`,
`## Resulting head`, and `## PR content` to common result headings. Complete when the diff is nonempty and
in scope, declared checks
pass, every carried finding has an evidenced proposed disposition, the user-visible
result is demonstrated, commits contain the intended change, and the tree is clean.
A no-op or already-delivered issue is reconciled with the
coordinator; do not manufacture a change to satisfy the nonempty criterion.

Coordinator independently checks evidence and applies the closure proof gate for
every carried effective blocker, then pushes the exact issue branch without
force, and finds or creates one non-draft PR with the contract marker and correct
base. Observe a push rejection before deciding how to integrate remote human work;
delegate any needed commit/repair to a worker. Read back PR/head/body, then review.
Attempt failures use recovery inside implementing rather than the review fix label.
