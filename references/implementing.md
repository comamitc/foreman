# Implementing — fresh primary, write

1. Read the accepted plan, admitted spec, conventions, adjacent code/tests, and
   current status. Reconcile existing work before repeating steps after interruption.
2. Implement plan items in order. Use a failing behavior check where meaningful,
   prove it fails for the intended reason, then make the smallest change and rerun.
   Documentation, configuration, deletion, generated, and operational changes may
   use stronger appropriate proof instead; explain when a failing test adds no value.
3. Run each item's verification. Keep scope narrow; commit coherent changes.
   Use the planning simplicity ladder before introducing new code. Preserve human
   changes and do not silently stage unrelated files.
4. Run all declared final checks and exercise the real user surface. Record actual
   commands, exit statuses, output/evidence paths, and the resulting head SHA.
5. Prepare PR text with Why, Scope, Tradeoffs, Blast Radius, and Verification.
   Report risks honestly and verify a clean worktree containing the intended commits.

Add `## Acceptance proof`, `## Resulting head`, and `## PR content` to common
result headings. Complete when the diff is nonempty and in scope, declared checks
pass, the user-visible result is demonstrated, commits contain the intended change,
and the tree is clean. A no-op or already-delivered issue is reconciled with the
coordinator; do not manufacture a change to satisfy the nonempty criterion.

Coordinator independently checks evidence, pushes the exact issue branch without
force, and finds or creates one non-draft PR with the contract marker and correct
base. Observe a push rejection before deciding how to integrate remote human work;
delegate any needed commit/repair to a worker. Read back PR/head/body, then review.
Attempt failures use recovery inside implementing rather than the review fix label.
