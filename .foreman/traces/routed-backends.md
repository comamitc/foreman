# Routed-backend procedure trace

This file is a procedure trace ([.foreman/vocabulary.md](../vocabulary.md) ("**Procedure trace**")). [CONTRIBUTING.md](../../CONTRIBUTING.md) ("**Procedure trace.**") governs its upkeep and its review, and [CONTRIBUTING.md](../../CONTRIBUTING.md) ("### Procedure trace refresh") gives the form of each fenced block. It has one entry for each routed-backend scenario of #388, headed by the scenario ID. Each entry gives the input, one or more Owner lines, and the expected outcome. The fenced block under each Owner line holds one or more consecutive whole owner lines, copied character for character without leading indentation, from the owner section its heading anchor names or from within five owner lines of its phrase anchor. R is the number of distinct requested (harness, model) pairs of the council, and B is the number of distinct evidenced routed backends across the votes.

## Inputs

- Issue: synthetic `owner/repo#N`, opened by a trusted author.
- Backend source: a synthetic captured source "S" that states the serving model separately from the requested name.
- Configuration: the default configuration, except that `review_policy.voters` holds the seats each entry names and `review_policy.distinct_backends` is `true` unless the entry says otherwise.
- Each entry starts from a complete code-review census with one voted candidate, unless the entry says otherwise.

## T-a

Two aliases, one evidenced backend.

Input: seats `{omp, jev/fast, null}` and `{omp, jev/smart, null}`; R=2; S gives `vendor/model-x` for both votes; B=1.

Owner: [references/review-convergence.md](../../references/review-convergence.md) ("## Verification vote")

```text
The requirement is unresolved when any voting seat's routed backend is `unknown`; otherwise it is met when the number of distinct evidenced routed backends across the votes is at least the number of distinct requested pairs, and unmet when it is not.
```

```text
With an unresolved or unmet requirement, the coordinator does not partition that census: it publishes a `review-exhausted` blocker as [recovery](recovery.md) ("## Blocked overlays") states, with [blocker](../templates/blocker.md) ("# Delivery blocked"), naming each seat index with its requested model, reported model, and routed backend, and the resume conditions that "## Bounded rounds and recurrence" lists for a backend requirement; it adds `foreman:blocked`, keeps the stage label, and stops.
```

Owner: [references/review-convergence.md](../../references/review-convergence.md) ("## Bounded rounds and recurrence")

```text
- for an unresolved or unmet backend requirement that "## Verification vote" states, a changed `review_policy.voters`, a changed `review_policy.distinct_backends`, or new backend evidence observed on a later invocation by that invocation's launch probe of a seat the blocker names; running that probe is not a station rerun.
```

Owner: [references/telemetry.md](../../references/telemetry.md) ("Provenance records three separate model facts")

```text
A routed backend is evidenced only by a source the coordinator already captures that states the serving model separately from the requested name, and the record names that source.
```

Outcome: unmet.

The census is not partitioned; a `review-exhausted` blocker names seats 1 and 2 with requested `jev/fast` and `jev/smart`, reported `jev/fast` and `jev/smart`, and routed backend `vendor/model-x` from S for both.

## T-b

Distinct evidenced backends.

Input: seats `{omp, jev/fast, null}` and `{omp, jev/smart, null}`; R=2; S gives `vendor/model-x` and `vendor/model-y`; B=2.

Owner: [references/review-convergence.md](../../references/review-convergence.md) ("## Verification vote")

```text
The requirement is unresolved when any voting seat's routed backend is `unknown`; otherwise it is met when the number of distinct evidenced routed backends across the votes is at least the number of distinct requested pairs, and unmet when it is not.
```

```text
Once the vote is complete and, when it applies, the backend requirement below is met, a voted candidate with more than N/2 `real` votes is partitioned under "## Effective policy". Any other voted candidate, a tie included, is `refuted-by-vote`: the census records it with each voter's vote and reason, it is advisory, it is never routed to fix, and it cannot by itself keep the delivery out of pre-merge. Voters add no round: "## Bounded rounds and recurrence" and "## Coordinator-evidence findings" count the census as they count a census without a vote, an evidence-only census included, however many voters ran.
```

Outcome: met.

The coordinator partitions the census by the vote.

## T-c

Unknown backend.

Input: seats `{omp, jev/fast, null}` and `{omp, jev/smart, null}`; omp reports `jev/fast` for seat 1; no captured source states its serving model, so seat 1 has routed backend `unknown`.

Owner: [references/review-convergence.md](../../references/review-convergence.md) ("## Verification vote")

```text
The requirement is unresolved when any voting seat's routed backend is `unknown`; otherwise it is met when the number of distinct evidenced routed backends across the votes is at least the number of distinct requested pairs, and unmet when it is not.
```

Owner: [references/harnesses/omp.md](../../references/harnesses/omp.md) ("omp shows the route's answer under the model you picked")

```text
Through a router such as Jev, omp reports the requested alias: comamitc/jev-router@0886e0fbbf351e00c4d48c31a7c4348043bbc203 `integrations/omp/README.md` ("omp shows the route's answer under the model you picked"); [telemetry](../telemetry.md) ("Neither the requested model nor the reported model is a routed backend by itself") owns what that report establishes.
```

Owner: [references/telemetry.md](../../references/telemetry.md) ("Provenance records three separate model facts")

```text
The model fields that [omp](harnesses/omp.md) ("Assistant messages"), [claude](harnesses/claude.md) ("Observed JSON fields of the stream's final `result` event"), and [grok](harnesses/grok.md) ("Observed JSON fields:") name, the reported model/provider and `modelUsage`, are reported models, not routed-backend sources; a routed backend with no named source stays `unknown` and is never inferred.
```

Outcome: unresolved.

The census is not partitioned, and a `review-exhausted` blocker names seat 1's routed backend as `unknown`.

## T-d

Provider-prefix and case difference that normalization accepts.

Input: seat `{omp, Google/Gemini-2.5-Flash , null}`, whose model is `Google/Gemini-2.5-Flash ` (with the trailing space); the last assistant message reports provider `google` and model `gemini-2.5-flash`.

Owner: [references/harnesses/omp.md](../../references/harnesses/omp.md) ("That comparison is lexical only")

```text
That comparison is lexical only: it folds case, trims surrounding whitespace, and joins a separately reported provider and model as `provider/model`, and a reported model that still differs is other than that model.
```

Outcome: accepted.

Both sides normalize to `google/gemini-2.5-flash`, so the seat's vote counts.

## T-e

Fallback and model mismatch.

Input (e1): a seat launch whose events include `retry_fallback_applied`.

Input (e2): a seat with set model `jev/fast`, whose last assistant message reported `vendor/model-x`.

Input (e3): a seat with set model `gpt-5`, whose last assistant message reports provider `openai` and model `gpt-5`, joined as `openai/gpt-5`.

Owner: [references/harnesses/omp.md](../../references/harnesses/omp.md) ("`retry.modelFallback: false`")

```text
`--tools=read,bash` and an evidence-only overlay. For a seat of a non-empty `review_policy.voters`, that overlay also sets `retry.modelFallback: false`, because omp's model fallback (`retry.fallbackChains` in the operator's omp configuration) otherwise answers with another model. A seat launch whose events include `retry_fallback_applied`, or, for a seat with a set `model`, whose last assistant message reports a model or provider other than that model, is a failed seat under [recovery](../recovery.md) ("failed seat:"), never a vote or a passed probe. For a seat whose `model` is `null`, the model and provider that message reports are that seat's resolved model.
```

Owner: [references/harnesses/omp.md](../../references/harnesses/omp.md) ("That comparison is lexical only")

```text
That comparison is lexical only: it folds case, trims surrounding whitespace, and joins a separately reported provider and model as `provider/model`, and a reported model that still differs is other than that model.
```

Owner: [references/recovery.md](../../references/recovery.md) ("failed seat:")

```text
| failed seat: a voter or a launch probe of a seat of a non-empty `review_policy.voters` fails, including an unavailable harness or model | the other rows that match the failure apply to that same seat, with its harness, model, effort, and recipe, up to and including the "resolved same_failure_attempts reached" row, whose repair changes no seat setting; the seat is never dropped and never swapped to a fallback or to another harness or model; in place of the "same failure after diagnosis and repair" row, the seat is exhausted: the vote stays incomplete, and the coordinator publishes a `review-exhausted` blocker as "## Blocked overlays" states, with [blocker](../templates/blocker.md) ("# Delivery blocked"), naming the seat index, harness, model, and redacted raw error and the resume conditions that [code-review convergence](review-convergence.md) ("## Verification vote") publishes for an exhausted seat; add `foreman:blocked` and keep the stage label; the delivery stops; an expired login follows its own row |
```

Outcome (e1): failed seat.
Outcome (e2): failed seat.
Outcome (e3): failed seat.

In e3, `gpt-5` still differs from `openai/gpt-5` after normalization.

## T-f

#382 seat exhaustion, unchanged.

Input: seat 2 is exhausted under the failed-seat row, so the vote stays incomplete; `distinct_backends` `true`.

Owner: [references/review-convergence.md](../../references/review-convergence.md) ("## Verification vote")

```text
A seat that [recovery](recovery.md) ("failed seat:") exhausts is review exhaustion. Besides the resume conditions that [recovery](recovery.md) ("Its published resume conditions are") lists, its blocker has one more: a launch probe of that seat's recipe that passes on a later invocation; running that probe is not a station rerun. On resume after a changed `review_policy.voters`, the new council votes that census from its first seat; otherwise a replacement voter on the exhausted seat completes the vote.
```

```text
The order is fixed: first a complete vote, then the backend requirement, then either the stop this paragraph states or the partition; a vote that never completes, including one whose seat is exhausted, never reaches the requirement.
```

Owner: [references/review-convergence.md](../../references/review-convergence.md) ("## Bounded rounds and recurrence")

```text
- for an exhausted seat, the added resume condition that "## Verification vote" publishes; or
```

Owner: [references/recovery.md](../../references/recovery.md) ("failed seat:")

```text
| failed seat: a voter or a launch probe of a seat of a non-empty `review_policy.voters` fails, including an unavailable harness or model | the other rows that match the failure apply to that same seat, with its harness, model, effort, and recipe, up to and including the "resolved same_failure_attempts reached" row, whose repair changes no seat setting; the seat is never dropped and never swapped to a fallback or to another harness or model; in place of the "same failure after diagnosis and repair" row, the seat is exhausted: the vote stays incomplete, and the coordinator publishes a `review-exhausted` blocker as "## Blocked overlays" states, with [blocker](../templates/blocker.md) ("# Delivery blocked"), naming the seat index, harness, model, and redacted raw error and the resume conditions that [code-review convergence](review-convergence.md) ("## Verification vote") publishes for an exhausted seat; add `foreman:blocked` and keep the stage label; the delivery stops; an expired login follows its own row |
```

Outcome: review-exhausted.

The blocker is the exhausted-seat blocker of #382; the backend requirement is never evaluated.

## T-g

Intentionally repeated seat.

Input (g false): two `{omp, jev/fast, null}` seats, `distinct_backends` `false`.

Input (g true): the same two seats, `distinct_backends` `true`; R=1; S gives `vendor/model-x` for both votes; B=1.

Owner: [references/contract.md](../../references/contract.md) ("`review_policy.voters` is a list of seat objects")

```text
A seat object has exactly the keys `harness`, one of `claude`, `codex`, `grok`, or `omp`, `model`, a non-empty string or `null`, and `effort`, a non-empty string or `null`; seats may repeat, and a seat may name the primary's harness.
```

Owner: [references/review-convergence.md](../../references/review-convergence.md) ("## Verification vote")

```text
With `false`, nothing in this paragraph applies, and the vote, partition, and seat rules above and below are unchanged.
```

```text
Its inputs are the number of distinct requested (harness, model) pairs of the council, where a `null` model counts as one value, and each voting seat's routed backend that [telemetry](telemetry.md) ("Provenance records three separate model facts") records.
```

Outcome (g false): no backend requirement.
Outcome (g true): met.

With `false`, the census is partitioned by the vote as before #388; with `true`, one requested pair needs one evidenced backend.
