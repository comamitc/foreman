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
enter init and does not run init. No executable, parser, or controller.

The create-time title is the provisional title. It is the first non-empty line of the preserved original request, at most 256 characters. On the `gh issue edit` that publishes the admitted spec, pass `--title` only when the live title still equals that provisional title and the Problem cut is non-empty. If the live title does not equal that provisional title, omit `--title`. If the live title equals that provisional title and the Problem cut is empty, omit `--title` and still publish the spec body. A title a person already changed stays as it is. An issue opened by URL or number uses this same comparison. Do not add a marker kind. Do not read the surrounding transcript.

When `--title` is set, its value is the first sentence of the admitted Problem section. Use the Problem body under that heading and before the next heading. Use the first non-empty paragraph. A paragraph is a maximal run of non-blank lines. If the Problem body has no such paragraph, the cut is empty. If the paragraph contains `.`, `!`, or `?`, keep the text through the first of those characters. If it does not, keep the paragraph. Trim each kept line, drop a line that becomes empty, and join the remaining lines with one space. Trim the ends. If the result is longer than 256 characters, keep the first 256 characters. If the result is empty, omit `--title` on that same publishing edit. Still publish the spec body. The empty cut is not a successful title write. Record the empty cut in the publication record that triage step 5 already requires. Do not send an empty title. Do not send `--title` on a later edit.

Read the title back after that edit. If `--title` was sent, the read-back title must equal the sent title. If `--title` was omitted, the read-back title must equal the live title from before the edit. A mismatch is not a successful publish. An empty cut is not a reason to skip the spec publish. Do not send a second edit to change the title.

[references/recovery.md](recovery.md) owns blocked-overlay removal.

Capstan's own behavior is a skill procedure executed by the coordinator. A
Capstan executable, parser, or controller is forbidden unless an admitted issue
records the exception. A Capstan init binary would violate this rule, not an
implementation choice. The rule does not apply to a target repository unless
that repository is Capstan. A delivery reads the target repository's own
conventions. It does not import this rule into that repository. Permit only
`git`, `gh`, existing harness CLIs, and a target repository's own CLI. A
Capstan executable, parser, or controller stays forbidden unless an admitted
issue records the exception. Do not permit the class "an installed CLI."

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
Before creating `capstan/N`, run `git fetch origin <resolved-base>` so `origin/<resolved-base>` is updated in this run. For this repository that command is `git fetch origin main`. Immediately after a successful fetch, record the SHA of that ref. Create the worktree from that SHA. Local `main`, an unfetched `origin/main`, and `origin/HEAD` are not valid parents. If the fetch fails, stop. Do not create the worktree from local `main`. An existing `capstan/N` worktree is not rebased or recreated. Do not fast-forward, switch, or edit the shared checkout.
When absent, create it with `git worktree add -b capstan/N ./.worktrees/capstan+N origin/BASE`
from the repository root after fetching and resolving BASE. Its parent is the recorded SHA, not the ref name alone. If a matching branch
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
5. Available local briefs, results, logs, and telemetry. Recreate missing evidence
   directories and briefs from remote facts; missing files cannot strand a run.

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
with `gh pr view PR --repo OWNER/REPO --json labels`. If the pull-request label
is absent, run the same add again on that pull request and read the pull-request
labels again. Do not open a second pull request. On the pull request, add or
remove only `capstan:ready-to-deploy`. Preserve unrelated pull-request labels.
Do not copy `capstan:planning`, `capstan:review`, or `capstan:fix` onto the pull
request. If a later observation shows the pull request is no longer immediately
mergeable, run
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
| ready | run accepted; worktree reconciled | planning |
| planning (initial) | complete published plan for admitted revision | plan-review |
| plan-review | complete census: no findings / findings | implementing / planning (single correction) |
| planning (single correction) | corrected plan and complete finding handoff; interrupted work retained explicitly | implementing |
| implementing | verified commits/checks/outcome; closure proof gate passed for carried effective blockers; [references/publication.md](publication.md) | review |
| review | exact-head policy partition: effective blockers / none / round ceiling | fix / pre-merge / blocked review-exhausted |
| fix | effective blocking census resolved or refuted; closure proof gate passed; verified resulting head (unchanged is valid after refutation) | review |
| pre-merge | strict live ready gate in pre-merge reference | ready-to-deploy |

Use `capstan:` before each stage name. Failed attempts preserve the active label.
The two planning rows share `capstan:planning`; evidence distinguishes them.
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
Capstan's own behavior is a skill procedure executed by the coordinator. A
Capstan executable, parser, or controller is forbidden unless an admitted issue
records the exception. A Capstan init binary would violate this rule, not an
implementation choice. The rule does not apply to a target repository unless
that repository is Capstan. Permit only `git`, `gh`, existing harness CLIs, and
a target repository's own CLI. A Capstan executable, parser, or controller stays
forbidden unless an admitted issue records the exception. Do not permit the
class "an installed CLI."

Environment names are `CAPSTAN_` plus uppercase nested keys joined with `_`, such
as `CAPSTAN_PRIMARY_HARNESS`, `CAPSTAN_SECONDARY_EFFORT`,
`CAPSTAN_RECOVERY_RUN_WALL_TIMEOUT_MIN`, `CAPSTAN_REVIEW_POLICY_MIN_CONFIDENCE`,
and `CAPSTAN_UNSAFE_AUTONOMY`.
`CAPSTAN_STATE` independently sets evidence storage. Never print environment values
wholesale. Call out unknown/invalid fields and use a valid lower-precedence value;
salvage unambiguous values from malformed input without inventing ambiguous ones.

`features` is the optional feature-map field. Resolution order is invocation,
then `CAPSTAN_FEATURES`, then the `.capstan.json` field `features`, then
`.capstan/features` when that directory contains `README.md`. `features: null`
disables the map. It does not fall through to `.capstan/features`. An absent
`features` field is not `features: null`. A missing explicit path is recorded in
`run.md`. The run continues with no map. A delivery with no map still completes.
Capstan does not generate a map during an ordinary issue. Do not add a stage, a
label, or a daily job for the map. Do not copy the map into a host skill
directory.

Each feature file uses only these four H2 headings and no harness name:
`Sub-features`, `How to get to it (user POV)`, `Driving it`, `Gotchas`.
`Driving it` states the repository commands and the observable end state. A
harness name, a host skill path, or another section does not satisfy the shape.
No Launch, Doctor, Evidence, Cleanup, or Helpers section.

[references/implementing.md](implementing.md) owns the feature-map write.

Defaults: primary claude; secondary codex; optional fallback grok; model and effort
null; transient_retries 3; same_failure_attempts 2;
run_wall_timeout_min 360;
max_cost_usd null; worker_timeout_min 60; ci_timeout_min 45; unsafe_autonomy false;
review_policy block_threshold medium, min_confidence 0.70,
max_review_fix_rounds 3, surface_recurrence_rounds 3.
Timeouts must be positive; retry counts nonnegative integers; cost positive or
null; unsafe_autonomy boolean. Review threshold must be critical/high/medium/low,
confidence from 0 through 1, max rounds a positive integer, and recurrence rounds
a nonnegative integer where 0 disables that early guard. Null model/effort uses the harness default and is
recorded as such. Null fallback disables it. Prefer a different available secondary;
if only one harness works, disclose `independence: same-harness`. An explicitly
requested unavailable setting fails visibly and enters recovery; never silently
drop an effort setting. Record effective nonsecret configuration in run.md.

`recovery.plan_revision_attempts` and `CAPSTAN_RECOVERY_PLAN_REVISION_ATTEMPTS`
are retired. Warn and ignore them, including invocation overrides; they cannot
skip the correction or enable additional cycles. The one-pass sequence is fixed,
not a configurable retry allowance. Other recovery settings remain unchanged.

Budget begins when the run is accepted and survives ordinary resume through
remote activity/summary timestamps. Loss of local telemetry does not reset it.
Use earliest reliable run evidence; unknown cost remains unknown. If a configured
cost limit cannot be measured, request a budget decision before unbounded spending;
offer the measurable wall budget. Do not invent prices or usage.

### Init

Init is outside the delivery loop. It runs only on an explicit init invocation.
A delivery, a resume, and an issue number do not enter init. Init is not a binary
and not a station. Init is not a gate. Delivery remains valid without init. A
missing `.capstan.json` still delivers. Label creation during delivery remains
required. A Capstan init binary would violate this rule, not an implementation
choice.

Probe each harness CLI on `PATH` with that CLI's documented help command from the
named checkout. Recommend a primary and a different secondary only from CLIs that
answered. Do not invent a model, effort, or harness. When the observed primary
and a different observed secondary are unambiguous, select that pair and report
it. Do not ask. Do not prompt. Ask only when the probe is ambiguous. Ask that one
pair and recommend an observed answer. Keep timeouts, cost, and `unsafe_autonomy`
at the documented defaults in this section. The invoking host does not become
primary merely because it ran init.

If `.capstan.json` is absent, exclusive-create it in the named checkout. Write
only `primary`, `secondary`, and `fallback`, plus the documented recovery
defaults. Set model and effort to null. Set `fallback` to null when no third
observed harness exists. Set `unsafe_autonomy` to false. Leave the file
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
