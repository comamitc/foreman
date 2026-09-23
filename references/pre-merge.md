# Pre-merge — coordinator and fresh primary repair workers (write)

Order: base drift/conflicts → CI → required approvals → final mergeability.

1. Fetch the resolved base and remote head. Compare local, remote, and PR heads.
   Preserve human commits. After publication, integrate current base through an
   ordinary merge commit authored by a primary worker, never a rebase/force-push.
   If linear-history policy requires rewriting published or human commits, use
   `authority-required`; do not change policy or rewrite history yourself.
2. Delegate conflicts with both sides' source context and the admitted spec.
   Preserve compatible intent, otherwise follow the spec. Verify the merge,
   checks, and clean tree; the coordinator pushes normally. Any new head or changed
   reviewed diff returns through the confirmation review and ratchet in
   [code-review convergence](review-convergence.md) before completing this station.
3. Read current checks with `gh pr checks PR --repo OWNER/REPO --required --json name,state,bucket,link`
   and all checks with the same command without `--required`. Pending returns
   exit 8. An empty set is not proof of success: corroborate repository requirements
   and GitHub merge state. Inspect logs with `gh run view RUN --repo OWNER/REPO --log-failed`.

   | Failure | Action |
   | --- | --- |
   | flake, supported by logs/history | rerun once per check/head; record rerun in remote evidence |
   | stale base | integrate base before diagnosing the resulting checks |
   | in-diff | fresh primary repairs with logs/spec/plan/diff; rerun original gate |
   | infrastructure | wait/back off with service guidance and re-observe |
   | human capability | exact typed blocker from recovery |

   `gh run rerun RUN --repo OWNER/REPO --failed` reruns eligible failed Actions
   jobs. Observe whether a new attempt already exists after an ambiguous request.
   For another CI provider use its documented authorized interface; do not invent
   a rerun endpoint. Observe at intervals of at most 60 seconds. The CI timeout is
   a diagnosis/re-observation boundary, not a human blocker or automatic success.
4. Observe review decision and required approvals. Agent census approval does not
   substitute for required GitHub human review. Missing required approval uses
   `authority-required` with one concrete requested action. Resume on observation.
5. Re-fetch base and query live PR state:

   ```sh
   gh pr view PR --repo OWNER/REPO --json state,isDraft,headRefOid,baseRefOid,baseRefName,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup,url
   ```

   Complete only if the PR is open/non-draft; local reviewed head equals remote
   branch and PR head; resolved base is current and integrated; no conflicts;
   required checks pass; required approvals exist; and GitHub reports no condition
   preventing immediate merge. Require affirmative `MERGEABLE` and `CLEAN`.
   Withhold readiness for BLOCKED, BEHIND, DIRTY, UNKNOWN, DRAFT, UNSTABLE, pending,
   or an unrecognized status until its actual impediment is resolved. Never bypass
   rules, enable auto-merge, enqueue, or merge to obtain a passing state.
6. Trace each bot claim before telemetry. A comment or review from Bugbot, an
   agentic security review, or any other non-human author is a bot claim, not a
   finding. Trace each claim against the current head and the admitted spec. A
   reachable, in-scope failure is recorded as a finding with severity and
   confidence. A claim that does not survive the trace is dismissed with a
   reason: noise, out of scope, already fixed, or not reproducible on the
   current head. Dismissal is not silence. A dismissed claim does not enter
   fix, does not consume a review-fix round, and does not block
   `capstan:ready-to-deploy`. An undismissed, untraced bot claim blocks ready.
   Do not project ready while a bot thread on the marked pull request has
   neither a trace nor a dismissal. Publish the trace or dismissal on the pull
   request in a comment marked `<!-- capstan:review-disposition owner/repo#N -->`.
   Name the bot comment URL, the head SHA, and either the finding or the
   dismissal reason. Do not add a marker kind. A later head change requires
   open bot claims to be traced again. A dismissal that names an older head
   does not cover the new head. A bot approval does not satisfy a required
   approving review. A bot request-changes does not, by itself, satisfy the
   effective-blocker test. Bot claims do not replace the secondary code-review
   census and do not replace round 1. Do not set `unsafe_autonomy`. Do not redo
   the git-metadata grant. Do not merge.
7. Publish final telemetry summary. The summary states one attempt table, two
   wall totals, and the no-estimate rule. The table has one row per station
   attempt. The columns are stage, start UTC, end UTC, wall time, role,
   harness, and the usage fields that harness reported. Say `unknown` when not
   reported; never estimate or use zero for missing usage. A field the harness
   did not report is `unknown`, not zero and not an estimate. Worker-process
   wall is the sum of attempt rows that have a process start and exit.
   End-to-end wall is from spec admission to the ready-label read-back, or to
   the review-exhausted summary publication. A bound that was not observed is
   `unknown`. The two totals are not substitutes for each other. A telemetry
   gap in this table does not block `capstan:ready-to-deploy`. Project
   `capstan:ready-to-deploy` on the issue with the existing stage rules. Add
   the same label to the marked pull request with
   `gh pr edit PR --repo OWNER/REPO --add-label capstan:ready-to-deploy`.
   Read issue labels with `gh issue view N --repo OWNER/REPO --json labels`.
   Read pull-request labels with `gh pr view PR --repo OWNER/REPO --json labels`.
   Read remote heads, base heads, and live pull-request state again with the
   step 5 query. If the pull-request label is missing, run the add again on that
   pull request and read the pull-request labels again. Do not open a second
   pull request. On the pull request, add or remove only
   `capstan:ready-to-deploy`. Preserve unrelated pull-request labels. Do not copy
   `capstan:planning`, `capstan:review`, or `capstan:fix` onto the pull request.
   If the live gate no longer holds, run
   `gh pr edit PR --repo OWNER/REPO --remove-label capstan:ready-to-deploy`
   and read the removal back with
   `gh pr view PR --repo OWNER/REPO --json labels`.
   Success is a read-back that does not contain the label. If the label remains,
   remove it once more on that pull request and read it back again. Do not leave
   it. Repair the issue label only with the existing stage rules.
   `Capstan: owner/repo#N` remains the identity check. The pull-request label is
   not a substitute for that marker, branch `capstan/N`, or the worktree. Stop
   without merging or deploying.

   Emission: after the marked summary is read back, the coordinator's final
   message in the host session contains the stage-analysis table and the two
   wall totals. A URL may follow. The URL alone does not satisfy this. Trigger
   only at verified `capstan:ready-to-deploy` or review exhaustion. No
   mid-station note. The surface is that final message on Claude Code, Codex,
   Grok, and Oh My Pi. No plugin, notification command, status-line API, or
   new marker. Workers do not post the table. Do not add a second summary
   comment or post the table on the pull request.

   Same-figures rule: copy the published summary's figures. Do not recompute.
   `unknown` stays `unknown`.

   Gap rule: a missed host message is a telemetry gap in `run.md`. It does not
   skip the GitHub summary and does not withhold ready.

Technical repair workers use the common result headings plus `## Resulting head`
and `## Original failure verification`. Failed attempts use shared recovery.

A new delivery with no remote issue branch or pull request stays on local `capstan/N` through code review and fix. Do not push, and do not create the pull request, at that transition. The secondary reviews the exact local base and head SHAs and their three-dot diff. A fix commit is not pushed merely to start the next review. The closure-proof gate still applies before review. Local CI is the declared checks run on the local machine, including tests and the other commands the plan or repository conventions already name. Do not invent a check from a file extension. Do not parse workflow YAML. A named check that cannot run locally is recorded as not run locally and remains a pre-merge GitHub check. A missing or failing local check uses existing recovery and does not advance toward publication. The publication boundary is the point after local code review converges and base freshness is confirmed. Before the first push, fetch the resolved base. A stale-base ordinary merge that changes the head is a changed candidate. It needs a fresh review of the new local SHAs and three-dot diff, zero effective blockers, and a rerun of affected local CI before the first push. Do not publish the pre-merge head. Then push the exact reviewed `capstan/N` head once without force and create or reconcile one non-draft pull request. Apply the existing marker, `Closes #N`, title suffix, and read-backs. The observed pull-request head must equal the reviewed local head before pre-merge. Before the pull request exists, marked code-review censuses and dispositions are issue comments. After creation, the final converged exact-head census and applicable dispositions go on the pull request and link that issue history. No new marker kind. Do not read, wait for, or rerun GitHub-hosted checks before the publication boundary. Pre-merge owns those checks after publication. Do not use `[skip ci]`, workflow disabling, draft behavior, branch-rule changes, or a synthetic empty commit. This is not a promise of one workflow run. Record why each post-publication push was necessary. If a matching remote branch or marked pull request already exists, preserve it. Do not delete, close, or recreate it to obtain the deferred path.
