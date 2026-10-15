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
   pull request, or this change. Triage does not create `.capstan/vocabulary.md`
   and does not write it. Do not open a docs pull request. Do not edit
   `CONTEXT.md`. Settle discoverable facts yourself.
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
   deletes. This rule does not ask the invoker for every decision.
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
   from the clone. A prototype runs only
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
   informs it; the question carries the observation as evidence.
3. Maintain a frontier of unresolved product decisions. Ask numbered rounds only
   for consequential choices that evidence cannot settle. Recommend an answer and
   explain its effect. An ask is one numbered round of the current frontier. The
   coordinator waits only while an asked node is unanswered.
   A question whose answer depends on an open question in the same round waits for
   the next round. Do not ask the user to find files or diagnose technical errors.
4. Write the smallest complete admitted spec with [spec](../templates/spec.md).
   Preserve the original request verbatim inside a backtick fence longer than any
   backtick run in the request. The fence is at least three backticks long. Every
   request line is byte-identical inside the fence. When the request has no final
   newline, add one line break before the closing fence. That line break is not
   request content. Use numbered, independently verifiable acceptance criteria;
   omit internal orchestration detail and execution provenance.
   The admitted spec's Decisions section lists every visited node and its
   settlement. Vocabulary for a new term goes in the spec. A delivery-scoped
   decision stays in that spec and is not copied into `.capstan/vocabulary.md`.
5. Re-read the issue before replacing its body; incorporate concurrent trusted
   edits rather than overwriting them. Publish the spec with its hidden marker,
   read it back, and record its GitHub body revision/time for later plan evidence.
   Keep the existing issue-body spec marker `<!-- capstan:spec owner/repo#N -->`.
   Do not remove it. Do not delete `spec`.
   On that same publish edit, apply the publication title rule in `references/contract.md`. Do not restate it here.
   Write the complete body file before you run the publish. Run `gh issue edit N --repo OWNER/REPO --body-file FILE` as its own command, with `--title` only as that title rule allows. Chain no local file edit, readback, diff, or other command to it. Read the spec back with a separate command after it.
   A denied spec publish is a host permission refusal to run that command. A GitHub API error from a command that ran follows [recovery](recovery.md) ("## Observe, diagnose, retry"). On a denied spec publish, record the denial as a ledger row ([telemetry](telemetry.md) ("This file owns the attempt table.")), do not rerun the command in this invocation, and do not publish the spec on any other surface, such as an issue comment or a pull request. Publish a `permission-required` blocker ([recovery](recovery.md) ("| permission-required |")) with [blocker](../templates/blocker.md) ("# Delivery blocked"). Its action asks the person to allow or approve that command in the host and then re-invoke. Its evidence path names the local spec draft, and it does not carry the spec text. Its resume condition is a spec publish to the issue body whose readback matches. Label it as [contract](contract.md) ("A blocker adds only `capstan:blocked`") states, and the delivery stops.
   On a later invocation, [recovery](recovery.md) ("## Blocked overlays") governs overlay removal; the condition it observes is this blocker's resume condition. Running this publish once is that observation, not a station rerun. A run that reads back observes it; [recovery](recovery.md) ("remove only the overlay, and continue") owns what follows. A denied run does not; record that denial and do not rerun the command, as above, publish no second blocker, and [recovery](recovery.md) ("If that condition is not observed") owns what follows.
6. Do not invoke the grilling skill, `pipeline grill`, `grill-with-docs`, or any
   host grill command. Do not add a taxonomy module or an envelope.

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

Visit every stated outcome as a node and classify it as an acceptance criterion or a post-merge check. A post-merge check is a stated outcome that needs a merge, a deploy, an operator action, or elapsed time to observe; every other stated outcome is an acceptance criterion, verifiable before merge. This classification runs before the repository visit in the next paragraph, which visits only acceptance criteria. Classifying a stated outcome as a post-merge check is an Ask when it narrows what "done" means for the issue, and also an Ask when no acceptance criterion would remain; otherwise it is a Default, and its Decisions entry records the reason. It narrows "done" when the issue states that outcome as its definition of done or as part of it, even when other acceptance criteria remain. A supplementary observation stated alongside the definition of done, and not as part of it, does not narrow it. When no acceptance criterion would remain, the Ask recommends one that the delivery can verify before merge; the recommendation does not answer the node, which stays unanswered until the invoker answers. Post-merge checks go in the admitted spec's `## Post-merge checks` section of [spec](../templates/spec.md), worded as an operator checklist; a spec with no post-merge check omits the section. A post-merge check is never an acceptance criterion and never blocks ready or `capstan:ready-to-deploy`. Capstan runs, waits for, and observes no post-merge check, and a post-merge check that names a merge or deploy does not authorize one; [contract](contract.md) ("Deployment stays forbidden") owns the endpoint.

Visit every acceptance criterion as a node and ask whether it is verifiable in this repository. A criterion is verifiable in this repository when its pass or fail can be observed by changing and running only this repository. A criterion that needs a change or a run in another repository is not; a criterion that only mentions another repository can still be. A criterion that is not verifiable in this repository is an Ask. Evidence and Default are illegal for that criterion. The Ask recommends narrowing the spec to this repository's half and names the other half as a companion issue: its repository `owner/repo`, a one-line outcome, and the dependency direction, meaning which delivery must land first. When the invoker accepts, the admitted spec keeps only the narrowed criteria and adds the Decisions entry `Companion: owner/repo#M`, or `Companion: owner/repo (to be filed)` when the invoker will file it later; the entry carries the one-line outcome and the dependency direction. Capstan files, comments, labels, and writes nothing in the companion's repository; the invoker files the companion issue. Cross-repository scope never becomes an acceptance criterion of this delivery.

A Decisions entry `Depends on #M` or `Depends on owner/repo#M` is walked like any other node. [contract](contract.md) ("## Start condition") owns resolving M and the Ask for an M that does not resolve.

Trusted comments posted after the admitted spec: [pre-merge](pre-merge.md) ("Newer trusted comments") owns their check.

With two or more issues,
[batch invocation](modes/batch-invocation.md) ("Every issue is walked before any issue enters unattended delivery")
sets triage order and the cycle Ask; each walk is this file's walk.

A correction outcome adds its class Ask round, issue filing, and filing-only end to this walk; [correction](modes/correction.md) ("This file owns correction") owns all three.
