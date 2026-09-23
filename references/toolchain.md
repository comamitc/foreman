# Toolchain

Take commands from the plan's named checks, then the repository's documented runner.
Do not detect a language. Do not invent a second runner.
Run preflight before worker launch.
The preflight records the command, the tool path, and the provenance.
A preflight failure is visible.
A preflight failure does not spend a worker turn on discovery.
This is a ban on worker-side discovery.
The brief carries the exact invocation.
A worker that substitutes a global tool has not followed the brief.
The worker runs that invocation.
The worker does not discover a command, a runner, or a tool path.

The three-step precedence is this order.
First, use the recorded toolchain when the identity matches.
Identity is the lockfile or manifest bytes, not a language version.
A mismatch invalidates only the recorded toolchain.
Resolution then uses the declared runner on `PATH`.
Second, use the declared runner on `PATH`.
Do not skip that `PATH` step.
Third, create one task-scoped environment only if that `PATH` step fails.
The fallback tool is the repository's own declared tool.
Do not limit that tool to a lockfile.
A manifest-only repository is included.
Do not assume a package manager is global.
Do not create a task environment when the `PATH` step succeeds.
Record the choice as provenance.

A single executable with no lockfile gets that executable and no new environment.
No declared check leaves the repo unchanged.
A declared `pipenv run` when no global `pipenv` exists uses these three steps.
A non-Python runner that is absent from `PATH` uses these three steps.
Neither is a virtualenv special case.
When a task environment is created, put it at `toolchain/` under the evidence root.
Do not implement #10 deletion. Do not re-run `lyric-utils#764`.
