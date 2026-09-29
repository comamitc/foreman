# Performance proof

Run it only when a performance requirement applies: an admitted acceptance criterion, or an applicable existing repository budget. Otherwise add no profiling step and no readiness gate. Required existing checks and independent read-only review stay unchanged.

This file owns performance proof.

The plan names the target repository, the affected user operation, the metric, and the accepted threshold. A missing consequential product criterion goes through existing [triage](../triage.md). Do not invent a frame, latency, or memory limit.

The plan pins the baseline and candidate revisions. Both use the same workload, data, runtime configuration, and environment. The plan records warm or cold state, the sampling, and the measurement tool's identity. Use the repository's native declared tooling. [toolchain](../toolchain.md) owns execution. Do not add a profiler or a Capstan runner.

When the target has a verification path, reuse its setup and reset steps. Otherwise use an equivalent existing native path.

Repeat the measurement as the metric requires. Report every result and its variability. Do not pick the best run. Do not weaken the agreed threshold. Noisy, incomparable, or insufficient observations leave the criterion `unresolved`. They are not a pass or an improvement.

Record the evidence through the acceptance row that [telemetry](../telemetry.md) owns. This rule adds no row field. Product latency or memory is not agent wall time or cost. The criterion is `verified` when repeated, comparable measurements at the current head meet the threshold. No other evidence verifies it. A candidate that misses the threshold leaves the criterion `unresolved`, even when functional tests pass. Implementing is then not complete, and the delivery is not ready. [implementing](../implementing.md) owns completion. A technical failure recovers normally.

A change of head, spec, workload, or environment invalidates the affected proof. Reassess and rerun it. Existing retention and redaction defaults apply. Do not enable replay retention. Do not keep unrestricted traces. Do not claim long-term reproducibility the evidence does not support.

Capstan adds no stage, label, schema service, universal benchmark framework, scheduler, automatic hill-climbing loop, default browser pass, or executable. Do not experiment on production traffic.

Acceptance is the normal pipeline and reviewer evidence on the diff.
