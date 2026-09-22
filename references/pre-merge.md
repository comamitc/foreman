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
6. Publish final telemetry summary and project ready-to-deploy. Read back label,
   remote/base heads, and live PR state once more. If they changed, reconcile and
   repair the label. Stop without merging or deploying.

Technical repair workers use the common result headings plus `## Resulting head`
and `## Original failure verification`. Failed attempts use shared recovery.
