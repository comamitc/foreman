# Publication

A new delivery with no remote issue branch or pull request stays on local `capstan/N` through code review and fix. Do not push, and do not create the pull request, at that transition. The secondary reviews the exact local base and head SHAs and their three-dot diff. A fix commit is not pushed merely to start the next review. The closure-proof gate still applies before review. Local CI is the declared checks run on the local machine, including tests and the other commands the plan or repository conventions already name. Do not invent a check from a file extension. Do not parse workflow YAML. A named check that cannot run locally is recorded as not run locally and remains a pre-merge GitHub check. A missing or failing local check uses existing recovery and does not advance toward publication. The publication boundary is the point after local code review converges and base freshness is confirmed. Before the first push, fetch the resolved base. A stale-base ordinary merge that changes the head is a changed candidate. It needs a fresh review of the new local SHAs and three-dot diff, zero effective blockers, and a rerun of affected local CI before the first push. Do not publish the pre-merge head. Apply the existing marker, `Closes #N`, title suffix, and read-backs. The observed pull-request head must equal the reviewed local head before pre-merge. Before the pull request exists, marked code-review censuses and dispositions are issue comments. After creation, the final converged exact-head census and applicable dispositions go on the pull request and link that issue history. Do not read, wait for, or rerun GitHub-hosted checks before the publication boundary. Pre-merge owns those checks after publication. Do not use `[skip ci]`, workflow disabling, draft behavior, branch-rule changes, or a synthetic empty commit. This is not a promise of one workflow run. Record why each post-publication push was necessary. If a matching remote branch or marked pull request already exists, preserve it. Do not delete, close, or recreate it to obtain the deferred path.

At the publication boundary, push the exact reviewed `capstan/N` head once without
force, and find or create one non-draft PR on the resolved base whose written body
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
is in force.
