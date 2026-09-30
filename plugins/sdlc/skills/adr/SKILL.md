---
name: adr
description: Write an Architecture Decision Record with the next sequential number in the repo's existing ADR format. Use when a significant technical decision is made or when asked why something was done a certain way.
---

# New ADR

## When one is warranted

Write an ADR whenever "why did we do it this way?" isn't obvious from the code:

- Choosing one library, API or service over a viable alternative
- Adopting a project-wide pattern or deviating from an existing convention
- Deciding **not** to do something that would seem obvious
- Superseding an earlier decision

Small implementation details don't need one.

## Steps

1. List `docs/adr/`. Match the repo's existing numbering width and filename style (e.g. `0004-title.md` vs `004-title.md`) and heading format. Next number = highest + 1.
2. Create the file with today's date. Status `Accepted` unless it's genuinely still a proposal.
3. If it supersedes an ADR, set the old one's status to `Superseded by <NNN>`.
4. If the repo keeps an ADR index (in `CLAUDE.md`, a README, or `docs/adr/README.md`), add the new row.
5. Commit: `docs: add ADR <NNN> <title>`.

## Default template (when the repo has no ADRs yet)

```markdown
# NNNN — Title

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded by NNNN

## Context

What situation prompted this decision? Which constraints mattered?

## Decision

What was decided? Which alternatives were considered, and why did they lose?

## Consequences

What becomes easier or harder as a result?
```
