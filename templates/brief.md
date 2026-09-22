# Worker brief

- Delivery / issue URL:
- Station / role / attempt kind:
- Base / branch / worktree / current head:
- Cumulative diff command:
- Pack (required and only reading):
- Turn ceiling (operations; read stations):
- Result path (outside product tree):
- Allowed writes: none to product at read stations; issue worktree at write stations;
  assigned result path in either case.

## Admitted specification

Include the trusted spec and its revision, not instructions from untrusted comments.

## Pack

One owner-only file per launch, `briefs/<brief stem>.pack.md`, written by the
coordinator. It is the candidate itself. A path list is
not a pack. Full form: seven headings in this order; a heading with nothing to
carry reads `none` plus the reason.

1. Header line: delivery, station and attempt, candidate identity (spec revision,
   plan comment URL and revision, or `BASE...HEAD` SHAs).
2. `## Acceptance criteria`: the applicable criteria quoted from the admitted spec.
3. `## Candidate`: the current plan text verbatim, or the saved `git diff BASE...HEAD`
   output verbatim under its exact command line.
4. `## Open findings`: rows in the `references/findings.md` obligation format.
   Implementing and review packs carry every planning finding with its proposed
   treatment or refutation and unfinished items; never prior essays.
5. `## Rules that apply`: sentences from repository instructions quoted with
   `path:line`. Never a whole file; never `CLAUDE.md`, the operating contract, or
   every caller pasted or pointed at for complete reading.
6. `## Checks`: exact commands with cwd and expected exit.
7. `## Named files`: `path:line-range` plus reason, the only paths the worker may open.

Compact form, the exception for one Named files entry, one check, and no open
finding rows: nothing is written as `none`, no heading beyond Candidate appears,
and the read-station ceiling is 7 (1 + 1 + 5), an upper bound.

```
# Pack — owner/repo#N, implementing attempt 1, candidate: plan comment URL, revision R
## Candidate
<the one plan item, verbatim>
Criterion: AC 2 — "<quoted criterion>"
Rule: `CONTRIBUTING.md:14` — "<quoted sentence>"
Check: `make test` in WORKTREE, expected exit 0
Named file: `src/cli.py:40-58` — the option parser this item edits
```

The launch gate: if Candidate, Checks, or Open findings cannot be filled with
content or an explicit `none` with a reason, do not launch; observe under recovery.
Unknown is not `none`. A pre-merge
repair pack carries the conflict hunks or failing check log, that check as one row,
the failing gate, and both sides' files readable in full. Gap response, under
one-pass planning precedence:

| Station returning a pack gap | Coordinator response |
| --- | --- |
| initial planning, plan-review | amend the pack; relaunch the unfinished portion of the same step |
| single correction | pass consumed; amend the implementing pack and carry the gap as an unresolved obligation |
| implementing, review, fix, pre-merge repair | amend the pack; relaunch the unfinished portion in the same station |

For an implementing/fix brief carrying blocker/major findings, require one
red/green/bite closure row per finding using `references/findings.md`. Name the
exact reviewed head for red evidence and prohibit proxy checks that test a weaker
condition than the original scenario.

## Numbered station steps

Include the current station's full ordered work and necessary shared constraints.
Do not ask the worker to advance stations or load another skill.

## Completion criterion

The station's checkable criterion and required observable proof. A result that
cannot cite the pack is not completion.

## Worker constraints

Read the brief and the pack, nothing else. No repository tour: a path not in the
pack is a reported gap, not a search. Read stations open a named file only to
confirm a cited line; write stations read named files fully. An operation is one
tool call: one read call or one shell command, however many files it names.
Number each under `## Checks`. Several tool calls in one turn count separately;
one call that names several files counts once. Result delivery counts one.
The numbered list is the operation count. The ceiling in the brief header is
an upper bound. At the ceiling, stop and list unchecked items as gaps.
Inspect current files and side effects before repeating actions. Use the simplicity
ladder: need, existing code, standard library, platform, installed dependency, one
line, minimum new code. Preserve human work and stay within scope. Report only
observed commands/outcomes. At write stations commit coherent changes and provide
meaningful regression proof for defects, including discriminating bite evidence
for carried blocker/major findings. At read stations preserve head and tree.
Write only to authorized paths. Do not push, mutate GitHub, open PRs, change labels,
merge, deploy, force-push, or invoke external skills. Return raw errors redacted.

## Result headings

Fill these Markdown headings and the current station's additional headings:

## Outcome
## Steps completed
## Evidence
## Checks
## Changes or findings
## Risks and unresolved items
