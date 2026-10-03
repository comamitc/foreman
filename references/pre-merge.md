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

   CI waits and repair workers: see [telemetry](telemetry.md) ("The attempt table has these columns, in this order").
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
   dismissal reason. A later head change requires
   open bot claims to be traced again. A dismissal that names an older head
   does not cover the new head. A bot approval does not satisfy a required
   approving review. A bot request-changes does not, by itself, satisfy the
   effective-blocker test. Bot claims do not replace the secondary code-review
   census and do not replace round 1. Do not set `unsafe_autonomy`. Do not redo
   the git-metadata grant. Do not merge.
7. [telemetry.md](telemetry.md) owns the
   attempt-table field rules and emission. Withhold `capstan:ready-to-deploy`
   while an applicable policy row for a mandatory rule is not `verified`;
   [telemetry.md](telemetry.md) owns the policy row and the mandatory-rule test.
   A non-mandatory row that is not `verified` is disclosed in the summary and
   does not withhold ready. An advisory partition of a missing-evidence finding
   does not set the row to `verified` and does not clear the withhold. Route the
   withhold by the step 3 failure table: evidence or a repair an agent can
   supply is the `in-diff` row, and a rule that needs what only a person can
   supply is the `human capability` row, with the policy row as the blocker
   evidence. A repair that changes the head returns through step 2. The
   withhold is not review exhaustion. It ends only when that mandatory row is
   `verified` at the current head. Project
   `capstan:ready-to-deploy` on the issue with the existing stage rules and on
   the marked pull request with [contract.md](contract.md) "Stage projection"
   ("After a successful ready projection"), through its issue and pull-request
   label read-backs and its live re-read with the step 5 query.
   If the pull-request label is missing, re-add it
   once and read it back as that section states. If the live gate no longer
   holds, remove the pull-request label and read it back as that section states.
   `Capstan: owner/repo#N` remains the identity check. The pull-request label is
   not a substitute for that marker, branch `capstan/N`, or the worktree.

   [telemetry.md](telemetry.md) owns the attempt-table field rules, the
   end-to-end wall, and the end-of-run order. After the ready-label read-back,
   follow that order. Stop without merging or deploying.

Technical repair workers use [templates/result.md](../templates/result.md), including
`## Resulting head` and `## Original failure verification`. Failed attempts use shared recovery.

[references/publication.md](publication.md) owns publication.
