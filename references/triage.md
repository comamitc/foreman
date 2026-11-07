# Triage — coordinator

1. Apply contract identity and security trust checks. Read the trusted original
   request, comments, repository instructions, and relevant code/tests.
   When `.foreman/vocabulary.md` exists, read it after repository instructions and before a question.
   [contract](contract.md) ("## Compat read path") resolves which vocabulary file this is.
   A term already defined there is evidence. Do not ask it
   again unless this issue contradicts it. A missing file is recorded and does
   not block. Evidence is the committed file on the resolved integration base. An
   unmerged vocabulary edit is not evidence for a different issue.
   Repository-scoped terms name a standing behavior, role, or artifact that
   later deliveries need. Delivery-scoped decisions bind only this issue, this
   pull request, or this change. Triage does not create a vocabulary file
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
   If a visited decision is an authority widening, a change that lets an actor
   move money (charge, pay, refund, pay out, transfer) or perform a write that
   the actor could not perform before, the settlement is Ask in this run even
   when the issue Decisions section states its answer, whatever
   `triage.auto_accept_recommended` resolves to. Evidence, Default, and a
   prototype observation are illegal for that node; a prototype informs the
   question as "Prototype:" below states. Only an invoker answer settles it.
   An invoker answer is an Ask settlement whose Decisions entry records the
   invoker's own answer: the answer URL of a comment that
   [recovery](recovery.md) ("A question blocker's resume condition") accepts,
   or a host-session answer that the admitted spec records with its round,
   question number, date, and quoted answer. `Ask, auto-accepted`, Default,
   and Evidence are not invoker answers. The question recommends the issue's
   answer and names who gains the authority and over what.
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
   explain its effect. An ask is one numbered round of the current frontier.
   A published round's number counts from 1 across the delivery's Ask rounds,
   auto-accepted rounds included, as its published blocker and `auto-answer`
   comments show. Each question has its own number in the round, from 1, and
   keeps it in every comment and event of that round.
   A question whose answer depends on an open question in the same round waits for
   the next round. Do not ask the user to find files or diagnose technical errors.
   Each round is asked on the issue: before the delivery's final message, publish
   each round as a question blocker, which is one `blocker` comment from [blocker](../templates/blocker.md) with blocker kind
   `product-decision`, whose reason names the round number and lists each numbered question with
   its question ID, `Context:` and the context of the decision, `Recommended:` and its
   recommended answer and `Effect:` and the effect of that answer, and `Options:` and every
   other option with its effect, and whose resume action asks for a reply that names each
   question ID or question number. A question has at least two options. A question with no
   recommended answer states `Recommended: none`. Add `foreman:blocked` and keep the stage label, as
   [contract](contract.md) ("A blocker adds only `foreman:blocked`") states. Read
   the comment and the labels back. Write the `ledger.md` row with the blocker URL
   and the `blocker` and `question` events, then deliver the round as "Question delivery:"
   below states; nothing waits in the host session before that read-back.
   [telemetry](telemetry.md) ("Every Ask round a delivery run asks")
   owns the `question` and `answer` events.
   [recovery](recovery.md) ("A question blocker's resume condition")
   owns its resume.

   Question ID: `owner/repo#N:rR:qK` is a question's stable identifier, from its delivery, its round number R, and its question number K. A retry or a resume keeps them, and reads each question, its context, and its options from the blocker comment.

   Question delivery: this rule delivers every question blocker of a delivery run, whichever step publishes it. It runs only after the blocker comment and the labels read back. A blocker comment, a label, or a final message never counts as delivery.

   - Picker: a session whose own tool list has a user-question tool, on a run without `--unattended`, presents the round: one prompt per unanswered question, in number order, each carrying the question ID, the question, its context, and every option with its effect, the recommended option first with `(Recommended)` after its label. A tool that cannot hold every option fails that question's delivery; trim nothing. Do not choose for the person.
   - Answer: relay each picker answer as [recovery](recovery.md) ("When the invoker replies to a question blocker") states before the next prompt.
   - Handoff: a session with no such tool, or a run with `--unattended`, prompts nothing and hands the round off.
   - Once: a question is prompted at most once in a run. A `question-delivery` line for it after the run's `run-start` or `run-resume` line means no prompt; when that read fails, the run hands the question off. A failed delivery gets no second prompt in that run, and no later question of the round is prompted in that run.
   - Outcome: `presented` needs a tool result that carries the person's answer; any other tool result is `failed`; a question handed off is `handed-off`; a question not prompted after a failure, or after a blocker read-back that failed, is `not-attempted`. [telemetry](telemetry.md) ("Every delivered question") owns the record. No comment, status line, or message says a picker was shown without that tool result.
   - End: when every question of the blocker has an answer, the run continues as [recovery](recovery.md) ("A question blocker's resume condition") states. Otherwise write the `run-end` event and stop with `foreman:blocked` on the issue, and end the final message with this block, one `Delivery:` group per unanswered question:

     ```text
     Foreman question handoff: owner/repo#N round R
     Blocker: BLOCKER_URL
     Resume: INVOCATION
     Answer rule: Present each question to the person with your user-question tool, recommended option first. Post the person's answer as a comment on the blocker's issue that quotes it and names the question ID, then send the Resume invocation. If you cannot present a question, tell the person delivery failed and show this block. Never answer for the person.
     Delivery: QUESTION_ID OUTCOME — EVIDENCE
     Question: TEXT
     Context: CONTEXT
     Option: LABEL (Recommended) — EFFECT
     Option: LABEL — EFFECT
     ```

   The [boundary pass](modes/boundary-pass.md) ("**Ask round.**") round and the [contract](contract.md) ("### Init") question stay in the session: neither is a delivery stop, so neither has a question blocker to deliver.

   Auto-triage: this paragraph applies only when `triage.auto_accept_recommended`
   resolves to `true` under [contract](contract.md)
   ("`triage.auto_accept_recommended` is a boolean"). With `false`, this
   paragraph does not apply, and every Ask is asked as this step states. It
   covers only Ask rounds of this walk, including the round
   [pre-merge](pre-merge.md) ("Newer trusted comments") asks. It does not cover
   the round [pre-merge](pre-merge.md) ("Ready backstop:") asks, the cycle round of [batch invocation](modes/batch-invocation.md) ("A cycle
   among in-set edges is one triage Ask round"), the class round of
   [correction](modes/correction.md) ("Ask and filing."), the round of
   [boundary pass](modes/boundary-pass.md) ("**Ask round.**"), or the trust
   confirmation of [security](security.md) ("Ask the user to confirm another
   issue author's trust"); auto-triage does not accept those rounds; each is
   asked as this step states. Before asking a
   round, the coordinator decides whether each question matches a category of
   the resolved `triage.pause_categories` ([contract](contract.md)
   ("`triage.pause_categories` is a list")). A question pauses when it matches
   one, or when the coordinator cannot decide whether it matches one. Under any
   list, including an empty list, a question also pauses when it has no
   recommended answer, when the recommendation does not answer the node,
   when it is the Ask for a `Depends on` entry that does not resolve
   ([contract](contract.md) ("An M that resolves to neither is an Ask")),
   or when it is the authority-widening Ask of step 2. Every
   other question in the round is auto-accepted. Next, publish one marked
   `auto-answer` issue comment for the round under [contract](contract.md)
   ("## Marked Markdown artifacts"), and read it back. The comment names the
   round by its number, gives each question of the round its number, and lists,
   for each auto-accepted question, the question, the chosen
   option, and the reason it matches no pause category, and, for each paused
   question, the category or rule that paused it. If the publish or the
   readback fails, settle and ask nothing in the round: inspect the issue
   comments as [contract](contract.md) ("Inspect all paginated comments and
   exact markers before publishing") requires, then take the URL of a comment
   this run published for the round whose body matches, edit one whose body
   differs to the composed body, or publish again when none exists, and read it
   back. A denied publish is a [recovery](recovery.md) ("## Denied coordinator
   step") outcome; any other failure that persists is recovered under
   [recovery](recovery.md) ("## Observe, diagnose, retry"). Until a comment for
   the round reads back with these classifications, no question in the round is
   settled, and the round is not complete. Then write the `question` and
   `answer` events of each auto-accepted question, record the comment URL in
   `ledger.md`, and settle each auto-accepted question as Ask with its
   recommended answer without asking it in the host session. Its Decisions
   entry records `Ask, auto-accepted`, the answer, and the comment URL, which
   is its answer URL. A rule above that requires an Ask settlement is met by
   that settlement. If the round has a paused question, run
   `gh issue edit N --repo OWNER/REPO --add-label foreman:needs-human`, plus `--remove-label capstan:needs-human` when the issue carries it, and read
   the labels back with `gh issue view N --repo OWNER/REPO --json labels`; ask
   the paused questions only after that readback shows the label. Then publish
   the paused questions as this step's question blocker; it carries that comment's round number, and it lists only the paused
   questions, each with its number from that comment. After every paused question in the round has
   an answer, run
   `gh issue edit N --repo OWNER/REPO --remove-label foreman:needs-human`, plus `--remove-label capstan:needs-human` when the issue carries it, and
   read the removal back with the same view. A round with no paused question
   adds no label.
4. Write the smallest complete admitted spec with [spec](../templates/spec.md).
   Preserve the original request verbatim inside a backtick fence longer than any
   backtick run in the request. The fence is at least three backticks long. Every
   request line is byte-identical inside the fence. When the request has no final
   newline, add one line break before the closing fence. That line break is not
   request content. Use numbered, independently verifiable acceptance criteria;
   omit internal orchestration detail and execution provenance.
   The admitted spec's Decisions section lists every visited node and its
   settlement. Vocabulary for a new term goes in the spec. A delivery-scoped
   decision stays in that spec and is not copied into `.foreman/vocabulary.md`.
5. Re-read the issue before replacing its body; incorporate concurrent trusted
   edits rather than overwriting them. Publish the spec with its hidden marker,
   read it back, and record its GitHub body revision/time for later plan evidence.
   Keep the existing issue-body spec marker, `<!-- foreman:spec owner/repo#N -->` or `<!-- capstan:spec owner/repo#N -->`.
   Do not remove it. Do not delete `spec`.
   On that same publish edit, apply the publication title rule in `references/contract.md`. Do not restate it here.
   Write the complete body file before you run the publish. Run `gh issue edit N --repo OWNER/REPO --body-file FILE` as its own command, with `--title` only as that title rule allows. Chain no local file edit, readback, diff, or other command to it. Read the spec back with a separate command after it.
   A denied spec publish is a host permission refusal to run that command, and [recovery](recovery.md) ("## Denied coordinator step") owns its outcome. Its blocker's evidence path names the local spec draft, and it does not carry the spec text. Its resume condition is a spec publish to the issue body whose readback matches. Label it as [contract](contract.md) ("A blocker adds only `foreman:blocked`") states.
   On a later invocation, [recovery](recovery.md) ("## Denied coordinator step") owns the resume observation. Running this publish once is that observation, not a station rerun.
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

Visit every stated outcome as a node and classify it as an acceptance criterion or a post-merge check. A post-merge check is a stated outcome that needs a merge, a deploy, an operator action, or elapsed time to observe; every other stated outcome is an acceptance criterion, verifiable before merge. This classification runs before the repository visit in the next paragraph, which visits only acceptance criteria. Classifying a stated outcome as a post-merge check is an Ask when it narrows what "done" means for the issue, and also an Ask when no acceptance criterion would remain; otherwise it is a Default, and its Decisions entry records the reason. It narrows "done" when the issue states that outcome as its definition of done or as part of it, even when other acceptance criteria remain. A supplementary observation stated alongside the definition of done, and not as part of it, does not narrow it. When no acceptance criterion would remain, the Ask recommends one that the delivery can verify before merge; the recommendation does not answer the node, which stays unanswered until the invoker answers. Post-merge checks go in the admitted spec's `## Post-merge checks` section of [spec](../templates/spec.md), worded as an operator checklist; a spec with no post-merge check omits the section. A post-merge check is never an acceptance criterion and never blocks ready or `foreman:ready-to-deploy`. Foreman runs, waits for, and observes no post-merge check, and a post-merge check that names a merge or deploy does not authorize one; [contract](contract.md) ("Deployment stays forbidden") owns the endpoint.

Visit every acceptance criterion as a node and ask whether it is verifiable in this repository. A criterion is verifiable in this repository when its pass or fail can be observed by changing and running only this repository. A criterion that needs a change or a run in another repository is not; a criterion that only mentions another repository can still be. A criterion that is not verifiable in this repository is an Ask. Evidence and Default are illegal for that criterion. The Ask recommends narrowing the spec to this repository's half and names the other half as a companion issue: its repository `owner/repo`, a one-line outcome, and the dependency direction, meaning which delivery must land first. When the invoker accepts, the admitted spec keeps only the narrowed criteria and adds the Decisions entry `Companion: owner/repo#M`, or `Companion: owner/repo (to be filed)` when the invoker will file it later; the entry carries the one-line outcome and the dependency direction. Foreman files, comments, labels, and writes nothing in the companion's repository; the invoker files the companion issue. Cross-repository scope never becomes an acceptance criterion of this delivery.
A companion Ask settled `Ask, auto-accepted` as this file states ("settle each auto-accepted question as Ask") is that acceptance.

A Decisions entry `Depends on #M` or `Depends on owner/repo#M` is walked like any other node. [contract](contract.md) ("## Start condition") owns resolving M and the Ask for an M that does not resolve.
A body that [decomposition](modes/decomposition.md) ("**Child body.**") filed keeps in the admitted spec its `Depends on #M` entries, its `Closes parent: #P` entry, and its `Child:`, `Plan:`, and `Parent:` lines. The walk visits a `Closes parent: #P` entry like a `Depends on #M` entry and settles it by Evidence: the parent's plan comment that the `Plan:` line names.

Trusted comments posted after the admitted spec: [pre-merge](pre-merge.md) ("Newer trusted comments") owns their check.

With two or more issues,
[batch invocation](modes/batch-invocation.md) ("Every issue is walked before any issue enters unattended delivery")
sets triage order and the cycle Ask; each walk is this file's walk.

A correction outcome adds its class Ask round, issue filing, and filing-only end to this walk; [correction](modes/correction.md) ("This file owns correction") owns all three.
