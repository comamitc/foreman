# Improvement invocation and replay

Load this file when the resolved `evidence.retain_replay` is `true`, when an improvement invocation consumes replay inputs, or when the admitted issue or the text invocation states that the outcome is an improvement invocation. This file owns the improvement invocation, replay selection and consumption, review corrections, the no-new-violations guard, and the comment rule.

Replay-selection rule: a run is selected only when capture records a bundle of
admitted inputs, pack content, check bodies, setup references, and outcomes.
The bundle has no credentials and no unrestricted raw traces. Redaction removes
a credential. A bundle that still contains a credential is not selected. The
rule is not a script in `.capstan.json`. An unselected run has no replay
bundle. A missing capture is recorded in `ledger.md` and is not replayable. A
failed capture is recorded in `ledger.md` and is not replayable. Benchmark
capture is not a ready gate.

Consume a replay input only when `evidence.retain_replay` marked that input
replayable. A missing bundle, an off switch, or a failed capture is a named
limitation, not a zero. A kept pile is not a benchmark case. Compare the
baseline and the candidate on equivalent inputs. One run is not a victory.
Report acceptance, false-ready, intervention, recurrence, wall, and reported
token usage. Unknown usage is not zero. Do not add incompatible token fields. Publish
the exact revisions, the command, the result, and the limitations. Do not
relabel an old evaluation as current-main proof. Prefer an executable check
and a known fault injection. Do not reward weakening verification.

On demand. No daemon, scheduler, external skill, or database. A named batch.
Evidence-backed causes. A ledger failure with no bundle is still a failure. An
empty bundle batch is not "no failures." A proposal cites run identities, the
scenario, a counterexample, a falsifiable hypothesis, and a discriminating
benchmark. Deduplicate against open issues. An issue is published only after an
explicit improvement invocation. Analysis-only stays a report. Compare baseline
and candidate with a held-out check. A weaker rubric is rejected. Workers do not
rewrite the running skill. The improvement stops at an open pull request. A
rejected or unsupported proposal does not manufacture a product change.

Review corrections. An explicit improvement invocation may name a bounded batch
of review corrections by PR, review, or comment URL. Consume a correction
only from a trusted author under [security.md](../security.md). Verify each
correction's scenario against its cited revision. An unverified correction
is reported and changes nothing. Deduplicate against existing checks, review
guidance, navigation pointers, lessons, and open issues. Repetition is a
signal, not authority. A covered correction is reported as covered.

Route each verified correction to the first artifact that holds: (a) a
small admitted structural change (type, API, data model, architecture) or a
repo-native static check that makes the failure impossible or mechanically
detected; (b) a deterministic repository check for other machine-checkable
behavior; (c) existing repository review guidance for judgment; (d) an existing
navigation pointer for discovery friction; (e) the existing lesson store for
non-obvious reasoning; (f) no-op.
[lessons.md](lessons.md) ("This file owns the lesson rule") owns the lesson rule.
Compare a structural change with the other options on blast radius and
upkeep. It is an option, not an automatic rewrite. Reuse means a pattern that
meets the requirement, not a copy of a known-broken workaround. No global memory
or store dependency. Do not create an instruction file.

A proposed check catches the historical failure at the pinned revision
where it occurred and accepts a legitimate counterexample. A weak rubric is
rejected. An instruction that encodes one reviewer's preference as universal
law is rejected.

The proposal rule above applies to a review correction as follows. The
correction URL and its cited revision are the run identities. The verified
scenario is the scenario. The counterexample is a legitimate case the change
must still accept. It is the held-out check. For (a) and (b), the hypothesis
is that the change rejects the failure. The benchmark is that change run at
the pinned historical revision: it rejects the failure there and accepts
the counterexample. For (c), (d), and (e), the hypothesis names the wrong
decision the edit prevents. The benchmark is a reviewer walkthrough of the
cited scenario and the counterexample against the edited text: the scenario's
decision changes and the counterexample's does not. A no-op under (f) is not
a proposal. It is reported with the URL, revision, scenario, and why no rung
held. A telemetry run-failure proposal keeps every requirement above.

When legacy violations block immediate cleanup, a no-new-violations guard may
use the repository's existing tooling. It lists each approved exception with
its rationale. The guard fails on any new violation, including one that leaves
the total count unchanged. A count-only ceiling is rejected. Do not enlarge
a baseline to pass. Do not exempt a security or correctness obligation the
current change must meet. Cleanup beyond scope is a separate admitted task.

Keep a comment that explains a legitimate constraint or rationale. Reject a
comment used instead of meeting an acceptance criterion. No blanket comment
ban, universal framework, automatic gardener, scheduler, or second lint stack.

Separate Capstan-process improvements from target-product learning. A
Capstan-process improvement found in another repository is reported. It is
not published there and not written to the Capstan package. A standards,
navigation, lesson, or check change enters only through admitted scope, with
evidence and normal review. The invocation does not edit the installed or
running skill or host-global files. The endpoint is unchanged: analysis-only
stays a report, and a published proposal stops at an open pull request.

Reconstruction after cleanup uses the retained check body and the initial
target SHA. A state the bundle does not keep is the named limitation
`unavailable-after-cleanup`. The rule does not claim that the model is
deterministic.
