# Bounded plan revisions

The coordinator reads this before launching a plan revision and after every
plan-review verdict. Track the planning episode from its initial plan until
independent approval. The limit changes the repair strategy, not the ready gate.

## Ordinary revisions

`recovery.plan_revision_attempts` defaults to 2: initial plan and review, then at
most two ordinary revision worker launches, each followed by independent review.
Check the limit before launching another revision. Zero means diagnose after the
first rejected plan. An approval advances immediately, even at the limit.

Count each launched ordinary revision, including a crash, timeout, or corrective
continuation that attempts another revision. Do not count read-only review or
result-only recovery that preserves an already produced candidate. Inspect effects
before retrying. Changed IDs, fewer findings, longer plans, new spec/head, or fresh
workers do not reset this count. General recovery can escalate earlier.

Publish the episode, ordinary launch count/limit, and ordinary/escalated mode in
marked plan/review or activity evidence before dispatch; reconcile launch outcome
afterward. Resume reconstructs them from remote attempts, not labels or a missing
local counter. An ambiguous recorded launch counts conservatively. If history
cannot establish remaining ordinary attempts, diagnose instead of granting a new
quota. No special state file or parser is required.

## Escalated repair

When another revision is needed at the limit, stay in the active planning station:

1. Launch a fresh independent secondary diagnosis using the admitted spec,
   current candidate, full finding lineage, actual prior briefs/results, and source
   evidence. Verify what feedback the primary received. Distinguish incomplete
   repairs, contradictory requirements, new discoveries, and reviewer goalposts.
2. Require a causal explanation tied to evidence and a materially different repair
   strategy with bounded steps and explicit acceptance checks. Identify which
   accepted parts stay unchanged. “Be more thorough” or another unbounded rewrite
   is not a different strategy. Missing or unsupported diagnosis uses corrective
   recovery; it is not permission to retry the same repair.
3. Brief a fresh primary with that strategy and the complete current obligations.
   Supply a standalone ordered brief, not nested copies of previous briefs. Repair
   the demonstrated cause, preserve settled scope, and record evidence per finding.
4. Obtain fresh independent plan review using [finding resolution](findings.md).
   Approval advances; rejection stays escalated. Compare failed checks with the
   diagnosis, then use fresh diagnosis or an evidence-backed alternative hypothesis.
   For the same failure after diagnosis/repair, use shared recovery's configured
   fallback once per original failure scenario per run; if unavailable or already
   attempted, a fresh primary needs a materially different strategy.
   A changed finding count alone never restores ordinary retries. Repeated failed
   hypotheses are not new strategies. Keep an attempted-strategy history.

Escalation ends only with independent approval or a legitimate handoff. All workers
consume the original run budget; apply configured time/cost limits before dispatch.
Use [recovery](recovery.md) for unavailable harnesses, technical failures, and typed
human capabilities. Neither revision exhaustion nor disagreement warrants blocked.
Ask a human only for a demonstrated missing decision, permission, credential,
other named capability, or budget approval. Never invent policy/authority to make
a plan pass, lower its acceptance bar, or silently change configured model/effort.
