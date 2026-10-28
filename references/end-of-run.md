[telemetry.md](telemetry.md) ("## Ledger, pile, and deletion") owns the deletion rule.

For pre-merge, when `review_policy.residual_effect_approval` resolves to
`true`, record the residual-effect approval in `ledger.md` at each observation
of [pre-merge](pre-merge.md) step 4 and step 5, before the end-of-run order:
whether the gate applied; the residual effects or `unknown` reversibility that
triggered it, where a missing statement is `unknown`; and the counting approver
login, review `id`, and head SHA, or `no approval yet at <head SHA>` while the
blocker stands. Pre-merge owns the gate. This record is the summary source for
it.

At terminal readiness, project the ready label and read it back. At review
exhaustion, do not project `foreman:ready-to-deploy`; the order starts after the
review-exhaustion decision. Then run the recurrence comparison under "Earlier
deliveries and recurrence" and write its lines into `ledger.md`. Then follow
this end-of-run order:

1. Write the final `ledger.md` and read it back.
2. At ready-to-deploy only, apply the deletion rule under "Ledger, pile, and deletion", write its records into `ledger.md`, and read it back.
3. Compute the ledger digest with `sha256sum ledger.md` or `shasum -a 256 ledger.md` and take the hex field. Nothing is written into `ledger.md` after this step.
4. Compose the summary from `ledger.md`, inspect it for credentials per [security.md](security.md) rule 7, and publish a marked issue summary.
5. Read the summary back.

Event cutoff: append the `run-end` event before step 1. From step 1 on, record
no event in `events.jsonl` or any other evidence file; the only ledger write
after step 1 is step 2's deletion records. An event from step 1 on, such as a
`telemetry-gap`, a `recovery` for a failed summary publication, or a
`label-change`, goes into the summary's gaps when it occurs before step 4
composes the summary, and otherwise into the final message. A missed final
message has no later record; the published summary stands. Host status lines
continue.

Any other marked summary, such as a batch human-capability summary, uses steps
1 and 3–5 and the event cutoff. Do not recompute the summary from the pile. The summary contains
PR URL, current head/base, observed ready-gate or exhaustion facts, the ledger's
attempt table with its Total row and the date line (copied unchanged: the same columns, order, and cell formats), findings addressed/refuted,
recovery history, human interventions, same-harness independence or unsafe mode
disclosures, applicable policy rows whose state is not `verified`, the ledger's
`Recurrence:` lines, the line
`Residual-effect approval:` stating the facts of the latest ledger
residual-effect approval record when one exists, and gaps. It
also contains the line `Ledger sha256: <hex>`, or `Ledger sha256: unknown` when
the digest fails. At `foreman:ready-to-deploy`, a summary whose admitted spec
has a `## Post-merge checks` section contains that section copied verbatim,
heading included; the final `ledger.md` records it verbatim, so step 4 composes
it from the ledger.
A summary for a spec without that section has no such heading.
Last, it contains the final `ledger.md` verbatim:

~~~
<details>
<summary>ledger.md</summary>

````
<ledger.md bytes>
````

</details>
~~~

The fence is backticks, one longer than the longest backtick run in `ledger.md`
and at least three. The final `ledger.md` ends with a newline. The block ends the
comment: nothing follows `</details>`, not even a newline. Before publishing,
write the whole candidate comment, block included, to FILE and measure it in
bash or zsh with `SUMMARY_BODY="$(<FILE)" gh api rate_limit --jq '$ENV.SUMMARY_BODY | length'`.
The `--jq` filter runs locally on the variable; the body is not sent. The count
is in Unicode code points. Include the block only when the count is at most
65,536, GitHub's comment limit, and the block passes the credential inspection.
A failed command or a count of 0 means the size is unknown. Otherwise put
`Ledger not published: <reason>.` in place of the block, where the reason is
`the comment would exceed 65,536 characters`,
`the comment size could not be measured`, or `credential inspection failed`. If
GitHub still rejects the comment as too long, publish it once more without the
block, with the first reason.

A digest failure or an
unpublished ledger is a telemetry gap. It does not block ready-to-deploy. It is
reported per the event cutoff, not in `ledger.md`. The summary comment and its
read-back are the record of publication. Include recovered
counts only when evidence supports them. Lost local data yields unknown details,
not an unrecoverable run. A failed GitHub summary publication uses normal transient
recovery; do not pretend it published.

Emission follows the summary read-back. The coordinator's final message in the host session contains the attempt table with its Total row and the date line, copied unchanged from the published summary in the summary's columns, order, and formats. A URL may follow. The URL alone does not satisfy this. Trigger only at
verified `foreman:ready-to-deploy` or review exhaustion. The table stays terminal-only.
In a batch invocation, each issue's summary also publishes at a human-capability blocked overlay, and the final message waits for batch end; [batch invocation](modes/batch-invocation.md) ("Emit the final message once, after the last issue's summary read-back") owns both.
The surface is that final message on Claude Code, Codex, Grok, and Oh My Pi.
No plugin, notification command, or status-line API. Workers do
not post the table. Do not add a second summary comment or post the table on
the pull request.

[boundary pass](modes/boundary-pass.md) ("## Triggers") owns any pass after the final message.

Ledger digest check: in the directory holding `ledger.md`, run `printf '%s  ledger.md\n' HEX | sha256sum -c -` or `printf '%s  ledger.md\n' HEX | shasum -a 256 -c -`, where HEX is the published `Ledger sha256:` value. It prints `ledger.md: OK` and exits 0 on a match, and prints `ledger.md: FAILED` and exits 1 otherwise. To check the published bytes instead, first recover them into an empty directory with `gh api repos/OWNER/REPO/issues/comments/ID --jq '.body | (split("\n\n</details>") | .[-2] | split("\n") | last) as $f | split("<summary>ledger.md</summary>\n\n" + $f + "\n") | last | split("\n" + $f + "\n") | first' > ledger.md`, then run the same command. Digest-filter evidence: #184. A body with CRLF line endings fails recovery and the check. The digest is tamper-evident, not tamper-proof: a mismatch shows that the ledger or the published bytes changed after publication, and nothing prevents the change. Someone who can edit the comment can change both. It is not signing, attestation, or server enforcement.

[publication.md](publication.md) owns publication.

[telemetry.md](telemetry.md) ("This section owns earlier deliveries") owns earlier deliveries, their kinds, and classes.

Recurrence comparison. At terminal readiness after the ready-label read-back, or at the review-exhaustion decision, and before end-of-run step 1, compare this delivery with the 20 most recent earlier deliveries other than this one, newest first by issue number:

- classes of this delivery's plan-review and code-review findings, against those deliveries' marked `plan-review` and `review` censuses;
- this delivery's friction of kinds 1–3 from its `ledger.md`, against those deliveries' marked summaries, including their ledger blocks when present.

Read each earlier delivery's marked `plan-review` comments and marked summaries on its issue, and its marked `review` censuses on its marked pull request, with `gh` only, and apply trust per [security.md](security.md) item 1. Listing earlier deliveries still pages every issue; only these marked-comment reads are bounded to 20 deliveries. For friction, the comparison reads each marked summary's published `ledger.md` block when present, and also its recovery history and gaps, which correction does not read. For each class or signal of this delivery that occurred in two or more earlier deliveries, write one notes line in `ledger.md`:

`Recurrence: <class or signal> — #A <occurrence URL>, #B <occurrence URL>[, …]; suggest a correction issue (correction mode, [modes/correction.md](modes/correction.md)).`

When none recurs, write `Recurrence comparison: no recurrence; scope: <K> earlier deliveries #X–#Y; <sources read>.` A failed, truncated, or partial read is a telemetry gap: write `Recurrence comparison: gap: <source>: <redacted error>` in `ledger.md` and continue. A gap does not block and is not zero. Do not invent a result. A recurrence line is disclosure only: it does not block ready, open an issue, change a blocking/advisory partition, or change the review-exhaustion decision. "Any other marked summary" does not run the comparison. The within-delivery `surface_recurrence_rounds` diagnosis under [review convergence](review-convergence.md) is separate and unchanged.
