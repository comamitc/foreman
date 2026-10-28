# Feature-map adoption

## Sub-features
- An inventory of the repository's authoritative sources before any file is named.
- Adoption of an existing conforming map, or a thin adapter map that links to the authoritative pages.
- A new map at a repo-native path, by default `.capstan/features`.

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes, and state in an issue or in a text invocation that the outcome is feature-map adoption.
[feature-map adoption](../../references/modes/feature-map-adoption.md) ("This file owns feature-map adoption") owns the procedure.

## Driving it
Invocation: invoke Foreman with the URL or number of an issue that states the feature-map adoption outcome, or with text that states it.
End state: a non-draft pull request that can merge under the existing ready gate and writes only the map files the plan names.
When a conforming map already exists, Foreman adopts it and does not create a second map.
The map then resolves as [contract](../../references/contract.md) ("`features` is the optional feature-map field") specifies.

## Gotchas
- A normal feature delivery, init, or resume does not enter adoption.
- The chosen path and any `.capstan.json` change land in the same reviewed commit.
- Adoption installs no documentation generator and no other skill.
- An unverifiable claim is omitted or reported as a gap.
