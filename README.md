# Capstan

Issue in, merge-ready PR out. One coordinator works with fresh headless workers,
records evidence, and recovers from technical failures. `capstan:ready-to-deploy`
means an open PR that GitHub says can merge immediately. Capstan never merges or
deploys.

The product is Markdown. There is no executable controller, installer, state
database, wrapper, or external skill dependency. The coordinator reads GitHub/git
facts and uses existing CLIs. Local evidence and labels help resume; they cannot
overrule current facts.

## Install and invoke

Prerequisites: git, authenticated gh with repository write access, and configured
harness CLIs on PATH. A delivery uses a primary and a fresh secondary; another
harness is preferred for independent judgment. Read the trust boundary below.

Copy or symlink this entire directory into a host's skill directory. For example,
with an absolute path to a reviewed checkout:

```sh
mkdir -p "$HOME/.agents/skills"
ln -s /absolute/path/to/capstan "$HOME/.agents/skills/capstan"
```

Inspect an existing destination first; do not replace another installation blindly.
Use a stable reviewed checkout or copy, not a branch being edited during a run.
The canonical `.agents/skills` location is shared by compatible hosts. Host-specific
alternatives and explicit invocation forms are:

| Host | User skill directory | Invocation |
| --- | --- | --- |
| Claude Code | `~/.claude/skills/capstan/` | `/capstan https://github.com/OWNER/REPO/issues/N` |
| Codex CLI | `~/.agents/skills/capstan/` | `$capstan https://github.com/OWNER/REPO/issues/N` |
| Grok Build | `~/.grok/skills/capstan/` | `/capstan https://github.com/OWNER/REPO/issues/N` |
| Oh My Pi | `~/.agents/skills/capstan/` | `/skill:capstan https://github.com/OWNER/REPO/issues/N` |

Restart the host or use its documented reload after installation. Confirm Capstan
appears in its explicit skill menu. Frontmatter disables model invocation; Codex
also receives `policy.allow_implicit_invocation: false` presentation metadata.
If a host version ignores invocation metadata, do not claim automatic invocation
is disabled: verify discovery behavior before using that version. Official discovery
references: [Codex](https://learn.chatgpt.com/docs/build-skills),
[Grok](https://docs.x.ai/build/features/skills-plugins-marketplaces),
[OMP](https://github.com/can1357/oh-my-pi/blob/main/docs/skills.md).

The same invocation resumes. Issue-title changes do not change branch `capstan/N`,
worktree `.worktrees/capstan+N`, or marked PR lookup. You may specify overrides in
the invocation, for example: “primary codex, secondary claude, wall budget 90 minutes.”
Only one coordinator should work on an issue at a time.

## Configuration

Optional `.capstan.json` in the target repository:

```json
{
  "primary": {"harness": "claude", "model": null, "effort": null},
  "secondary": {"harness": "codex", "model": null, "effort": null},
  "fallback": {"harness": "grok", "model": null, "effort": null},
  "recovery": {
    "transient_retries": 3,
    "same_failure_attempts": 2,
    "plan_revision_attempts": 2,
    "run_wall_timeout_min": 360,
    "max_cost_usd": null
  },
  "worker_timeout_min": 60,
  "ci_timeout_min": 45,
  "unsafe_autonomy": false
}
```

The coordinator interprets each value. Precedence is invocation, environment,
file, defaults. Environment keys use uppercase paths joined by underscores, such
as `CAPSTAN_PRIMARY_HARNESS` or `CAPSTAN_RECOVERY_RUN_WALL_TIMEOUT_MIN`.
Unknown/malformed values are called out and ignored individually. Model/effort
null uses the harness default; unsupported explicit effort fails visibly.
`fallback: null` disables fallback. `CAPSTAN_STATE` overrides evidence storage.

Read [contract](references/contract.md) for field rules and
[harnesses](references/harnesses.md) for version-checked launch guidance. No parser
is installed. A cost cap needs measurable reported cost; otherwise the coordinator
asks for a usable budget decision rather than inventing usage.

Reviews independently verify each finding against its original failure scenario
and acceptance condition, retaining unresolved/new lineage. Planning allows two
ordinary revisions by default, then escalates to independent diagnosis and a
different repair strategy within the same run budget. The limit never approves
or blocks an issue automatically. See [finding resolution](references/findings.md)
and [plan convergence](references/plan-convergence.md); use
`CAPSTAN_RECOVERY_PLAN_REVISION_ATTEMPTS` to override the revision limit.

## Trust and authority

Use repositories you control and trusted collaborators' issues. OWNER, MEMBER,
and COLLABORATOR content is trusted; other issue authors require confirmation and
untrusted comments are excluded by default. A worktree is not a security sandbox.
Host permissions and repository instructions still apply.

The coordinator may push its branch, create/update its PR and issue artifacts,
change Capstan labels, and rerun eligible CI. Workers may edit/commit only their
worktree at write stations. Human commits are preserved; published branches are
never force-pushed. Missing credentials, permissions, purchase decisions, required
approvals, consequential product choices, and budget decisions produce one typed
human action. Tests, code defects, conflicts, and CI diagnosis remain agent work.

Unsafe permission-bypass mode requires explicit user configuration and appears
in the final report. Default mode retains each host's strongest supported scoped
protection. No hostile-input sandbox or distributed lock is provided in v1.

## Evidence and cleanup

Evidence defaults to `${XDG_STATE_HOME:-$HOME/.local/state}/capstan/OWNER/REPO/N/`.
Owner-only briefs, results, worker/check logs, run.md, and optional events.jsonl
record observed commands and usage. Secrets are redacted before persistence or
publication. Missing usage is unknown, never estimated.

To clean raw logs manually, first resolve the exact delivery directory, inspect
its contents, and confirm no worker is active. Archive it or remove only the
selected files using your normal file manager. Keep remote marked evidence for
resume. There is no automatic deletion job, and losing local evidence must not
prevent delivery continuation.

## Development and provenance

Acceptance is established in a separate fixture repository, never loaded at
runtime. A releasable revision needs a live ready-to-ready-to-deploy journey with
zero human requests, recovery exercises, and two interactive-host smoke runs.
Help checks and document validation alone do not meet that bar.

Historical ideas came from ponytail, firstmate, Matt Pocock's skills, and pstack.
This attribution is provenance only. All shipped instructions are Capstan-owned;
no third-party skill is installed, copied, invoked, or needed. MIT licensed.
