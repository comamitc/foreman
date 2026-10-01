# Capstan

Issue in, merge-ready PR out. One coordinator works with fresh headless workers,
records evidence, and recovers from technical failures. `capstan:ready-to-deploy`
means an open PR that GitHub says can merge immediately. Capstan never merges or
deploys.

The product is Markdown. Capstan's own behavior is a skill procedure executed
by the coordinator. A Capstan executable, parser, or controller is forbidden
unless an admitted issue records the exception. Issue #181 records one: the
launch builder `scripts/launch.sh` and its test script `scripts/test-launch.sh`,
run with `bash` by the coordinator. There is no installer or wrapper. The coordinator reads GitHub/git facts. Local evidence and labels help
resume; they cannot overrule current facts.

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

Install is this directory symlinked or copied into the host skill path already
listed. Capstan does not ship a marketplace manifest or a converter.

Restart the host or use its documented reload after installation. Confirm Capstan
appears in its explicit skill menu. Frontmatter disables model invocation; Codex
also receives `policy.allow_implicit_invocation: false` presentation metadata.
If a host version ignores invocation metadata, do not claim automatic invocation
is disabled: verify discovery behavior before using that version. Official discovery
references: [Codex](https://learn.chatgpt.com/docs/build-skills),
[Grok](https://docs.x.ai/build/features/skills-plugins-marketplaces),
[OMP](https://github.com/can1357/oh-my-pi/blob/main/docs/skills.md).

### Compatibility with host instructions

The completion endpoint is a verified open merge-ready PR. Capstan does not deploy. A fresh task inspects and resolves the base, fetches that branch, records the SHA, and creates the worktree before product edits. [contract](references/contract.md) owns that order, the host exceptions, and the rule that a host or user instruction file does not change a Capstan delivery's completion endpoint or its fetch-then-worktree order. This section adds no installer and no precedence system.

The same invocation resumes. Issue-title changes do not change branch `capstan/N`,
worktree `.worktrees/capstan+N`, or marked PR lookup. You may specify overrides in
the invocation, for example: “primary codex, secondary claude, wall budget 90 minutes.”
Only one coordinator should work on an issue at a time. These delivery forms do not
enter init.
The invocation `status` alone, for example `/capstan status`, prints a read-only report of this repository's open issues that carry a Capstan stage label or the `capstan:blocked` overlay, and changes nothing. `status` with other words is a text invocation.

### Text invocation

[contract](references/contract.md) owns text intake.

Feature-map adoption. The issue or the text invocation states that the outcome
is feature-map adoption. A normal feature delivery does not enter it.

Documentation backfill. The issue or the text invocation states that the
outcome is documentation backfill, and it names the audience and the workflow.
A normal feature delivery, init, or resume does not enter it.

Incremental maintenance. A normal feature delivery corrects a canonical page
in the same commit when that delivery makes a public statement false. It does
not enter documentation backfill. It does not require a feature map. It is not
lesson maintenance.

Feature-map audit. The issue or the text invocation states that the outcome is
an audit of the configured feature map. An absent or disabled map (`features`
null or absent) produces a no-map result. The audit does not seed a map.

Verification-path adoption. The issue or the text invocation states that the
outcome is verification-path adoption, and it names the target repository and
one user operation. A normal feature delivery, init, or resume does not enter it.

Optional map. A configured `features` path may link to a canonical page. The
map is not a second copy of that page. No map does not block documentation
backfill, and backfill does not seed a map.

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
    "run_wall_timeout_min": 360
  },
  "review_policy": {
    "block_threshold": "medium",
    "min_confidence": 0.7,
    "max_review_fix_rounds": 3,
    "surface_recurrence_rounds": 3
  },
  "worker_timeout_min": 60,
  "ci_timeout_min": 45,
  "unsafe_autonomy": false,
  "evidence": {
    "delete_pile": false
  },
  "features": null
}
```

The coordinator interprets each value. Precedence is invocation, environment,
file, defaults. Environment keys use uppercase paths joined by underscores, such
as `CAPSTAN_PRIMARY_HARNESS` or `CAPSTAN_RECOVERY_RUN_WALL_TIMEOUT_MIN`.
Unknown/malformed values are called out and ignored individually. Review findings
block only when they meet both the configured severity and confidence floors;
other supported findings remain visible as advisory. Model/effort
null uses the harness default; unsupported explicit effort fails visibly.
`fallback: null` disables fallback. `CAPSTAN_STATE` overrides evidence storage.
[contract](references/contract.md) owns `evidence.delete_pile`. [telemetry](references/telemetry.md) owns the ledger and deletion.

[contract](references/contract.md) owns feature-map resolution and heading shape.

Read [contract](references/contract.md) for field rules and
[harnesses](references/harnesses.md) for version-checked launch guidance.
Capstan does not capture cost. The only run budget is wall time; [contract](references/contract.md) owns it and the retired cost fields. The coordinator never invents prices or usage.

Planning follows one fixed sequence: initial plan, independent review, one
correction pass addressing the entire feedback set, then implementation. A review
with no actionable findings skips correction. There is no second plan-review.
All findings carry into implementation and independent code review; correcting
the plan does not verify the code. Only an actual missing prerequisite or budget
decision stops safe implementation. See [one-pass planning](references/plan-convergence.md)
and [finding resolution](references/findings.md).

Before a repaired candidate is pushed for review, every carried effective blocker must
pass a coordinator-verified closure proof: the original scenario is red at the
reviewed head, green at the candidate head, and the regression check demonstrably
bites when the defect is present. A passing suite or an “addressed” table is not
closure. Missing proof stays in the current write station instead of consuming a
secondary review to rediscover incomplete work. A repeated scenario keeps its
original lineage and triggers independent diagnosis plus a different repair
hypothesis; only a distinct failure scenario is new.

Code re-review is a ratchet, not a fresh unlimited scan: it verifies prior blockers
and the repair delta. Complete review censuses are capped by
`review_policy.max_review_fix_rounds`. If effective blockers remain at the ceiling,
Capstan adds `capstan:blocked` with reason `review-exhausted`; it never marks the PR
ready or silently discards them. See
[code-review convergence](references/review-convergence.md).

## Init

[contract](references/contract.md) owns init.

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
Owner-only briefs, results, worker/check logs, and optional events.jsonl
record observed commands and usage. Secrets are redacted before persistence or
publication. [references/telemetry.md](references/telemetry.md) owns the ledger,
the pile, deletion, and missing-usage rules.
[references/contract.md](references/contract.md) owns `evidence.delete_pile`.

To clean raw logs manually before ready-to-deploy, first resolve the exact
delivery directory, inspect its contents, and confirm no worker is active.
Archive it or remove only the selected files using your normal file manager.
Keep remote marked evidence for resume. Losing local evidence before
ready-to-deploy must not prevent delivery continuation.

## Development and provenance

Acceptance is the product pipeline: planning → implementing → independent review → merged-ready PR gate.
Reviewer evidence on the diff is the proof.

Historical ideas came from ponytail, firstmate, Matt Pocock's skills, and pstack.
This attribution is provenance only. All shipped instructions are Capstan-owned;
no third-party skill is installed, copied, invoked, or needed. MIT licensed.

[references/publication.md](references/publication.md) owns publication.
