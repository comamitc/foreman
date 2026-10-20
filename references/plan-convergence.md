# One-pass planning

The coordinator reads this before dispatching planning or plan-review, after their
results, and when resuming a run. Planning settles scope, architecture, irreversible
decisions, and the implementation approach. Executable correctness is proved in
implementing and code review, not through repeated plan judgments.

## Fixed sequence

One initial plan → one independent plan review → one correction pass covering the
entire feedback set → implementing. There is no second plan-review or planning escalation loop.

| Observed evidence | Next action |
| --- | --- |
| No initial plan | Fresh primary produces the initial plan |
| Initial plan, no complete review | Fresh secondary reviews once |
| Complete review, no actionable findings | Enter implementing |
| Complete review with findings, correction not launched | Fresh primary corrects the plan once against ALL findings |
| Correction returned | Merge the changes, check coverage, publish the merged plan and the handoff, enter implementing |
| Correction interrupted or incomplete | Preserve its output; hand off unfinished obligations to implementing |

A plan revision that the citation check sends back to its author keeps its step: the corrective prompts are not a second plan, plan review, or correction pass, and the returned initial plan is still the one initial plan. When the corrective prompts on the correction revision end with citation errors left, each remaining error line is an unfinished obligation, handled as the "Correction interrupted or incomplete" row above states. [references/harnesses/shared.md](harnesses/shared.md) ("The coordinator runs the citation check") owns when that check runs and the bound on the send-back.

One correction means one pass over all N findings, not one finding per pass. Its
brief includes the full census with original scenarios, acceptance conditions,
and evidence. Each finding needs a concrete plan correction with an implementation
check, an evidence-backed proposed refutation, or an explicitly identified
prerequisite. Update affected plan items, not just a response table. Preserve
settled scope; keep the correction proportional to the feedback.

The correction returns only changed plan content under `## Plan`: for each
changed section or item, its heading or item number in the current plan, the
action (add, replace, or delete), and the replacement text. Keys stay the
current plan's; an added item takes the next unused item number, and nothing
is renumbered. It returns the complete finding handoff under
`## Revision response`. There is no other template or schema. The coordinator
applies the changes to the current plan in the order returned and publishes
the whole merged plan as the next revision; resume and later stations read that
one revision.

The coordinator checks coverage by action: every added or replaced section or
item is present at its key in the merged plan, every deleted one is absent at
its key, and every finding is represented in the handoff. This is a coverage
check, not another design review. A correction is a proposed treatment, not
verified closure. Carry the original review, the merged plan's carried sections
([pack](pack.md) ("Implementing: the plan's identity lines")), and every finding
into the implementation brief using [finding resolution](findings.md). If a finding
was omitted or inadequately treated, retain it as unresolved with its original
acceptance condition and an explicit implementation task; never infer closure.
Implementation must complete this mapping before affected code is written.

## Prerequisites versus implementation obligations

Review severity alone does not stop implementation. Testable failure cases,
cleanup protocols, checksums, validation, and other technical corrections become
implementation tasks and regression checks.

Only a demonstrated missing decision, authority, permission, credential, other
human capability, or budget approval warrants [recovery](recovery.md)'s typed
handoff. State the exact missing prerequisite and why safe implementation depends
on it. Never invent rights or execute an unsafe step to meet the sequence.
An unexplained architectural contradiction requires technical diagnosis before
affected implementation, not automatic blocking or another plan-review cycle.
Technical diagnosis and repair proceed inside implementing with executable or
source-backed evidence; they do not reopen planning.

## Recovery and resume

Record the initial plan, complete review, correction launch/outcome, full finding
handoff, and original budget start in marked remote artifacts and run.md. A
correction launch consumes the single pass, including a crash or timeout. Observe
effects first; recover an existing result without rewriting it. Unfinished
correction work travels with the full census into implementing, rather than
starting another read-only correction worker. Missing initial-plan/review output
may be recovered for that same step, bounded by the original run budget; recovery
must not review the corrected plan or generate successive design verdicts.

Resume reconstructs these facts from GitHub and local evidence, not stage labels
or counters alone. Legacy runs with any post-review correction already launched
have consumed the pass: use the latest plan and all reconciled findings, and enter
implementing once actual prerequisites are satisfied. An ambiguous launch counts
as consumed. Missing history is reconstructed, not a fresh allowance. Preserve
prior verified evidence while distinguishing plan-level traces from code proof.

New findings, changed IDs/counts, technical repairs, base drift, fresh workers,
and resume do not restart planning. Only an explicit operator-authorized scope or
architectural change can reopen it; record the changed assumptions and affected
obligations. Preserve the original budget unless the operator explicitly extends it.
