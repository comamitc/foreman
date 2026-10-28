# Help invocation

Load this file only when [contract](../contract.md) "## Read-only invocations" dispatches the `help` keyword.

This file owns the help invocation.

## Argument grammar

The invocation is `help` followed by zero or more tokens of any kind. The tokens after `help`, joined by one space, are the question. With no token after `help`, the invocation is bare `help`. No token after `help` makes the invocation text intake or another invocation.

Examples: `help`; `help overrides`; `help init`; `help how do I resume a blocked issue`; `help why is #42 stuck`; `help fix #42`.

## Procedure

The coordinator does every step in the invoking session, under the rules [contract](../contract.md) "## Read-only invocations" states. This file's stricter rules: the procedure runs only file reads inside the installed skill directory, a listing of `references/modes/`, and the checks "## State checks" names; it runs no other `gh` or `git` command and no worker; it writes no file, including a temporary file; it asks no question; and it prints only in the invoking session.

1. **Parse.** Split the trimmed invocation on whitespace into tokens. Drop the first token. The rest, joined by one space, is the question.
2. **Menu.** With no question, read the keyword table under [contract](../contract.md) "## Read-only invocations"; its rows are the read-only invocations. List `references/modes/` and read the first paragraph of each Markdown file there that no keyword row names; those files are the outcome modes. Print the menu as "## Answer" states, then stop. Print no topic, keyword, or mode from memory.
3. **Route.** Take the "## Situation map" row that matches the question. A question that names a keyword in the keyword table routes to the mode file its row names. A question that names an outcome mode file's stem routes to that file. With no matching row, read the headings of [contract](../contract.md) and route to the section that matches.
4. **Read the owner.** Read the owning file's named section before answering. When the file disagrees with the map, the file wins. Answer only what a shipped file states. When no shipped file states it, say so and name the nearest owner. Invent no behavior, override, or config field.
5. **Work requests.** When the question asks for work, such as `help fix #42`, the answer is the invocation that does that work. Do not run it.
6. **State.** Run a check from "## State checks" only when its result can change the answer. Mention a result only when it changed the answer.
7. **Print.** Print the answer as "## Answer" states, once, then stop.

## State checks

These are the only checks the procedure runs. Each is read-only. A failed check is a named gap in the answer, never a guess.

- `gh auth status`, when the answer depends on GitHub access. Mention only whether `gh` is authenticated. Print none of its output.
- `gh repo view --json nameWithOwner`, when the answer depends on the invoking workspace's repository.
- Whether `.capstan.json` exists at the root `git rev-parse --show-toplevel` prints, when the answer concerns config or init.
- `command -v` for each harness CLI that [harnesses](../harnesses.md) ("The harness CLIs are"), ("A help invocation may read this file only for these names") names and permits, when the answer concerns harness choice or install.
- For a question about why issue `N` is stuck, with `R` the repository `gh repo view` resolves: `gh api --method GET "repos/R/issues/N"` for its `capstan:` labels, and `gh api --method GET "repos/R/issues/N/comments" --paginate` for its latest marked blocker comment, chosen as [status](status.md) ("Otherwise, the kind from the latest") chooses it. Apply [security](../security.md) item 1 ("inspect GitHub `author_association`") before reading a comment's text. A comment whose trust that item leaves unresolved is not read, and the answer says so.

## Answer

- **Menu.** The first line is `Foreman help — topics`. Then one line per topic, in this order: deliver an issue, deliver from text, batch, resume or unblock, overrides and config, install per host, read-only invocations, outcome modes. Each topic line, including the read-only invocations and outcome modes lines, is the topic and the invocation `help <topic>`; the nested lines below those two topics follow their own topic line. Under read-only invocations, one line per keyword row, in table order: the keyword and `help <keyword>`. Under outcome modes, one line per outcome mode file: the outcome its first paragraph names, in at most eight words, and `help <file stem>`. The overrides and config line also names the init invocation, which [contract](../contract.md) "### Init" owns. The menu asks nothing and has no `Send next:` line; each entry's `help <topic>` is the invocation it offers. Its last line is the `Coverage:` line.
- **Answer.** The first line is `Foreman help — <question>`. Then the answer in at most four sentences. Then `Send next:` and the invocation to paste. Then `Source:` and each owning file with its heading or quoted anchor, such as `references/recovery.md "## Blocked overlays"`. Then `State:` with each check result that changed the answer, only when one did. Then the `Coverage:` line.
- **Coverage.** The menu and every question answer end with one line, `Coverage: read FILES; sampled PARTS; not read SOURCES`. FILES is each file read in full. PARTS is each file read only in part, such as an outcome mode file's first paragraph, or `none`. SOURCES is each source the answer bears on that was not read, and each gap. [contract](../contract.md) ("The report states its coverage limits") owns the rule.
- **Host form.** Print each invocation in the invoking host's form from its row of [README](../../README.md) "## Install and invoke". When the host is unknown, an answer prints every row's form, and the menu prints every row's form of `help` once, after its first line, and its entries without a host form.
- **Citations.** A citation is a path relative to the installed skill directory. It is never a GitHub link.
- **Not a finding report.** A help answer has no Rule, Evidence, Consequence, Fix, or Issue body field. [contract](../contract.md) "## Read-only invocations" exempts it from the finding shape.

## Situation map

Each row names the file that owns the answer. The owner states the rule; this map names it and does not restate it. When a file disagrees with this map, the file wins.

| Situation | Owner and anchor |
|---|---|
| Deliver an issue by URL or number | [contract](../contract.md) "## Identity and authority" ("An issue URL uses that issue"), ("An invocation that is an issue number") |
| Deliver from text | [contract](../contract.md) ("Other non-empty prose with no GitHub URL creates one issue") |
| Deliver two or more issues | [batch](batch-invocation.md) ("This file owns batch invocation order") |
| Resume a delivery | [README](../../README.md) ("The same invocation resumes") |
| Resume or unblock a blocked issue | [recovery](../recovery.md) "## Blocked overlays" |
| Why an issue is stuck | [recovery](../recovery.md) "## Blocked overlays"; [status](status.md) ("This file owns the status invocation") |
| Overrides in one invocation | [contract](../contract.md) ("Allowed overrides stay overrides"); [README](../../README.md) ("You may specify overrides in the invocation") |
| Config, environment, and `.capstan.json` | [contract](../contract.md) "## Configuration" |
| The init invocation | [contract](../contract.md) "### Init" ("This section owns the init invocation") |
| Install per host and invocation forms | [README](../../README.md) "## Install and invoke" |
| Choosing harnesses | [contract](../contract.md) ("Probe each harness CLI on `PATH`"); [harnesses](../harnesses.md) ("The harness CLIs are") |
| Read-only invocations | [contract](../contract.md) "## Read-only invocations" |
| Outcome modes | [contract](../contract.md) ("An outcome mode files issues only where its mode file grants it") |
| File a Foreman improvement | [improvement](improvement.md) ("This file owns the improvement invocation") |
| Where a run's evidence is kept | [telemetry](../telemetry.md) "## Ledger, pile, and deletion" |

## Recipes

Each recipe is the text after the host form "## Answer" states. The owners in "## Situation map" state what each does.

- Deliver an issue: `https://github.com/OWNER/REPO/issues/N`, or the issue number `N`.
- Deliver from text: one line that states the outcome and does not start with the word `help`.
- Deliver two or more issues: `N M`.
- Resume: `https://github.com/OWNER/REPO/issues/42`; [README](../../README.md) ("The same invocation resumes").
- Overrides: `https://github.com/OWNER/REPO/issues/N primary codex, secondary claude, wall budget 90 minutes`.
- Init: `init`.
- A read-only invocation: its keyword alone, for each row of the keyword table under [contract](../contract.md) "## Read-only invocations".
- Help: `help`, or `help <question>`.

## Review

A cited owner that does not state the answer blocks. An answer that names a behavior, override, or config field no shipped file states blocks. An answer printed before its owning file was read blocks. A citation that is a GitHub link, or not a path relative to the installed skill directory, blocks. A question answer without `Send next:` blocks. The bare `help` menu prints no `Send next:` line; its `help <topic>` entries are the invocations it offers, and a menu in the shape "## Answer" states passes. A menu or question answer without a `Coverage:` line that names what was read, sampled, and not read blocks. An invocation in another host's form when the host is known blocks. A menu that lists a topic, keyword, or mode from memory, misses a keyword row or an outcome mode file, or asks a question blocks. A help answer with a finding field blocks. A map row, recipe, or state check that restates its owner's rule instead of naming it by owner and anchor blocks. A state result mentioned when it did not change the answer blocks. A help invocation's read of a harness file that [harnesses](../harnesses.md) ("A help invocation may read this file only for these names") does not permit blocks. A blocker comment's text read before [security](../security.md) item 1 is applied blocks. A help invocation that runs the work it was asked about, a delivery, init, or a worker, runs a `gh` or `git` command "## State checks" does not name, writes a file, or creates or changes a label, issue, comment, pull request, branch, worktree, or evidence file blocks.
