# Init

## Sub-features
- An absent `.capstan.json` is created and left uncommitted.
- An existing `.capstan.json` keeps its bytes unchanged, and init reports that it exists.
- The Foreman labels are ensured; [contract](../../references/contract.md) ("Ensure these eleven labels exist") lists them.

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes, and invoke it from a workspace inside the repository's git work tree.
[contract](../../references/contract.md) ("### Init") owns the init invocation and the procedure.

## Driving it
Invocation: invoke Foreman with exactly `init`, lowercase, and nothing else.
End state: the repository has a `.capstan.json`, either created and left uncommitted or with its bytes unchanged, and every label [contract](../../references/contract.md) ("Ensure these eleven labels exist") lists. No branch switch, commit, push, or pull request results.

## Gotchas
- `init` with any other text, including an override or an issue number, enters text intake, subject to its checks; see [text invocation](text-invocation.md).
- `init` is not a read-only invocation: it can write `.capstan.json` and create labels.
- Delivery does not require init; a missing `.capstan.json` still delivers.
