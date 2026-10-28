# Text invocation

## Sub-features
- Issue creation from the text, which is kept as the original request.
- Provisional title: the created issue's title may change when the spec is published; [contract](../../references/contract.md) ("The create-time title is the provisional title") owns when.
- An outcome stated in the text selects a mode, such as [feature-map adoption](feature-map-adoption.md); the [index](README.md) lists them.

## How to get to it (user POV)
Install Foreman as [README](../../README.md) ("Install and invoke") describes, and invoke it from a workspace whose repository `gh repo view` resolves.
[contract](../../references/contract.md) ("## Identity and authority") owns text intake.

## Driving it
Invocation: invoke Foreman with non-empty prose that contains no GitHub URL, is not the init invocation, which [contract](../../references/contract.md) ("### Init") owns, and does not start with the word `help`, which [help](../../references/modes/help.md) ("This file owns the help invocation") owns.
End state: Foreman prints the new issue URL in the host session, then runs the normal [issue delivery](issue-delivery.md) for that issue.
The created issue is the delivery identity.

## Gotchas
- `status` with any other text enters text intake.
- `init` with any other text enters text intake. The init invocation is not text intake; [contract](../../references/contract.md) ("### Init") owns it.
- Prose whose first word is `help` is a help invocation, not text intake, and creates no issue; [help](../../references/modes/help.md) ("This file owns the help invocation") owns it.
- If `gh repo view` cannot resolve a repository, no issue is created and Foreman asks for `owner/repo`.
- A GitHub URL that is not an issue URL, or empty text, creates no issue.
- Foreman does not read a filesystem path or use the surrounding transcript.
- A title a person already changed stays as it is.
- Text intake does not run init.
