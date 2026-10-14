# ADR rule

Load this file only when repository instructions or the admitted issue require an ADR.

This file owns the ADR rule.

Repository instructions or the admitted issue decide whether an ADR is required. Do not invent a universal ADR threshold. Do not create an ADR directory merely because a design choice exists.

Discover the existing ADR path, template, numbering or naming rule, status model, index, and declared validation command. The plan names the exact ADR and index paths. An unnamed path is a gap, not a search.

A required ADR uses the repository's native format for context, decision, alternatives, consequences, and supersession. Do not copy the issue. Do not duplicate `.capstan/vocabulary.md`.

The new or superseding ADR lands in the same commit as the architectural behavior. Do not rewrite accepted historical ADR text to erase the earlier decision, except for a repository-permitted mechanical correction.

[implementing](../implementing.md) ("Write only the paths the plan names") owns the write scope.

No convention and no explicit issue requirement means write no ADR and create no ADR infrastructure.

Do not add an external ADR tool, OpenSpec, or a generator. A declared ADR checker stays a declared check.

Acceptance is the normal pipeline and reviewer evidence on the diff.

## Review

Block a missing required ADR. Block a broken supersession link. Block invented rationale. Block a contradiction with the diff.

The ADR is a claim. Code and checks are proof.
