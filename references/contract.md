# Delivery contract

## Identity and authority

Resolve the repository from the explicit URL or `gh repo view --json nameWithOwner,defaultBranchRef`.
Resolve the base from the admitted triage decision, otherwise repository default.
Repository integration instructions are evidence to settle the base during triage;
do not infer it from `origin/HEAD`. Read applicable repository instructions first.

An issue URL uses that issue and does not create a second issue. Allowed
overrides stay overrides. An invocation that is an issue number, with or
without those overrides, uses that issue when it resolves in the current
checkout. Other prose is not this path even if it contains a digit.

An invocation whose every token is an issue URL, an issue number, or an
allowed override, separated by spaces or commas, naming two or more distinct
issues, is a batch invocation;
[references/modes/batch-invocation.md](modes/batch-invocation.md) ("This file owns batch invocation order")
owns it. Any other invocation, including prose that contains issue numbers or
issue URLs, is not a batch invocation and follows this section unchanged.

"## Read-only invocations" owns read-only invocations and their dispatch. "### Init" owns the init invocation, and text intake does not take it.

Other non-empty prose with no GitHub URL creates one issue in the repository
`gh repo view` resolves from the invoking workspace. Title is the first
non-empty line, at most 256 characters. Body is the full text. Emit the new
issue URL in the host session before continuing. Then run the normal delivery.
Preserve the text as the original request.

If `gh repo view` cannot resolve a repository, create no issue and do not parse
a name from the prose. Ask for `owner/repo`. A GitHub URL that is not an issue
URL creates no issue. Empty text creates no issue. Do not read a filesystem
path. Do not use the surrounding transcript.

The created issue is the delivery identity. This one create is the only added
authority. An ordinary delivery does not create issues. Text intake does not
enter init and does not run init.

An outcome mode files issues only where its mode file grants it: [improvement](modes/improvement.md) ("An issue is published only after an explicit improvement invocation") and [correction](modes/correction.md) ("This file owns correction").

The create-time title is the provisional title. It is the first non-empty line of the preserved original request, at most 256 characters. On the `gh issue edit` that publishes the admitted spec, pass `--title` only when the live title still equals that provisional title and the Problem cut is non-empty. If the live title does not equal that provisional title, omit `--title`. If the live title equals that provisional title and the Problem cut is empty, omit `--title` and still publish the spec body. A title a person already changed stays as it is. An issue opened by URL or number uses this same comparison. Do not read the surrounding transcript.

When `--title` is set, its value is the first sentence of the admitted Problem section. Use the Problem body under that heading and before the next heading. Use the first non-empty paragraph. A paragraph is a maximal run of non-blank lines. If the Problem body has no such paragraph, the cut is empty. If the paragraph contains `.`, `!`, or `?`, keep the text through the first of those characters. If it does not, keep the paragraph. Trim each kept line, drop a line that becomes empty, and join the remaining lines with one space. Trim the ends. If the result is longer than 256 characters, keep the first 256 characters. If the result is empty, omit `--title` on that same publishing edit. Still publish the spec body. The empty cut is not a successful title write. Record the empty cut in the publication record that triage step 5 already requires. Do not send an empty title. Do not send `--title` on a later edit.

Read the title back after that edit. If `--title` was sent, the read-back title must equal the sent title. If `--title` was omitted, the read-back title must equal the live title from before the edit. A mismatch is not a successful publish. An empty cut is not a reason to skip the spec publish. Do not send a second edit to change the title.

[references/recovery.md](recovery.md) owns blocked-overlay removal.

| Item | Stable identity |
| --- | --- |
| Delivery | `owner/repo#N` |
| Branch | `capstan/N` |
| Worktree | `<repo>/.worktrees/capstan+N` |
| PR | exact head `capstan/N` and body line `Capstan: owner/repo#N` |
| Local evidence root | `${CAPSTAN_STATE:-${XDG_STATE_HOME:-$HOME/.local/state}/capstan}/owner/repo/N/` |

`capstan:ready-to-deploy` is not a substitute for `Capstan: owner/repo#N`, branch
`capstan/N`, or the worktree.

Titles never participate in identity. Resolve the primary repository location
from `git worktree list --porcelain` rather than nesting worktrees in worktrees.
Use a fresh worktree for a new issue; continue an existing matching issue
worktree. Never switch the shared checkout or edit the integration branch there.
Before creating `capstan/N`, run `git fetch origin <resolved-base>` so `origin/<resolved-base>` is updated in this run. For example, a repository whose resolved base is `main` fetches `origin/main`. Immediately after a successful fetch, record the SHA of that ref. Create the worktree from that SHA. Local `<base>`, an unfetched `origin/<base>`, and `origin/HEAD` are not valid parents. If the fetch fails, stop. Do not create the worktree from local `<base>`. An existing `capstan/N` worktree is not rebased or recreated. Do not fast-forward, switch, or edit the shared checkout.
Inspect and resolve the base before that fetch. Edit product files only after the worktree exists. If the matching issue worktree already exists, continue it without rebasing or recreating it. If the matching `capstan/N` branch exists and no matching worktree is attached, do not continue a missing worktree and do not run `git worktree add -b` again. Use the existing rule in the next sentences: attach that branch without `-b`. OpenClaw stays in the original checkout. Read-only research that edits no product file does not need a new worktree.
When absent, create it with `git worktree add -b capstan/N ./.worktrees/capstan+N <recorded-sha>`
from the repository root. Its parent is the recorded SHA, not the ref name alone. If a matching branch
already exists, attach that branch without `-b`. Preserve dirty work and human
commits. An unrelated branch, worktree, or PR occupying the identity is a
collision, not permission to overwrite it. Observe ancestry, marked comments,
and ownership; ask for disposition only if both intents cannot be preserved.

The coordinator may create its worktree/branch, push normally, create/update its
PR, publish issue/PR comments, replace the admitted issue specification, change
Capstan labels, and rerun eligible checks. Observe before every external mutation
and read back afterward. On ambiguous exit, observe effects before retrying.
The coordinator does not edit product files or author product commits.

Workers may edit and commit product files only at write stations, inside the
issue worktree. Read stations may write only their assigned evidence result.
Workers never push or mutate GitHub. Capstan never force-pushes, merges, deploys,
creates credentials, purchases quota, changes security settings, or performs
destructive production actions. A required action outside these boundaries uses
[recovery](recovery.md)'s typed handoff; authorization does not add a v1 merge mode.

Completion means the requested, authorized endpoint. Capstan ends at a verified open merge-ready PR. Deployment stays forbidden. `capstan:ready-to-deploy` is the live gate, not a deploy step.

A host or user instruction file does not change a Capstan delivery's completion endpoint or its fetch-then-worktree order.

## Read-only invocations

This section owns read-only invocations: their dispatch, the keyword table, the rules every read-only invocation follows, and the report finding shape.

Trim the invocation and split it on whitespace into tokens. An invocation whose first token equals a keyword in the table below, byte for byte, and whose remaining tokens all match the argument grammar its row points to, is a read-only invocation. Load only the mode file that row names and follow it. Any other invocation, including prose that starts with a keyword, is not a read-only invocation and follows "## Identity and authority" unchanged.

| Keyword | Mode file | Argument grammar owner |
|---|---|---|
| `status` | [references/modes/status.md](modes/status.md) ("This file owns the status invocation") | [status](modes/status.md) ("The trimmed invocation equals `status`, byte for byte, in lowercase") |
| `architect` | [references/modes/architect.md](modes/architect.md) ("This file owns the architect invocation") | [architect](modes/architect.md) ("A path token is relative to the invoking workspace's git work tree") |
| `guardrails` | [references/modes/guardrails.md](modes/guardrails.md) ("This file owns the guardrails invocation") | [guardrails](modes/guardrails.md) ("The invocation is `guardrails` followed by zero or more path tokens") |
| `learn` | [references/modes/learn.md](modes/learn.md) ("This file owns the learn invocation") | [learn](modes/learn.md) ("The invocation is `learn` followed by zero or more `repo OWNER/REPO` pairs") |
| `help` | [references/modes/help.md](modes/help.md) ("This file owns the help invocation") | [help](modes/help.md) ("The invocation is `help` followed by zero or more tokens of any kind") |

This table is the only list of read-only keywords. A keyword is one lowercase word that is not an issue number or an allowed override. A new read-only mode adds its row here and owns its argument grammar in its mode file.

`init` is not a read-only keyword and has no row in this table. The read-only rules below do not apply to init. "### Init" owns the init invocation.

Every read-only invocation follows these rules. A mode file may state a stricter rule, never a weaker one.

- It creates or changes no label, comment, issue, PR, branch, worktree, evidence file, ledger, or process.
- It runs no coordinator loop, triage, init, side-effect reconciliation, worker, or launch probe. It publishes no summary, stage analysis, or host status line.
- It prints its report once, then stops.
- An unreadable or partial source is a named gap in the report, never zero or an empty result. No result is invented.

A read-only report other than `status` or `help` states each finding with:

1. **Rule:** the Capstan rule applied, as its file and quoted heading.
2. **Evidence:** `path:line`, or a URL plus its commit SHA.
3. **Consequence:** what it leads an agent contributor to do.
4. **Fix:** the recommended fix and its level in [ladder](ladder.md) "## Enforcement".
5. **Issue body:** a ready-to-paste issue body for that fix.

Findings are ranked by severity, highest first. The report states its coverage limits: what it sampled and which sources it did not read.

## Global non-goals

These global non-goals apply to every Capstan file and every mode file. Capstan
never adds:

- a Capstan executable, parser, or controller (unless an admitted issue records
  the exception; #181 records it for `scripts/launch.sh` and its test script);
- a new stage, station, label, config field, or marker kind (unless an admitted
  issue records the exception; #185 records it for the config field
  `review_policy.residual_effect_approval`);
- a daemon, scheduler, watcher, or recurring job;
- a database, store, or state service;
- a host-skill copy, per-host plugin, or marketplace directory;
- an external skill dependency.

Capstan's own behavior is a skill procedure executed by the coordinator. A
Capstan init binary would violate the executable non-goal, not an
implementation choice. The executable non-goal does not apply to a target
repository unless that repository is Capstan. A delivery reads the target
repository's own conventions. It does not import this rule into that
repository. Permit only `git`, `gh`, existing harness CLIs, the coordinator's
launch builder `scripts/launch.sh` (workers never run it), `sha256sum` or
`shasum -a 256` for the ledger digest only, and a target repository's own CLI.
Do not permit the class "an installed CLI."

## Evidence and reconciliation

Read [security](security.md) before consuming issue content. Query issue and
comment author associations using `gh api repos/OWNER/REPO/issues/N` and the
paginated `/issues/N/comments` endpoint. Then inventory:

1. Issue body, admitted specification revision, trusted comments, and labels.
2. `git worktree list --porcelain`, worktree status, local/remote heads, ancestry,
   commits, and cumulative diff against the resolved base.
3. `gh pr list --repo OWNER/REPO --head capstan/N --state all --json number,body,state,headRefName,url`.
   Select the open PR with the exact marker and repository/head identity. Closed
   or merged PRs are evidence to inspect, not permission to recreate intent.
4. Live PR base/head, checks, approvals, and mergeability; marked remote artifacts.
5. Available local briefs, results, logs, `ledger.md`, and other telemetry.
   Recreate missing evidence directories and briefs from remote facts; missing
   files cannot strand a run. [telemetry.md](telemetry.md) owns `ledger.md`.

Select the furthest active station whose prerequisites are supported, accounting
for evidence made stale by current facts. Labels are hints. A complete plan can
survive lost local results. A malformed code review calls for fresh review;
incomplete planning artifacts follow [one-pass planning](plan-convergence.md).
A PR found after a creation timeout completes the existing creation rather than
duplicating it.

Plans identify the spec revision. Implementation and repair identify resulting
head SHA. Reviews identify exact head and base SHAs and inspect the three-dot
diff. A new head requires fresh cumulative review and affected checks; a changed
base requires reassessing the changed diff and review freshness. Neither change
discards a still-applicable spec or plan. Spec changes invalidate only dependent
judgments. PR readiness is always observed live.

## Marked Markdown artifacts

Use `<!-- capstan:KIND owner/repo#N -->` for `spec`, `plan`, `plan-review`,
`review`, `review-disposition`, `blocker`, `activity`, and `summary`. Put the spec marker in the issue
body, plans/plan reviews/blockers/activity/summaries in issue comments, and code
review censuses and dispositions in PR comments. Human-readable revision, UTC time, head/base,
and attempt lines disambiguate artifacts; no digest or schema protocol is needed.
The admitted body keeps product content concise; machine identifiers belong in
the hidden marker and evidence comments, not repeated product prose.
Activity, summary, and disposition shapes are prose-defined here, in review
convergence, and in telemetry; no additional
template or rigid format is required.

Inspect all paginated comments and exact markers before publishing. Preserve
history by appending a new revision comment when judgment changes. On an
ambiguous publication, compare marker, revision/SHAs, and content before repeating.
Only update Capstan-authored artifacts; never replace another author's comment.
Use body files with `gh issue edit/comment`, `gh pr create/edit/comment`, or
`gh api ... -F body=@FILE`; never interpolate issue text into shell command code.
Read back the body/comment after writing. Markers locate claims, not proof.

## Start condition

This section owns the start condition for every delivery, single or batch.

A Decisions entry `Depends on #M` or `Depends on owner/repo#M` in the admitted spec is a start condition. Only those entries count. Dependencies are never inferred from prose, links, or file overlap. In `Depends on #M`, M resolves in the delivery's own repository. In `Depends on owner/repo#M`, M resolves in `owner/repo`; an `owner/repo` equal to the delivery's repository is the same as `Depends on #M`. In this section, OWNER/REPO is the repository M resolves in.

Triage resolves M when it visits that entry: `gh api repos/OWNER/REPO/issues/M` returns an issue, or a pull request when the response has a `pull_request` field. For an entry in another repository, triage first reads `gh repo view OWNER/REPO --json defaultBranchRef`. M resolves to neither only when the issue read returns 404 Not Found and, for an entry in another repository, that repository read succeeded. Every other failed read is not an observation and follows the failed-read rule below. An M that resolves to neither is an Ask under [triage](triage.md) ("An ask is one numbered round of the current frontier."). The round names the entry and recommends correcting or removing it. It is never ignored.

The condition holds only when a pull request that is #M, or that closes issue #M, has merged and its merge commit is an ancestor of the fetched resolved integration base, or, for an entry in another repository, of that repository's default branch. Observe it with read-only calls:

1. For an issue, list the pull requests that close it with `gh issue view M --repo OWNER/REPO --json closedByPullRequestsReferences`. Issue closed state alone does not count.
2. For pull request #M, or each closing pull request P, read `gh pr view P --repo OWNER/REPO --json state,mergeCommit`. Only state `MERGED` with a merge commit counts.
3. For an entry in the delivery's own repository, run `git fetch origin <resolved-base>` and record the SHA as "## Identity and authority" requires ("record the SHA of that ref"). The merge commit counts only when `git merge-base --is-ancestor <merge-commit> <recorded-sha>` exits 0. Any other exit means it does not count. A pull request merged into another branch does not count unless its merge commit is an ancestor of the recorded SHA. For an entry in another repository, read its default branch with `gh repo view OWNER/REPO --json defaultBranchRef` and run `gh api repos/OWNER/REPO/compare/<merge-commit>...<default-branch>`. The merge commit counts only when the response `status` is `ahead` or `identical`. Any other status means it does not count. Nothing in that repository is cloned, fetched, or written.

The coordinator checks every entry at the ready station, after the admitted spec is published and before it creates or attaches the worktree or launches any worker. A delivery already past ready is not re-gated. A failed fetch or query, including a read of another repository that fails for missing access, is not an observation; recover it under [recovery](recovery.md) and do not start. The one exception is the issue read that makes M resolve to neither ("M resolves to neither only when"); it is the triage Ask above, not a recovery.

If an entry does not hold, the dependent does not start: no worker launches and no worktree changes. It gets the `authority-required` blocker ([recovery](recovery.md) "| authority-required |") with the action "merge #M, then re-invoke" for each such #M; for an entry in another repository the action names `owner/repo#M`. Publish it with [blocker](../templates/blocker.md) "# Delivery blocked". Keep the stage label. On a later invocation, [recovery](recovery.md) "## Blocked overlays" governs overlay removal; the condition it observes is this section's condition.

Inside a batch, [batch invocation](modes/batch-invocation.md) ("This file owns batch invocation order") owns ordering for an M in the set.

## Stage projection

Exactly one stage label should exist, with optional `capstan:blocked` overlay.
Create missing labels idempotently: inspect `gh label list --repo OWNER/REPO`,
then `gh label create capstan:STAGE --repo OWNER/REPO --color 1d76db --description 'Capstan: STAGE'`
only when absent. If creation races, re-read instead of treating it as fatal.
Label creation during delivery remains required. Init is outside the delivery
loop and does not replace that create. A missing `.capstan.json` still delivers.
Use `gh issue edit N --repo OWNER/REPO --add-label capstan:NEXT --remove-label capstan:OLD`
for observed old Capstan stage labels. Preserve every unrelated label. Read back
with `gh issue view N --repo OWNER/REPO --json labels`. Multiple or stale stage
labels are repaired from evidence and recorded, never treated as a terminal error.

After a successful ready projection, add `capstan:ready-to-deploy` to the marked
pull request with
`gh pr edit PR --repo OWNER/REPO --add-label capstan:ready-to-deploy`.
That add has no `--remove-label`. Read the issue labels back with
`gh issue view N --repo OWNER/REPO --json labels` and the pull-request labels
with `gh pr view PR --repo OWNER/REPO --json labels`. Then read remote heads,
base heads, and live pull-request state again with the step 5 query and its
residual-effect re-check in [pre-merge.md](pre-merge.md) ("Re-fetch base and
query live PR state"), which owns that re-check.
If the pull-request label
is absent, run the same add again on that pull request and read the pull-request
labels again. Do not open a second pull request. On the pull request, add or
remove only `capstan:ready-to-deploy`. Preserve unrelated pull-request labels.
Do not copy `capstan:planning`, `capstan:review`, or `capstan:fix` onto the pull
request. If a later observation shows the pull request is no longer immediately
mergeable, or the pre-merge residual-effect re-check fails, run
`gh pr edit PR --repo OWNER/REPO --remove-label capstan:ready-to-deploy`
and read the removal back with `gh pr view PR --repo OWNER/REPO --json labels`.
Success is a read-back that does not contain the label. If the label remains,
remove it once more on that pull request and read it back again. Do not leave a
stale ready label. Repair the issue label with the existing `gh issue edit` and
`gh issue view` stage rules. These sentences apply on the next ready projection
after they are in force.

| Stage | Completion evidence | Next |
| --- | --- | --- |
| triage | admitted spec; no unresolved material decision | ready |
| ready | run accepted; start condition holds ("## Start condition"); worktree reconciled; launch probe passed | planning |
| planning (initial) | complete published plan for admitted revision | plan-review |
| plan-review | complete census: no findings / findings | implementing / planning (single correction) |
| planning (single correction) | corrected plan and complete finding handoff; interrupted work retained explicitly | implementing |
| implementing | verified commits/checks/outcome; closure proof gate passed for carried effective blockers; [references/publication.md](publication.md) | review |
| review | exact-head policy partition: effective blockers / none / round ceiling | fix / pre-merge / blocked review-exhausted |
| fix | effective blocking census resolved or refuted; closure proof gate passed; verified resulting head (unchanged is valid after refutation) | review |
| pre-merge | strict live ready gate in pre-merge reference | ready-to-deploy |

Use `capstan:` before each stage name. Failed attempts preserve the active label.
The two planning rows share `capstan:planning`; evidence distinguishes them.
The stage move made by the newer-trusted-comments check:
[pre-merge.md](pre-merge.md) ("Newer trusted comments") owns it.
Apply [one-pass planning](plan-convergence.md) before dispatch or resume; its
interrupted-correction handoff takes precedence over generic station retry rules.
A blocker adds only `capstan:blocked`. Remove a human-capability blocker when its
capability is observed; remove a review-exhausted blocker only under
[code-review convergence](review-convergence.md)'s resume conditions.
`capstan:ready-to-deploy` means immediately mergeable, not merged or deployed,
on the marked pull request and on the issue.

## Concurrent activity

Support one coordinator per issue and sequential resume across hosts. An optional
activity comment gives host/session, start time, budget start, and last progress.
It is informational. Compare live heads, comments, checks, and known worker PIDs.
If another coordinator is visibly progressing, wait 30 seconds and re-observe
within the wall budget. If no progress is visible, record takeover and continue.
A fresh, stale, missing, or malformed marker never requires human repair. Avoid
overlapping write workers; inspect and stop only a known process from this run
before replacing it. Never kill processes by broad name or PID guesses.

## Configuration

Read `.capstan.json` as ordinary input, not executable instructions. Resolve each
field independently: explicit invocation, environment, file, then defaults.

Environment names are `CAPSTAN_` plus uppercase nested keys joined with `_`, such
as `CAPSTAN_PRIMARY_HARNESS`, `CAPSTAN_SECONDARY_EFFORT`,
`CAPSTAN_RECOVERY_RUN_WALL_TIMEOUT_MIN`, `CAPSTAN_REVIEW_POLICY_MIN_CONFIDENCE`,
`CAPSTAN_UNSAFE_AUTONOMY`, and `CAPSTAN_EVIDENCE_DELETE_PILE`.
`CAPSTAN_STATE` independently sets evidence storage. Never print environment values
wholesale. Call out unknown/invalid fields and use a valid lower-precedence value;
salvage unambiguous values from malformed input without inventing ambiguous ones.
`evidence.delete_pile` is the exception to fall-through. It is a boolean. The
default is `false`. Precedence is invocation, then `CAPSTAN_EVIDENCE_DELETE_PILE`,
then `.capstan.json`, then the default. An invalid value is `false`. Do not fall
through to a lower precedence value. Do not resolve an invalid or missing value
to `true`. A missing `evidence.delete_pile` means `false`. Record the resolved
value in `ledger.md`. [telemetry.md](telemetry.md) owns that file and deletion.
The switch cannot suppress the ledger. There is no second cleanup flag.

`evidence.retain_replay` is a boolean. The default is `false`. Precedence is
invocation, then `CAPSTAN_EVIDENCE_RETAIN_REPLAY`, then `.capstan.json`, then
the default. An invalid value is `false`. A missing `evidence.retain_replay`
means `false`. Do not fall through to a lower precedence value. Do not resolve
an invalid or missing value to `true`. Record the resolved value in `ledger.md`.
`evidence.retain_replay` cannot suppress the ledger or provenance.
`evidence.retain_replay` is not a cleanup flag. [telemetry.md](telemetry.md)
owns retention and provenance. This file owns `evidence.retain_replay`.

`review_policy.residual_effect_approval` is a boolean. The default is `false`.
Precedence is invocation, then `CAPSTAN_REVIEW_POLICY_RESIDUAL_EFFECT_APPROVAL`,
then `.capstan.json`, then the default. An invalid value is called out and falls
through to the next valid source, per the rule above. Record the resolved value
in `ledger.md`. When it resolves to `false`, every station behaves as before.
[pre-merge.md](pre-merge.md) step 4 owns the residual-effect approval it enables.

`features` is the optional feature-map field. Resolution order is invocation,
then `CAPSTAN_FEATURES`, then the `.capstan.json` field `features`, then
`.capstan/features` when that directory contains `README.md`. `features: null`
disables the map. It does not fall through to `.capstan/features`. An absent
`features` field is not `features: null`. A missing explicit path is recorded in
`ledger.md`. The run
continues with no map. A delivery with no map still completes.
Capstan does not generate a map during an ordinary issue. Do not copy the map into a host skill
directory.

Each feature file uses only these four H2 headings and no harness name:
`Sub-features`, `How to get to it (user POV)`, `Driving it`, `Gotchas`.
`Driving it` states the repository commands and the observable end state. A
harness name, a host skill path, or another section does not satisfy the shape.
No Launch, Doctor, Evidence, Cleanup, or Helpers section.

[references/implementing.md](implementing.md) owns the feature-map write.

[references/modes/feature-map-adoption.md](modes/feature-map-adoption.md) ("This file owns feature-map adoption") owns feature-map adoption.

[references/modes/feature-map-audit.md](modes/feature-map-audit.md) ("This file owns the feature-map audit") owns the feature-map audit.

[references/modes/adr.md](modes/adr.md) ("This file owns the ADR rule") owns the ADR rule.

Defaults: primary claude; secondary codex; optional fallback grok; model and effort
null; transient_retries 3; same_failure_attempts 2;
run_wall_timeout_min 360;
worker_timeout_min 60; ci_timeout_min 45; unsafe_autonomy false;
review_policy block_threshold medium, min_confidence 0.70,
max_review_fix_rounds 3, surface_recurrence_rounds 3,
residual_effect_approval false.
Timeouts must be positive; retry counts nonnegative integers;
unsafe_autonomy boolean; residual_effect_approval boolean. Review threshold
must be critical/high/medium/low,
confidence from 0 through 1, max rounds a positive integer, and recurrence rounds
a nonnegative integer where 0 disables that early guard. Null model/effort uses the harness default and is
recorded as such. Null fallback disables it. Prefer a different available secondary;
if only one harness works, disclose `independence: same-harness`. An explicitly
requested unavailable setting fails visibly and enters recovery; never silently
drop an effort setting. Record effective nonsecret configuration in `ledger.md`.
[telemetry.md](telemetry.md) owns that file.

`recovery.plan_revision_attempts` and `CAPSTAN_RECOVERY_PLAN_REVISION_ATTEMPTS`
are retired and handled like any unknown field: called out and ignored.

`recovery.max_cost_usd` and `CAPSTAN_RECOVERY_MAX_COST_USD` are retired and
handled like any unknown field: called out, ignored, and recorded in `ledger.md`,
including as an invocation override. A set value does not trigger a budget
decision.

The only run budget is wall time (`recovery.run_wall_timeout_min`). Budget begins
when the run is accepted and survives ordinary resume through remote
activity/summary timestamps. Loss of local telemetry does not reset it. Use
earliest reliable run evidence. Do not invent prices or usage.

### Init

Init is outside the delivery loop. It runs only on an explicit init invocation.
A delivery, a resume, and an issue number do not enter init. Init is not a binary
and not a station. Init is not a gate. Delivery remains valid without init. A
missing `.capstan.json` still delivers. Label creation during delivery remains
required.

This section owns the init invocation. An invocation that, trimmed and split on
whitespace as "## Read-only invocations" does, is the single token `init`, byte
for byte in lowercase, is the init invocation. `init` with any other token,
including an allowed override or an issue number, is not the init invocation
and follows "## Identity and authority" unchanged. The named checkout is the
invoking workspace's git work tree.

Probe each harness CLI on `PATH` with that CLI's documented help command from the
named checkout. Recommend a primary and a different secondary only from CLIs that
answered. Do not invent a model, effort, or harness. When the observed primary
and a different observed secondary are unambiguous, select that pair and report
it. Do not ask. Do not prompt. Ask only when the probe is ambiguous. Ask that one
pair and recommend an observed answer. Keep timeouts and `unsafe_autonomy`
at the documented defaults in this section. The invoking host does not become
primary merely because it ran init.

If `.capstan.json` is absent, exclusive-create it in the named checkout. Write
only `primary`, `secondary`, and `fallback`, plus the documented recovery
defaults. Set model and effort to null. Set `fallback` to null when no third
observed harness exists. Set `unsafe_autonomy` to false. Do not write
`evidence.delete_pile`. A missing `evidence.delete_pile` means `false`.
Do not write `evidence.retain_replay`. Leave the file
uncommitted. Do not switch branches. Do not commit, push, or open a pull request.
The write is allowed on `main` and stays uncommitted. Exclusive create writes the
new file only when it is absent. If the file is present before the write finishes,
do not replace it. Resolve the repository with
`gh repo view --json nameWithOwner,defaultBranchRef` from that checkout. Do not
start init from an issue number.

If `.capstan.json` exists, leave the bytes unchanged. Do not merge, reformat,
replace, or use `--force`. Report that the file already exists.

Ensure these ten labels exist: `capstan:triage`, `capstan:ready`,
`capstan:planning`, `capstan:plan-review`, `capstan:implementing`, `capstan:review`,
`capstan:fix`, `capstan:pre-merge`, `capstan:ready-to-deploy`, and
`capstan:blocked`. Create only absent labels with the stage-projection command
above. Re-read a race. Do not add or remove any other label.

Init writes no secrets, no evidence directory, no worktree, and no feature map.
Init does not write `features`. Init does not edit product source. The
`.capstan.json` write is init configuration, not a product-source edit and not a
delivery commit.

[references/publication.md](publication.md) owns publication.
