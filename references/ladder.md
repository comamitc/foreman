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

Reach the minimum that works only when no earlier rung holds.

## Never-cut list

Do not cut trust-boundary validation, handling that prevents data loss, security, accessibility basics, or any admitted requirement. An admitted acceptance criterion is an explicit request. Do not ship a smaller behavior and challenge the spec.

## Bug fix

A bug fix goes in the shared function after the callers are traced. One guard there beats a guard on only the path the ticket names. A deliberate ceiling is a one-line comment that names the ceiling and the upgrade path, not a new abstraction.

## Check

Non-trivial logic leaves one runnable check that fails if the logic breaks. A one-liner does not grow a framework, a fixture, or a per-function suite. An existing repository test convention still applies when that repository already has one. Do not invent a second test stack. Capstan has no test runner. Do not add one.

## Coordinator evidence

Coordinator evidence stays complete. Do not shorten briefs, censuses, `run.md`, or the requested PR sections to look lazy. The ladder governs the product diff, not those artifacts.
