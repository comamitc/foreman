# Help

## Sub-features
- A menu of topics, read at run time from the keyword table and the mode files; [help](../../references/modes/help.md) ("## Answer") owns its shape.
- An answer to a question, read from the file that owns it, with the invocation to send next and the owning file cited by path; [help](../../references/modes/help.md) ("## Situation map") names the owners.
- Read-only checks of local and GitHub state, mentioned only when they change the answer; [help](../../references/modes/help.md) ("## State checks") owns them.

## How to get to it (user POV)
Install Capstan as [README](../../README.md) ("Install and invoke") describes, and invoke it from any workspace.
[help](../../references/modes/help.md) ("This file owns the help invocation") owns the procedure.

## Driving it
Invocation: invoke Capstan with `help`, alone or followed by a question, for example `help how do I resume a blocked issue` or `help fix #42`.
End state: Capstan prints one menu or one answer and stops. An answer names the owning file by a path inside the installed package and the invocation to send next. The menu and the answer each end with a `Coverage:` line that says what was read, what was sampled, and what was not read. The run changed no file and no label, issue, comment, pull request, or branch on GitHub, and started no delivery.

## Gotchas
- Every invocation whose first word is `help`, in lowercase, is a help invocation, so such prose does not create an issue; to deliver from text, start the text with another word. `Help` and `helpme` are not help invocations; see [text invocation](text-invocation.md).
- `help fix #42` prints the invocation that delivers #42 and does not run it.
- Bare `help` asks no question; it prints the menu once. The menu has no `Send next:` line; each entry's `help <topic>` is the invocation to send.
- A failed state check, such as an unauthenticated `gh`, is named in the answer, never guessed.
- A "why is #N stuck" answer reads a blocker comment only after [security](../../references/security.md) item 1 is applied; an untrusted comment is named, not read.
