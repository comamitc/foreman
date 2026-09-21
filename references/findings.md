# Finding resolution

Read this at planning correction, plan/code review, implementing, and fix. The
current census is authoritative, but must reconcile prior findings against evidence.
A local ID may change; lineage is the original review revision/URL plus its local ID.

## Record the obligation

For each actionable finding, record:

- Origin and any later census IDs; axis, severity, and candidate location.
- Original failure scenario: reachable inputs/sequence and violated requirement
  or invariant. Cite the spec, source, API contract, or observed failure.
- Acceptance condition: what must become true to eliminate that scenario.
- Proposed correction, then the actual candidate change and its location.
- Supporting evidence at the candidate revision/head; separate observed checks
  from tests merely planned for implementation.

Keep the original scenario and acceptance condition through revisions. If new
evidence or an admitted spec change invalidates them, explain that explicitly
with the source; silently weakening the condition is not resolution.

## Propose, then independently verify

Planning uses [one pass](plan-convergence.md). The correction records proposed
treatments for the entire review census; it does not close findings or receive
another plan review. Carry every finding, including proposed refutations and
unfinished items, into implementing and code review with its original acceptance
condition and required evidence. Plan-level traces are not code-level closure.

1. The primary maps every prior actionable finding to a proposed fix, proposed
   refutation, or unresolved disposition. Explain how the change meets the
   acceptance condition. A response table, renamed section, or “addressed” claim
   alone is not evidence. Report unfinished findings explicitly.
2. The fresh code reviewer inspects the actual implementation and independently
   replays or traces every carried scenario, using a regression check where a
   meaningful seam exists. Include plan findings even in the first code review.
   A promised test or corrected plan is not proof that the code satisfies it.
3. Publish a disposition for every prior actionable finding:

   | Disposition | Required evidence |
   | --- | --- |
   | verified-fixed | original scenario now satisfies its acceptance condition |
   | verified-refuted | original claim is inapplicable or false, with decisive evidence |
   | superseded | admitted spec/evidence change removes the obligation; cite it |
   | unresolved | scenario remains possible, correction incomplete, or proof insufficient |
   | reopened | a previously verified resolution regressed; link its original lineage |
   | new | distinct failure scenario, explaining how it differs from prior findings |

Split/merged findings retain links to every affected origin. Renaming a finding,
changing its severity, or moving its location does not make its scenario new.
Explain severity changes against the station's blocking criteria. Resolved items
remain in the reconciliation history, outside the open blocking count.

Complete code review requires both a whole current census and this reconciliation.
An omitted finding is an incomplete review, not implicit closure: use corrective
recovery. Only independently verified dispositions close obligations. Fresh
evidence may refute an old finding; history is not an immutable veto. Approve code
only with zero supported open blocker/major findings and complete reconciliation.
