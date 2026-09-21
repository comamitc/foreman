# Recovery inside the active station

A failed attempt supplies evidence for another autonomous attempt. It is not,
by itself, a human blocker. Preserve the active stage while recovering.

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
   budget or [plan revision count](plan-convergence.md).
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
   | actionable plan findings | apply plan-convergence.md before another revision; bounded ordinary attempts then independent diagnosis and changed strategy |
   | actionable code review findings | review/fix loop with findings.md reconciliation |
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

## Human capabilities

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

Use [blocker](../templates/blocker.md). Publish one concrete action with why an
agent cannot supply it, attempted recovery, evidence, station/branch/head, and exact
resume invocation. Add blocked overlay without removing the stage. If GitHub access
itself is unavailable, report the blocker locally and to the user, then publish
when access returns; failure to publish does not hide the need.

A pending check, provider outage, rate limit, or unavailable service remains a
wait/retry condition unless a named human capability is missing. On a still-active
session, re-observe an awaited approval automatically. On a new invocation, verify
the capability or recorded budget decision, remove only the overlay, and continue.
An elapsed wait is not approval. Stop/hand off owned processes explicitly on cancel
or blocker; leave evidence of any safe completed work and remaining steps.
