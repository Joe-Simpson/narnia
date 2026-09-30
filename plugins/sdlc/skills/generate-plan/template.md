---
slug: <slug>
spec: <spec/<slug>.md | issue #number>
issue: <#number | none>
author: <author>
date: <YYYY-MM-DD>
status: planned
---

# Plan: <title>

## Approach

<One paragraph: the implementation strategy and why. Reference the spec constraints that drove it.>

## Files

| Action | Path | What changes |
| ------ | ---- | ------------ |
| create | `...` | <purpose> |
| modify | `...` | <functions/components/types added, changed or removed> |

## Steps

1. <Specific enough that someone unfamiliar could execute it>
2. **RED** — write failing tests for: <each case, mapped to AC-n>
   - Confirm each fails with the repo's single-test command
   - Commit: `test(<scope>): add failing tests for <description>`
3. **GREEN** — implement <specific change> to pass the tests
   - Commit: `<type>(<scope>): <description>`
4. **REFACTOR** — clean up, then run every gate in `.claude/sdlc.json`
5. Docs: <ADR / setup / CLAUDE.md / changelog updates, or "none">
6. Smoke test: <manual check that exercises the acceptance criteria>

## Risks

- **Risk**: <what could go wrong> — **Mitigation**: <how it's handled>

## Rejected Alternatives

- **<Alternative>**: rejected because <reason>

---

_Update this file if implementation diverges. Set status to `implemented` once all steps are done and the verifier passes._
