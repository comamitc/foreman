# Feature-map adoption

Run adoption only when the admitted issue or the text invocation states that the outcome is feature-map adoption.

This file owns feature-map adoption.

Before the plan names files, inventory the target repository. Record what is authoritative. Inventory the contributor instructions, the README, the existing documentation indexes, the ADR location when one is present, the user-visible entry points, the declared checks, and the configured `features` path. Do not copy those sources wholesale.

A map conforms when it uses the heading shape that [contract](../contract.md) owns and each feature file has a user-facing reach path.

When a conforming map already exists, adopt that map. Do not create a second map.

When existing documentation is useful and does not match the feature-map shape, create a thin adapter map. Link the adapter to the authoritative pages. Name the relevant source, tests, and checks in the adapter. Do not rewrite the repository's documentation system.

When no map and no suitable location exist, propose the repo-native path. The default path may be `.capstan/features`. An existing documentation convention may justify another configured path. Put the chosen path and any `.capstan.json` change in the same reviewed commit.

The index contains only user-facing features. Each feature file uses the heading shape that [contract](../contract.md) owns. State a real reach path, the exact repository command or interaction that drives the feature, the observable end state, and the material gotchas. An internal-only feature file is a feature file for an internal module that has no user-facing reach path. Do not add an internal-only feature file.

Trace every seeded claim to current source, to existing authoritative docs, or to a runnable repository check. The map remains a claim. Omit an unverifiable claim, or report that claim as a gap.

Name every file that adoption writes. [implementing](../implementing.md) ("Write only the paths the plan names") owns the write scope.

Do not install OpenSpec, AgentLens, a documentation generator, or another skill. Do not add a generated architecture encyclopedia.

Use the normal Capstan pipeline for implementation and review. The final pull request is non-draft. The final pull request is mergeable under the existing ready gate.

Acceptance is the normal pipeline and reviewer evidence on the diff.
