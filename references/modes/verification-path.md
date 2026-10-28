# Verification-path adoption

Run it only when the admitted issue or the text invocation states that the outcome is verification-path adoption.

This file owns verification-path adoption.

Before implementation, the plan names the target repository and one representative user operation.

Before the plan names files, inventory the target's existing CLI, documented runner, and native automation interfaces. Reuse the smallest supported path. Do not add a generic driver when the repository already has one.

Record the path in an existing feature file's `Driving it` section when the target has a suitable one. [contract](../contract.md) owns that heading shape. Otherwise record it in the target's existing repo-native documentation. A new feature file, page, or section needs its own admitted scope. Record these seven steps: prerequisites, isolated data or setup, start or readiness, the drive action, the observable assertion, evidence capture, and reset or cleanup. Mark a step that does not apply with its reason. Do not add a section schema, a feature-map heading, or a tool registry.

The coordinator carries the path's exact commands, required state, and allowed effects into the pack `## Checks` heading that [pack](../pack.md) owns. Workers do not discover tools. Workers do not inherit undocumented state. [toolchain](../toolchain.md) owns execution. [harnesses/shared](../harnesses/shared.md) owns result acceptance. [telemetry](../telemetry.md) owns the acceptance ledger row.

Missing usable tooling is a capability gap. Report the gap. Creating or extending a target CLI needs admitted target-repository scope and normal review. An ordinary feature issue does not become a tooling project. The Foreman executable ban does not apply to the target repository. Target CLI permission does not override a safety or authority boundary.

Verification stays isolated from production. Do not leak a credential. Do not make a live financial or messaging write. Do not reset production. A path whose only reset touches production is not a verification path. Report it as a capability gap. Reviewers stay read-only. A technical failure recovers normally. A permission or product decision uses the existing handoff.

Acceptance is a live run in the target. Run the accepted scenario twice from clean, isolated state with fresh workers. Run one meaningful failure case and one interrupted or dirty-state case. The observations reproduce, and reset returns clean state. A pass that depends on state the setup step did not create is not scenario success. No run relies on a previous worker's hidden state or an improvised replacement script. A launch or version probe is not scenario success.

Keep the pinned Foreman and target revisions, the relevant tool, config, and data identities, the actual invocations, the observed outcomes, and the cleanup results in existing evidence. Reference that evidence through the acceptance row that [telemetry](../telemetry.md) owns. This mode adds no row field. Existing head and spec invalidation and retention settings apply. Do not enable replay retention.

Foreman adds no runner, driver, default browser dependency, or required framework.
