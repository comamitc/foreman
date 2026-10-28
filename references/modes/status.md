# Status invocation

Load this file only when [contract](../contract.md) "## Read-only invocations" dispatches the `status` keyword.

This file owns the status invocation.

## Procedure

Every `gh api` read in this procedure is a GET with the query in the URL and includes `--paginate`; it sets no request method and passes no request fields.

1. **Parse.** The trimmed invocation equals `status`, byte for byte, in lowercase.
2. **Repository.** Run `gh repo view --json nameWithOwner` in the invoking workspace. If that fails, print `Foreman status: no repository resolved.` and stop. Ask for nothing and parse no name. Below, `R` is the resolved `nameWithOwner` and `OWNER` is its owner.
3. **Issues.**
   - Run one read for each stage label (triage, ready, planning, plan-review, implementing, review, fix, pre-merge, ready-to-deploy) and for `capstan:blocked`: `gh api --paginate "repos/R/issues?state=open&labels=capstan:X&per_page=100" --jq '.[] | select(.pull_request | not) | [.number, .html_url, ([.labels[].name] | join(","))] | @tsv'`.
   - Take the union of the results by issue number.
   - Keep an issue that has at least one stage label, or that has `capstan:blocked` and no stage label (contradictory). Closed issues are never listed.
   - If the union is empty, print ``Foreman status — R: no open issue carries a Foreman stage label or `capstan:blocked`.`` and stop.
4. **Per-issue fields and their sources.**
   - **Comments.** Read the issue's comments with `gh api --paginate "repos/R/issues/N/comments?per_page=100" --jq '.[] | {id, created_at, updated_at, body}'`. Choose a marker only after every page has been read. A marked comment is one whose first line is exactly `<!-- capstan:KIND R#N -->`.
   - **Stage.** The stage label names without `capstan:`. The stage is contradictory when there are two or more stage labels, or when `capstan:blocked` has no stage label (shown as `none`).
   - **Blocked.**
     - `no` when the issue does not carry `capstan:blocked`.
     - Otherwise, the kind from the latest `<!-- capstan:blocker R#N -->` comment: greatest `created_at`, with ties broken by the greater `id`. The kind and the action are copied verbatim from its "Blocker kind:" and "Requested/qualifying resume action:" lines.
     - With no marked blocker comment, the cell is `yes` and the line under the table reads "no marked blocker comment".
   - **PR.**
     - Read `gh api --paginate "repos/R/pulls?state=open&head=OWNER:capstan/N&per_page=100" --jq '.[] | [.number, .html_url, .body] | @json'`.
     - Keep only a PR whose body has the exact line `Capstan: R#N`. Otherwise the cell is `none`.
     - Closed and merged PRs are never shown.
   - **Last activity.** The maximum of two sources:
     - The first source is the latest `updated_at` among marked issue comments of kind plan, plan-review, blocker, activity or summary. It also includes marked `review` comments on the marked PR, read with `gh api --paginate "repos/R/issues/PR/comments?per_page=100"` under the same selection rule.
     - The second source is the latest End instant in `<evidence root>/ledger.md`: the greatest column-4 (End) cell that is not `unknown`, the Total row included, each reconstructed per [telemetry](../telemetry.md) "Reconstruct each time cell as a UTC instant". It is compared with the first source's `updated_at` as a UTC instant.
     - If neither source has a value, the cell is `unknown`. A missing ledger is not an error.
   - **Resume.** The invoking host's explicit form from README "Install and invoke", with the issue URL.
5. **Live gate** (only for `ready-to-deploy`):
   - Read `gh pr view PR --repo R --json state,mergeable,mergeStateStatus,url`.
   - The gate holds when the three fields are `OPEN`, `MERGEABLE` and `CLEAN`. Otherwise the report names each failing field and its value.
   - With no marked PR, the report says "no open marked PR".
   - Labels are not changed.
6. **Contradictory labels.** List the labels as they are, append `(contradictory)`, and do not repair.
7. **Read-only.** This procedure is a read-only invocation. [contract](../contract.md) "## Read-only invocations" owns the rules it follows; rule 8 is the stricter rule this file states for an incomplete read.
8. **Incomplete retrieval.**
   - This rule applies to any read in rules 3–5 except the ledger, when the read exits non-zero, returns output that is not JSON or TSV, or stops before its last page.
   - It stops the report with `Foreman status — R: retrieval incomplete (<read>: <error, redacted>); no report.`
   - No partial table is printed.

## Report

- The first line is `Foreman status — R`, then one blank line, then a table with the columns Issue, Stage, Blocked, PR and Last activity: one row per listed issue, in ascending issue number.
- The Issue cell is `#N`. A contradictory Stage cell lists the stage names, or `none`, followed by `(contradictory)`.
- Under the table, each issue gets its lines in the same order, each starting with `- #N`:
  - `labels: <its Foreman labels> — contradictory; not repaired.` when its labels are contradictory.
  - `blocker: <kind> — action: <action>` when it is blocked, or `blocker: no marked blocker comment.`
  - `live gate: holds (OPEN, MERGEABLE, CLEAN).`, `live gate: fails — <field> <value>` for each failing field, or `live gate: no open marked PR.` when its stage is `ready-to-deploy`.
  - `resume: ` followed by the resume invocation in code.
