**Repository-scoped term**: a meaning later deliveries in this repository will need. Rejected: a decision that binds only this issue.

**Delivery-scoped decision**: a settlement that binds only this issue or this change. Rejected: copying it into `.capstan/vocabulary.md`.

**Vocabulary file**: `.capstan/vocabulary.md`. Rejected: `CONTEXT.md` or a host skill.

**Rung**: one step on the ladder. The first rung that holds is the one that gets written. Rejected: writing a lower rung and justifying it.

**Higher rung**: the earlier stop. Existing code is higher than a new helper. A native feature is higher than a new dependency. Rejected: treating a new file as higher than existing code.

**Never-cut list**: validation, data-loss handling, security, accessibility, and admitted requirements. These are not simplifications. Rejected: deleting a guard to hit a line-count target.

**Ceiling comment**: one line naming a known limit and the condition that would justify replacing it. Rejected: a new abstraction for that limit.

**Declared check**: a verification command the plan or the repository conventions already name. Rejected: a command Capstan invents from a file extension.

**Toolchain**: the resolved invocation for a declared check, plus the task environment when the repo's own tool requires one. Rejected: a global package manager assumed to be on `PATH`.

**Identity**: the bytes of the lockfile or manifest that produced the toolchain. Not a language version. Rejected: a language-version pin.

**Provenance**: which precedence step supplied the invocation. Rejected: a model judgment with no recorded step.
