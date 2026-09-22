# Triage — coordinator

1. Apply contract identity and security trust checks. Read the trusted original
   request, comments, repository instructions, relevant code/tests, and vocabulary.
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
3. Maintain a frontier of unresolved product decisions. Ask numbered rounds only
   for consequential choices that evidence cannot settle. Recommend an answer and
   explain its effect. An ask is one numbered round of the current frontier. Each
   question includes a recommended answer. The coordinator waits only while an
   asked node is unanswered. Do not set ready while any asked node is unanswered.
   A question whose answer depends on an open question in the same round waits for
   the next round. Do not ask the user to find files or diagnose technical errors.
4. Write the smallest complete admitted spec with [spec](../templates/spec.md).
   Preserve the original request verbatim. Use numbered, independently verifiable
   acceptance criteria; omit internal orchestration detail and execution provenance.
   Decide the integration base using repository conventions before creating work.
   The admitted spec's Decisions section lists every visited node and its
   settlement. Vocabulary for a new term goes in the spec. Do not add `CONTEXT.md`.
5. Re-read the issue before replacing its body; incorporate concurrent trusted
   edits rather than overwriting them. Publish the spec with its hidden marker,
   read it back, and record its GitHub body revision/time for later plan evidence.
   Keep the existing issue-body spec marker `<!-- capstan:spec owner/repo#N -->`.
   Do not remove it. Do not delete `spec`. Do not add a marker kind.
6. Do not invoke the grilling skill, `pipeline grill`, `grill-with-docs`, or any
   host grill command. Do not add a taxonomy module, an envelope, a new marker
   kind, a `CONTEXT.md` pull request, a stage, a label, or an executable.

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
