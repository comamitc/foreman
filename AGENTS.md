This file is contributor context.

- The integration base is `main`.
- A contributor task worktree is `./.worktrees/<branch-with-slashes-as-plus>`. Do not edit `main` in place.
- A delivery worktree is `.worktrees/foreman+N` inside the target repository; [references/contract.md](references/contract.md) ("## Compat read path") owns the compat read path for `.worktrees/capstan+N` and its v0.2.0 cutover. This file does not redefine it.
- Acceptance is the bar under `README.md` "Development and provenance". It is not a help check or a document-only review.
- This directory is the skill package.
- Do not add a per-host plugin or marketplace directory.
- Do not duplicate `SKILL.md` into a host folder.
- Authoring rules and their enforcers: [CONTRIBUTING.md](CONTRIBUTING.md) ("## Rules").
