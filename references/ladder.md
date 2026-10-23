# Ladder

Read the touched flow before you climb. Stop at the first rung that holds. If two rungs work, take the higher one. Do not write the lower one and justify it.

A higher rung is the earlier stop. Existing code is higher than a new helper. A native feature is higher than a new dependency. A new file is not higher than existing code.

Rungs, highest first:

1. need
2. existing code
3. standard library
4. native platform feature
5. already-installed dependency
6. one line
7. the minimum that works

## Never-cut list

Do not cut trust-boundary validation, handling that prevents data loss, security, accessibility basics, or any admitted requirement. An admitted acceptance criterion is an explicit request. Do not ship a smaller behavior and challenge the spec.

## Bug fix

A bug fix goes in the shared function after the callers are traced. One guard there beats a guard on only the path the ticket names. A deliberate ceiling is a one-line comment that names the ceiling and the upgrade path, not a new abstraction.

## Module

This section applies only to a module the change adds or reshapes. An existing module keeps its shape unless restructuring is the admitted task. Add a new module only when a behavior needs one.

Divide modules by the behavior they provide to callers, not by the state they hold. One module owns a behavior end to end. Prefer narrow, deep modules: a small interface with substantial behavior behind it. Apply the deletion test: if deleting a module would make no complexity reappear in its callers, it is a pass-through and is not added. Add a seam only where something actually varies: two adapters, or an external system.

Assume the next contributor is an agent that sees only the files it opened, copies the nearest example, and takes the shortest path that compiles, so a change that looks right from one file must be right for the whole repository.

Red flags:

- Information leakage: one internal decision appears in more than one module, so changing it means finding every copy.
- Temporal decomposition: modules split by execution order instead of by the knowledge they own, so one piece of knowledge spreads across steps.
- Split ownership: more than one module writes the same state, so no single module can keep it consistent.
- Two supported ways to do one task, so callers pick different ones and the two drift apart.
- Internals reachable from outside the module, so callers depend on them and the interface stops being the contract.
- Hand-synced lists: the same items listed in more than one place, so adding one means editing every list.

## Check

Non-trivial logic leaves one runnable check that fails if the logic breaks. A one-liner does not grow a framework, a fixture, or a per-function suite. An existing repository test convention still applies when that repository already has one. Do not invent a second test stack. Capstan has no test runner. Do not add one.

Test tiers, highest first:

1. end-to-end through the real entry point with real dependencies
2. integration at an API or data boundary against a real service
3. unit

The required check for non-trivial logic sits at the highest tier the target repository can already run. A tier can already run when a declared check or an existing repository test path already exercises it. Do not build a new tier, test stack, runner, or framework to reach a higher one. A lower tier needs a one-line reason in the plan.

The required check is derived from an admitted acceptance criterion and drives through the interface of the module that owns the behavior, at the tier the rule above selects. A test of private internals does not satisfy the required check.

A mock or stub of code the target repository owns does not satisfy the required check. A mock at a true external boundary remains allowed at the integration tier.

A real-dependency tier stays isolated from production: no live financial or messaging write and no production reset. Where only production can serve the dependency, the check drops to the next tier and the plan states that reason.

When the repository has no runnable end-to-end path, the plan records that gap and names the tier it used. The tier rule does not change the Markdown-only rule in [references/planning.md](planning.md) ("A Markdown-only change uses the simplest observable text checks") or the exemption in [references/implementing.md](implementing.md) ("Documentation, configuration, deletion, generated, operational, and trivial changes").

## Enforcement

This section owns the enforcement order. It applies to each mistake class or friction class a plan fixes; [correction](modes/correction.md) ("This file owns correction") names it. Pick the highest level that works, and state why each higher level did not.

Levels, highest first:

1. architecture: a module shape that makes the mistake impossible; "## Module" owns that shape
2. types
3. a lint or CI check whose error names the fix
4. a property-based or model-checked check
5. a behavioral test
6. standards or docs text, last

The property-based or model-checked level applies when the mistake class concerns an invariant over many states or sequences, and the target repository already has a property-testing or model-checking tool, or can add one with one dev dependency that runs under its existing test runner or declared check. Hypothesis, fast-check, proptest, and TLA+ are examples, not a closed list; a model checker such as TLA+ qualifies only when the repository already has and runs it. The plan names the invariant in one sentence and the generator or model bound. Its check meets the fail-on-occurrence, pass-on-fix, and registration rule in [correction](modes/correction.md) ("Every new check fails on a real past occurrence") and ("Every new or repaired check is registered"). The rungs above ("already-installed dependency") pick its tool.

These levels are not the rungs above. When [improvement](modes/improvement.md) also loads in a correction run, this order governs every correction class; improvement's routing ("Route each verified correction to the first artifact that holds") stays with the review corrections an explicit improvement invocation names, and its replay rules are unchanged.

## Coordinator evidence

Coordinator evidence stays complete. Do not shorten briefs, censuses, `run.md`, or the requested PR sections to look lazy. The ladder governs the product diff, not those artifacts.
