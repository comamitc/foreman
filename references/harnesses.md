# Fresh headless workers

Read this only when spawning. Load [harnesses/shared.md](harnesses/shared.md) and
exactly one selected host adapter: [Claude](harnesses/claude.md),
[Codex](harnesses/codex.md), [Grok](harnesses/grok.md), or
[OMP](harnesses/omp.md). Do not load the other host files.
When Codex hosts the coordinator, also load [harnesses/codex-nested-host.md](harnesses/codex-nested-host.md).

The harness CLIs are `claude`, `codex`, `grok`, and `omp`, the commands the adapters' launch recipes run.
A help invocation may read this file only for these names; it loads no host adapter or shared file and spawns nothing.

`references/harnesses/shared.md` owns the silent-check rule.
