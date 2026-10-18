# Toolchain

Take commands from the plan's named checks, then the repository's documented runner.
Do not detect a language. Do not invent a second runner.
Run preflight before worker launch.
The preflight records the command, the tool path, and the provenance, and for a heavy check whether `flock` is on `PATH` and the slot the brief carries.
A preflight failure is visible.
A preflight failure does not spend a worker turn on discovery.
The brief carries the exact invocation.
A worker that substitutes a global tool has not followed the brief.
The worker runs that invocation.
The worker does not discover a command, a runner, or a tool path.

Preflight proof runs the exact command the brief names. When that command cannot run as the proof, preflight runs the smallest probe that shows that command's real entry point exists. A check of an empty path is not that proof. When that command comes from the project's dev dependencies, preflight installs those dependencies before the proof. The text `All dependencies are now up-to-date` is not success when the entry point is missing. A lock-hash mismatch is a visible preflight failure. A lock-hash mismatch does not fall through to a sync that omits dev packages. A version probe does not create a virtualenv.

A heavy check's exact invocation is `flock <state root>/heavy.lock <declared invocation>`, where `<state root>` is `${CAPSTAN_STATE:-${XDG_STATE_HOME:-$HOME/.local/state}/capstan}`, written out in full with no `owner/repo/N` part ([references/contract.md](contract.md) ("| Local evidence root |")); with N above 1 the slot rule below chooses the slot file.
N is `heavy_checks.max_concurrent` ([references/contract.md](contract.md) ("`heavy_checks.max_concurrent` is a positive integer")).
The lock has N slot files: slot 1 is `<state root>/heavy.lock` and slot K, for K from 2 to N, is `<state root>/heavy-K.lock`.
A check that is not heavy keeps its declared invocation, with no lock.
Every local run of a heavy check that Capstan makes uses that invocation: worker runs at every station and coordinator runs.
Each such run holds exactly one slot through its `flock` invocation, so at most N heavy checks run at once among sessions that resolve the same state root and the same N.
When the plan marks a heavy check, preflight prepares the lock before each worker launch whose brief carries that check: it runs `flock -n SLOT true` for every slot from 1 to N, which with N = 1 is `flock -n <state root>/heavy.lock true`.
Each probe creates its slot file and does not wait for another holder.
Exit 0, or exit 1 when another holder has the slot, means `flock` is on `PATH` and the file exists; exit 127 means `flock` is not on `PATH`, which preflight records once and then probes no further slot; any other exit is a visible preflight failure.
The brief carries the first slot whose probe exited 0, searching from slot ((I - 1) mod N) + 1, where I is the issue number, through slot N and then from slot 1; when every probe exited 1, the brief carries that starting slot.
Every heavy check in that brief names that slot.
The choice only spreads waits; the bound comes from each run holding one slot, and a check can wait on its slot while another slot is free.
A delivery whose plan marks no heavy check has no lock preparation.
For a heavy check, preflight proof is that smallest probe, not the full suite, so preflight runs no heavy check ahead of the order in [references/planning.md](planning.md) ("Mark each declared check heavy or not heavy").
`flock` waits with no timeout of its own; `worker_timeout_min` and the run wall budget bound the wait.
The preparation probe does not wait.
With no `flock` on `PATH`, the brief carries the declared invocation, the check runs unlocked, and the run does not stop; [references/telemetry.md](telemetry.md) ("The ledger notes keep the raw usage.") owns the notes line.
The lock is shared by every session that resolves the same state root.
Sessions that resolve the same state root and different values of N share the slots they have in common, so the bound among them is the largest N.
A session with its own `CAPSTAN_STATE` gets its own lock and can overlap with others.

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
`toolchain/` is pile. [telemetry.md](telemetry.md) owns its deletion. Evidence: #11 (`lyric-utils#764`), #61.
