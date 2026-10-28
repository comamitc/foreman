# Recovery inside the active station

A failed attempt supplies evidence for recovery, not by itself a human blocker.
For planning and plan-review, [one-pass planning](plan-convergence.md) takes
precedence over all generic retry, corrective-prompt, diagnosis, and fallback
rules below. They cannot create another correction or second plan review.
Technical diagnosis/repair of carried findings belongs in implementing. Elsewhere,
preserve the active stage while recovering.

## Observe, diagnose, retry

1. Observe possible side effects before repeating anything. Inspect worktree,
   commits, known process/session, result file, remote branch, PR, comments, checks,
   and rerun attempts. Timeout or malformed output does not prove an action failed.
   Preserve completed work and brief only the unfinished portion.
2. Record station, head, failed command/check and exit, redacted raw error, open
   findings, worker outcome, and evidence paths. Compare semantically with prior
   attempts using original failure scenarios and acceptance conditions. A changed
   head, error, finding ID/count, or plan length alone is not progress; cite the
   newly satisfied condition or eliminated cause. Explain this comparison in
   run.md. Verified progress resets the same-failure count, not the total run
   budget or the consumed single planning correction.
3. Choose the smallest response supported by evidence:

   | Condition | Response |
   | --- | --- |
   | network/rate limit/temporary GitHub failure | use resolved transient_retries (default 3), 5/15/30 second backoff then 30 seconds for additional configured retries, honoring longer server guidance within budget |
   | crash/timeout | inspect effects and live processes; fresh worker for unfinished work |
   | failed launch probe | no station worker launches and the run does not advance until a re-probe or a recovery-selected fallback's probe passes; diagnosis only under a recipe whose probe passed in this invocation ([launch probe](harnesses/shared.md)) |
   | missing/weak/malformed result | precise corrective feedback, up to 2 corrective prompts, then a fresh worker |
   | failed behavior/test/type/lint/build | primary repairs using original command/logs, diff, spec and plan; rerun under [references/planning.md](planning.md) ("Mark each declared check heavy or not heavy") |
   | unknown technical failure | fresh diagnosis worker; unknown does not mean human-required |
   | resolved same_failure_attempts reached (default 2) | fresh secondary independent diagnosis, then fresh primary repair |
   | same failure after diagnosis and repair | one configured fallback attempt per original failure scenario per run; if unavailable or already attempted, fresh primary with a materially different hypothesis |
   | actionable plan findings | single correction against the complete census, then implementing with every obligation; apply plan-convergence.md |
   | actionable code review findings | bounded review/fix loop with review-convergence.md partitioning, findings.md reconciliation, and the pre-push closure proof gate |
   | recurrent/reopened scenario after a claimed fix | record the insufficient red/green/bite proof, obtain fresh secondary diagnosis, then use a materially different primary repair hypothesis |
   | conflicts/CI | pre-merge reference's ordered recovery |
   | telemetry/local artifact/helper failure | recreate from remote evidence or use direct existing CLI; note the gap |
   | denied coordinator step | "## Denied coordinator step" below; no other row applies |

4. Re-observe and verify the original completion criterion after repair. Continue
   with new evidence, another hypothesis, or independent diagnosis while budget
   remains. Exhausting transient retries is a diagnosis point, not permission to
   misclassify an outage as a product decision. Keep waits supervised and bounded.
5. At the total wall-time budget, request only more time, an admitted scope
   change, or cancellation. Never request human diagnosis or repair of a
   technical error.

Deliver corrective feedback to the current worker only if its session is still
reachable through an installed, help-verified continuation interface. Otherwise
start a fresh worker carrying the prior result and precise feedback; missing resume
support is not a blocker. Each new station and independent judgment starts fresh.
Do not launch a second writer while a prior writer is alive.

## Denied coordinator step

A denied coordinator step is a host permission refusal to run a coordinator command, such as an auto-mode classifier denial. A GitHub API error from a command that ran is not a denied step; it follows "## Observe, diagnose, retry". [Claude adapter](harnesses/claude.md) ("## Claude Code host") owns the host's read forms.

1. A denied read is retried once in the other form: the host's file-read tool for a local file, or the plain `gh` read with no redirect for GitHub. A read that was already in that form is retried once in that same form. A second denial follows step 2.
2. For a denied GitHub write, or a read still denied after step 1, record the denial as a ledger row ([telemetry](telemetry.md) ("This file owns the attempt table.")). Do not rerun the command in this invocation. Do not route the step through another command or another surface, such as an issue comment, a pull request, or `gh api`. Publish a `permission-required` blocker as "## Blocked overlays" states, with [blocker](../templates/blocker.md) ("# Delivery blocked"), naming the exact command. Its action asks the person to allow or approve that command in the host and then re-invoke. Its resume condition is that command running and reading back. The delivery stops.
3. When the blocker comment itself is denied, report the blocker locally and in the host session, and the delivery stops. A denial is not unavailable GitHub access.
4. On a later invocation, "## Blocked overlays" governs overlay removal, and the condition it observes is this blocker's resume condition. Running the exact denied command once is that observation, not a station rerun. A run that reads back observes it, and "## Blocked overlays" ("remove only the overlay, and continue") owns what follows. A run that is denied again does not observe it: record that denial as a ledger row, do not run the command again in that invocation, publish no second blocker, and "## Blocked overlays" ("If that condition is not observed") owns what follows.

## Blocked overlays

An explicit invocation of an issue that has `foreman:blocked` starts. Do not
refuse because of that label. Do not ask the operator to remove it first.
Before removing the overlay, observe the existing resume condition. Remove a human-capability overlay only when the missing capability, decision, or budget is observed. Remove a review-exhausted overlay only when one of the published
review-convergence resume conditions is observed. Keep the stage label. If that
condition is not observed, leave `foreman:blocked`, leave the blocker handoff,
and do not rerun the station. A label that is not `foreman:blocked`, including
a label named `blocked`, does not refuse the invocation and is not removed.
This section reads `capstan:blocked` as `foreman:blocked`, as [contract](contract.md) ("## Compat read path") states.

Review exhaustion is the one technical blocked overlay.
[Code-review convergence](review-convergence.md) states when it applies
("## Bounded rounds and recurrence", "## Coordinator-evidence findings").
It is not evidence that a person must diagnose or
repair the code. Its published resume conditions are a materially different
candidate repair, a policy/spec change, or an explicit trusted disposition.

All other blocked overlays identify a missing human capability:

| Reason | Exactly what the person supplies |
| --- | --- |
| credential-required | login, key, certificate, secret, authenticated session |
| purchase-required | payment, paid quota, plan authorization |
| permission-required | repository, organization, cloud, or service access |
| product-decision | consequential choice absent from admitted spec |
| external-action | dashboard, email, legal/physical/unsupported-system action |
| authority-required | required approval or action beyond v1 authority |
| safety-boundary | explicit authority for a production-affecting/destructive step |
| budget-approval | more time, scope change, or cancel at circuit breaker |

Failure to create this worktree's `index.lock` after the verified grant is
technical recovery, not `safety-boundary`. `unsafe_autonomy` is not the remedy.

Use [blocker](../templates/blocker.md). For human-capability blockers, publish one
concrete action and why an agent cannot supply it. For review exhaustion, publish
the qualifying repair/spec-policy/disposition resume choices and why automation
cannot continue on the same evidence. Add blocked overlay without removing the
stage. If GitHub access
itself is unavailable, report the blocker locally and to the user, then publish
when access returns; failure to publish does not hide the need.

A pending check, provider outage, rate limit, or unavailable service remains a
wait/retry condition unless a named human capability is missing. On a still-active
session, re-observe an awaited approval automatically. On a new invocation, verify
the capability, recorded budget decision, or review-exhausted resume condition;
remove only the overlay, and continue.
An elapsed wait is not approval. Stop/hand off owned processes explicitly on cancel
or blocker; leave evidence of any safe completed work and remaining steps.
