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
   | missing/weak/malformed result | precise corrective feedback, up to 2 corrective prompts, then a fresh worker |
   | failed behavior/test/type/lint/build | primary repairs using original command/logs, diff, spec and plan; rerun that check |
   | unknown technical failure | fresh diagnosis worker; unknown does not mean human-required |
   | resolved same_failure_attempts reached (default 2) | fresh secondary independent diagnosis, then fresh primary repair |
   | same failure after diagnosis and repair | one configured fallback attempt per original failure scenario per run; if unavailable or already attempted, fresh primary with a materially different hypothesis |
   | actionable plan findings | single correction against the complete census, then implementing with every obligation; apply plan-convergence.md |
   | actionable code review findings | bounded review/fix loop with review-convergence.md partitioning, findings.md reconciliation, and the pre-push closure proof gate |
   | recurrent/reopened scenario after a claimed fix | record the insufficient red/green/bite proof, obtain fresh secondary diagnosis, then use a materially different primary repair hypothesis |
   | conflicts/CI | pre-merge reference's ordered recovery |
   | telemetry/local artifact/helper failure | recreate from remote evidence or use direct existing CLI; note the gap |

4. Re-observe and verify the original completion criterion after repair. Continue
   with new evidence, another hypothesis, or independent diagnosis while budget
   remains. Exhausting transient retries is a diagnosis point, not permission to
   misclassify an outage as a product decision. Keep waits supervised and bounded.
5. At total wall/cost budget, request only more time/cost, admitted scope change,
   or cancellation. Preserve the run start across resume. If cost is unavailable,
   report unknown and resolve an explicit cost cap before exceeding what can be
   measured. Never request human diagnosis or repair of a technical error.

Deliver corrective feedback to the current worker only if its session is still
reachable through an installed, help-verified continuation interface. Otherwise
start a fresh worker carrying the prior result and precise feedback; missing resume
support is not a blocker. Each new station and independent judgment starts fresh.
Do not launch a second writer while a prior writer is alive.

## Blocked overlays

An explicit invocation of an issue that has `capstan:blocked` starts. Do not
refuse because of that label. Do not ask the operator to remove it first.
Before removing the overlay, observe the existing resume condition. Remove a human-capability overlay only when the missing capability, decision, or budget is observed. Remove a review-exhausted overlay only when one of the published
review-convergence resume conditions is observed. Keep the stage label. If that
condition is not observed, leave `capstan:blocked`, leave the blocker handoff,
and do not rerun the station. A label that is not `capstan:blocked`, including
a label named `blocked`, does not refuse the invocation and is not removed.

Review exhaustion is the one technical blocked overlay. Apply it only at
[code-review convergence](review-convergence.md)'s configured round ceiling with
effective blockers still open. It is not evidence that a person must diagnose or
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
| budget-approval | more time/cost, scope change, or cancel at circuit breaker |

Failure to create this worktree's `index.lock` after the verified grant is
technical recovery, not `safety-boundary`. `unsafe_autonomy` is not the remedy.

Use [blocker](../templates/blocker.md). For human-capability blockers, publish one
concrete action and why an agent cannot supply it. For review exhaustion, publish
the qualifying repair/spec-policy/disposition resume choices and why automation
cannot continue on the same evidence. Include attempted recovery, evidence,
station/branch/head, and exact resume invocation. Add blocked overlay without
removing the stage. If GitHub access
itself is unavailable, report the blocker locally and to the user, then publish
when access returns; failure to publish does not hide the need.

A pending check, provider outage, rate limit, or unavailable service remains a
wait/retry condition unless a named human capability is missing. On a still-active
session, re-observe an awaited approval automatically. On a new invocation, verify
the capability, recorded budget decision, or review-exhausted resume condition;
remove only the overlay, and continue.
An elapsed wait is not approval. Stop/hand off owned processes explicitly on cancel
or blocker; leave evidence of any safe completed work and remaining steps.
