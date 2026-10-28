# Verification-path adoption

## Sub-features
- An inventory of the target's existing CLI, documented runner, and native automation, reusing the smallest supported path.
- A recorded path for one user operation: prerequisites, setup, readiness, drive, assertion, evidence capture, and reset.

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes, and state in an issue or in a text invocation that the outcome is verification-path adoption, naming the target repository and one user operation.
[verification path](../../references/modes/verification-path.md) ("This file owns verification-path adoption") owns the procedure.

## Driving it
Invocation: invoke Foreman with the URL or number of an issue that states the verification-path adoption outcome and names the target repository and one user operation, or with text that does.
End state: the path is recorded in an existing feature file's `Driving it` section, or else in the target's existing repo-native documentation.
Acceptance is a live run in the target from clean, isolated state.
Missing usable tooling, or a path whose only reset touches production, ends as a reported capability gap.

## Gotchas
- A normal feature delivery, init, or resume does not enter it.
- Foreman adds no runner, driver, default browser dependency, or required framework.
- Creating or extending a target CLI needs its own admitted scope.
- Verification stays isolated from production.
