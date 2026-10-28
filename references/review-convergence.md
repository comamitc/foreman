# Code-review convergence

Read this before code review, fix, their recovery, or resume. Review is a quality
gate, not an unbounded search for additional improvements. Preserve every supported
finding, but route only effective blockers back through fix.

## Effective policy

Resolve `review_policy` through the normal configuration precedence. Defaults:

| Field | Default | Meaning |
| --- | --- | --- |
| `block_threshold` | `medium` | Lowest severity eligible to block |
| `min_confidence` | `0.70` | Lowest confidence eligible to block |
| `max_review_fix_rounds` | `3` | Maximum counted code-review censuses in one delivery; also the starting evidence-only allowance ("## Coordinator-evidence findings") |
| `surface_recurrence_rounds` | `3` | Consecutive rounds on one file/category surface that trigger convergence diagnosis |
| `residual_effect_approval` | `false` | Opt-in ready gate; [pre-merge](pre-merge.md) step 4 owns it |

Severity order is `low < medium < high < critical`. A finding is an **effective
blocker** only when all of these are true:

1. It is supported and in scope for this change.
2. Its severity is at or above `block_threshold`.
3. Its confidence is at or above `min_confidence`.
4. It is not covered by an explicit trusted operator disposition.

Everything else is advisory. Record advisories and their partition reason in the
review census and final summary, but do not send them to fix or count them against
readiness. A malformed or missing severity/confidence makes the review result
incomplete and uses review recovery; never guess a value. Configuration cannot
make a supported `critical` security, data-loss, corruption, or irreversible-state
finding advisory by severity threshold; confidence and disposition still apply.

Use this calibration in every code-review brief:

| Severity | Meaning |
| --- | --- |
| `critical` | security/auth bypass, data loss/corruption, outage, or irreversible state |
| `high` | concrete correctness defect, harmful race/ordering failure, stranded production dependency, or required behavior absent |
| `medium` | recoverable degradation, triggered edge case, or bounded operational hazard |
| `low` | hardening, observability, maintainability, narrow inconsistency, or another variant of an already-fixed class |

Confidence is a number from 0 through 1. `>=0.8` requires a concrete trace or
reproduction; `0.5..<0.8` is plausible with material context uncertainty; `<0.5`
is speculative. Do not inflate either field to force another round. Out-of-scope
and pre-existing observations are advisory regardless of their raw severity.

## Review ratchet

Round 1 reviews the complete cumulative diff, affected callers, and carried plan
findings. Every later round first verifies every prior effective blocker against
its original scenario, acceptance condition, and repair evidence, then reviews the
repair delta. It is not another unrestricted scan of unchanged code.

A later finding may block only when it meets the effective policy and is either:

- a prior blocker that remains unresolved or has reopened; or
- a distinct failure scenario introduced or materially exposed by changes since
  the preceding reviewed head; or
- an obligation admitted since the preceding reviewed head: an added or changed
  requirement, decision, or acceptance criterion that the head does not meet. It
  is reviewed as an open obligation row, and the round ceiling still applies.

A newly noticed concern in unchanged code is advisory as `late-discovered`, even
when it was in the original cumulative diff. Exception: a supported `critical`
security, data-loss, corruption, or irreversible-state finding may block once and
must explain why the earlier scope missed it. A renamed, split, deeper instance,
or weaker attempted repair of an earlier scenario is recurrent, not new. New
blocking findings must be at least as severe as the blocker whose repair exposed
them; lower-grade follow-on variants are advisory.

The coordinator performs the partition from the structured census; the reviewer
does not decide routing merely by returning `fix`.

An operator disposition must come from the explicit invocation or a trusted
OWNER/MEMBER/COLLABORATOR comment, name each finding's origin review and local ID,
state `accepted-risk`, `out-of-scope`, or `superseded`, and give a reason. The
coordinator republishes it on the PR with
`<!-- foreman:review-disposition OWNER/REPO#N -->`, source author/comment URL,
effective head and policy, then reads it back before repartitioning. Never infer a
disposition from approval, silence, labels, or ambiguous prose. A disposition for
one lineage does not cover a renamed distinct scenario.

## Coordinator-evidence findings

A **coordinator-evidence finding** is a code-review finding located in an evidence
check ([pack](pack.md) "A command the coordinator writes from plan text for a
pack's `## Checks` is an evidence check") or in real-run evidence ([pack](pack.md)
"Real-run evidence checklist"), and it shows no defect in the product diff. A
finding that also shows a product-diff defect is a product finding.

A finding is at **blocking grade** when its severity is at or above
`block_threshold` and its confidence is at or above `min_confidence`. The
**evidence-only allowance** is `max_review_fix_rounds` minus the number of earlier
evidence-only censuses in this delivery, counted from the marked censuses as
rounds are counted below. A complete census is an **evidence-only census** when
the evidence-only allowance is above zero, at least one of its blocking-grade
findings is a coordinator-evidence finding, and none of its product findings is
an effective blocker. A census whose only blocking-grade findings are
coordinator-evidence findings is therefore an evidence-only census while the
evidence-only allowance remains.
An evidence-only census does not consume a round, and it does not advance to
pre-merge. One delivery has at most `max_review_fix_rounds` evidence-only
censuses.

A coordinator-evidence finding is never sent to fix, because fix is a product
write station and the evidence lives outside the product tree. The coordinator
repairs each blocking-grade coordinator-evidence finding of a census before the
next review, by the repair that [pack](pack.md) owns for that kind of evidence:
the row "| any station reporting a defective evidence check" for an evidence
check, and the "Real-run evidence checklist" for real-run evidence. A
coordinator repair is not a station and moves no stage label. While the
evidence-only allowance remains, a coordinator-evidence finding is never an
effective blocker of the product.

Once the evidence-only allowance is zero, a census that holds a blocking-grade
coordinator-evidence finding is not an evidence-only census, and it consumes a
round. Each of its coordinator-evidence findings is partitioned as an ordinary
finding, under the effective-blocker list and the review ratchet above. While
the round allowance remains, the coordinator repairs each blocking-grade
coordinator-evidence finding as above, whether partition makes it an effective
blocker or leaves it advisory, and the next review is counted. At the round
ceiling, "Bounded rounds and recurrence" below applies to an effective one, and
it gives `review-exhausted`. At the round ceiling, the coordinator also repairs
each blocking-grade coordinator-evidence finding that partition leaves advisory,
and one confirmation review of those repairs follows without consuming a round.
If that confirmation review finds a coordinator-evidence finding at blocking
grade still open, the run adds `foreman:blocked` with blocker kind
`review-exhausted`.

A census with both product effective blockers and a blocking-grade
coordinator-evidence finding is not an evidence-only census, and it consumes a
round. Its product effective blockers go to fix. The coordinator repairs its
coordinator-evidence findings before the next review, and that review verifies
both.

After a coordinator repair, the next review is a confirmation review, a complete
census under the review ratchet. It verifies each repair against the finding's
acceptance condition. It judges a changed evidence check for weakening under
[review](review.md) ("When the pack carries a changed evidence check"). A
coordinator-evidence finding in that confirmation review is routed to the
coordinator again under this section. A pre-merge advance needs a review in
which no coordinator-evidence finding at blocking grade is open.

The census records each coordinator-evidence finding with its partition reason,
and states whether the census is counted, the remaining round allowance, and the
remaining evidence-only allowance.

## Bounded rounds and recurrence

Count marked, complete code-review censuses for this delivery from GitHub evidence,
including reviews recovered after lost local state. A malformed review does not
consume a round. A census taken before the checks in the gate owned by
[implementing.md](implementing.md) have exited 0 does not consume a round. An
evidence-only census ("## Coordinator-evidence findings" above) does not consume a
round. A review of a new head after implementation or fix does. Resume,
worker replacement, renamed finding IDs, and changed counts do not reset it.

For a delivery already in progress when this policy is installed, retain all legacy
findings and repair evidence, but do not count a census that lacks both an explicit
effective policy and blocking/advisory partition. The first policy-shaped census
is round 1. This is a one-time schema migration, not a reset available to later
configuration or wording changes.

When the same blocking scenario recurs after a claimed closure, apply
[finding resolution](findings.md): diagnose the failed proof independently and use
a materially different repair hypothesis. When new-key blockers occupy the same
file/category surface for `surface_recurrence_rounds` consecutive reviews, perform
the same diagnosis before spending any remaining round.

After publishing `max_review_fix_rounds` counted censuses:

- zero effective blockers advances to pre-merge, regardless of advisories,
  subject to the pre-merge requirement in "## Coordinator-evidence findings" above;
- remaining effective blockers add `foreman:blocked` with blocker kind
  `review-exhausted` and end ordinary automation.

Review exhaustion is a technical blocker, not readiness. Publish the exact
remaining blockers, advisories, reviewed head/base, round history, prior repair
hypotheses, and evidence. Keep the `foreman:review` stage label under the blocked
overlay. Do not launch another reviewer or fixer against the same head automatically.

Resume a review-exhausted run only after observing one of:

- a new candidate head containing a materially different repair;
- an admitted spec or policy change that changes the partition; or
- an explicit trusted operator disposition for named finding lineages with a
  reason, published in the next marked review/summary artifact.

Repartition at the current policy. A disposition is audit evidence, never an
implicit deletion. A new candidate head receives one fresh confirmation review;
it does not restart the consumed ordinary round allowance. If that confirmation
still contains an effective blocker, retain the review-exhausted blocker.
