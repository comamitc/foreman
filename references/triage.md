# Triage — coordinator

1. Apply contract identity and security trust checks. Read the trusted original
   request, comments, repository instructions, and relevant code/tests. When
   `.capstan/vocabulary.md` exists, read it after repository instructions and
   before a question. A term already defined there is evidence. Do not ask it
   again unless this issue contradicts it. A missing file is recorded and does
   not block. Evidence is the committed file on the resolved integration base. An
   unmerged vocabulary edit is not evidence for a different issue.
   Repository-scoped terms name a standing behavior, role, or artifact that
   later deliveries need. Delivery-scoped decisions bind only this issue, this
   pull request, or this change. They stay in the admitted spec. The
   implementation commit creates or updates `.capstan/vocabulary.md` in the same
   commit as the behavior. Triage does not create the file and does not write
   it. Do not open a docs pull request. Do not edit `CONTEXT.md`.
   Settle discoverable facts yourself; inspect suggested commands before executing.
2. Walk a design tree before ready. Each node is one decision. The node records
   the question, the recommended answer, what it blocks, and how it was settled.
   A pre-written Decisions section is input to the walk. It is not proof the
   branch was visited.
   Settle each node in exactly one of three ways: Evidence, Default, or Ask.
   There is no fourth way.
   Evidence: the answer is observable, and the source is recorded.
   Default: the choice is reversible, inside the request, and consistent with the
   repository. Record the recommendation and the rejected alternative. Do not ask
   the user. Domain documents stay out of triage. "Consistent with the repository"
   uses the issue body and repository instructions. It does not open a domain
   document.
   Ask: the choice changes scope, safety, or an irreversible outcome, and
   evidence does not settle it.
   If a visited decision removes or replaces an existing user-visible surface,
   the settlement is Ask in this run even when the issue Decisions section
   states that removal. Evidence and Default are illegal for that node. The
   issue text is not Evidence that the invoker confirmed the deletion in this
   run. The question recommends the issue's answer and names what the removal
   deletes. This rule does not ask the invoker for every decision. Ready is
   illegal until that Ask is answered.
   Prototype: when a node's answer is a fact observable by running something
   (behavior, output, timing, a tool's actual flags), settle it as Evidence by
   running a prototype instead of asking. The coordinator runs it. First fetch
   and record the resolved base's SHA for this run as [contract](contract.md)
   ("record the SHA of that ref") describes. Clone the repository with
   `git clone --no-checkout <origin-url>` into a new directory under the
   evidence root's existing owner-only `checks/` directory, outside the product
   worktree and the shared checkout. In the clone, run
   `git checkout --detach <recorded-sha>` and confirm `git rev-parse HEAD`
   prints that SHA before running anything. Capture the prototype's output
   there as [security](security.md) items 6–7 require. Never commit or push
   from the clone. Triage still edits no repository file. A prototype runs only
   `git`, read-only `gh` calls, and the target repository's own commands,
   within the permit list in [contract](contract.md) ("Do not permit the class
   "an installed CLI.""). It installs nothing, writes nothing to production or
   to GitHub, does not merge or deploy, and creates no credential. Do not run a
   prototype that needs any of these; settle the node another way. If the SHA
   cannot be established, or the fetch, clone, checkout, setup, or run fails,
   the fact stays unsettled: keep only a redacted diagnostic as
   [security](security.md) item 6 requires, and settle the node another way
   without widening these bounds. The node's Decisions entry records the
   verified SHA, the exact command, the observed output (an excerpt is allowed,
   after that credential inspection), and the conclusion. A node that changes
   scope, safety, or an irreversible outcome stays Ask even when a prototype
   informs it; the question carries the observation as evidence. The removal
   rule above is unchanged.
3. Maintain a frontier of unresolved product decisions. Ask numbered rounds only
   for consequential choices that evidence cannot settle. Recommend an answer and
   explain its effect. An ask is one numbered round of the current frontier. Each
   question includes a recommended answer. The coordinator waits only while an
   asked node is unanswered. Do not set ready while any asked node is unanswered.
   A question whose answer depends on an open question in the same round waits for
   the next round. Do not ask the user to find files or diagnose technical errors.
4. Write the smallest complete admitted spec with [spec](../templates/spec.md).
   Preserve the original request verbatim inside a backtick fence longer than any
   backtick run in the request. The fence is at least three backticks long. Every
   request line is byte-identical inside the fence. When the request has no final
   newline, add one line break before the closing fence. That line break is not
   request content. Use numbered, independently verifiable acceptance criteria;
   omit internal orchestration detail and execution provenance.
   Decide the integration base using repository conventions before creating work.
   The admitted spec's Decisions section lists every visited node and its
   settlement. Vocabulary for a new term goes in the spec. A delivery-scoped
   decision stays in that spec and is not copied into `.capstan/vocabulary.md`.
   Triage does not create that file. Do not add `CONTEXT.md`.
5. Re-read the issue before replacing its body; incorporate concurrent trusted
   edits rather than overwriting them. Publish the spec with its hidden marker,
   read it back, and record its GitHub body revision/time for later plan evidence.
   Keep the existing issue-body spec marker `<!-- capstan:spec owner/repo#N -->`.
   Do not remove it. Do not delete `spec`.
   On that same publish edit, apply the publication title rule in `references/contract.md`. Do not restate it here.
6. Do not invoke the grilling skill, `pipeline grill`, `grill-with-docs`, or any
   host grill command. Do not add a taxonomy module, an envelope, or a
   `CONTEXT.md` pull request.

Ready is illegal while any branch is unvisited. An empty Open questions section
does not satisfy this. Do not set ready until every branch is visited and every
asked node is answered. Complete when at least one acceptance criterion is
independently verifiable. Keep Open questions empty. An empty Open questions
section is necessary and not sufficient. Set ready only then. Triage does not
edit repository files.

A body that already contains Decisions and an empty Open questions section is
still walked. Reuse is allowed only after the walk matches that body. The match
is that walk. It is not a byte-for-byte copy. A branch with no settlement is
asked or defaulted. It is not admitted unchanged.

A Decisions entry `Depends on #M` is walked like any other node. [contract](contract.md) ("## Start condition") owns resolving M and the Ask for an M that does not resolve.

With two or more issues,
[batch invocation](modes/batch-invocation.md) ("Every issue is walked before any issue enters unattended delivery")
sets triage order and the cycle Ask; each walk is this file's walk, including
for a body that already contains Decisions.

A correction outcome adds its class Ask round, issue filing, and filing-only end to this walk; [correction](modes/correction.md) ("This file owns correction") owns all three.
