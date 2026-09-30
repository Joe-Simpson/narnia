---
name: generate-spec
description: Turn an approved intent/<slug>.md into spec/<slug>.md — numbered requirements, testable acceptance criteria, design, and security notes.
argument-hint: "<slug>"
disable-model-invocation: true
---

# Generate spec

## 0. Load context

1. Read `.claude/sdlc.json` (stop and suggest `/sdlc:adopt` if missing). Resolve `<artifactRoot>`.
2. Confirm `<artifactRoot>/intent/$ARGUMENTS.md` exists with `status: approved`. If not, stop and explain.
3. Read the repo's `CLAUDE.md` for architecture and conventions the spec must respect.
4. Load every skill named in `stackSkills` — the spec must fit the repo's stack rules.
5. Read any ADRs relevant to the affected area (`docs/adr/`).
6. Apply `/sdlc:security-review` thinking up front, including the repo checklist at `securityChecklist` — flag risks now rather than in review.

## 1. Write the spec

Write `<artifactRoot>/spec/<slug>.md` from the repo's `spec/_template.md` if present, otherwise [template.md](template.md):

- Functional and non-functional requirements as numbered, verifiable statements (`FR-1`, `NFR-1`)
- Acceptance criteria that are each independently testable ("given X, when Y, then Z")
- Design: affected modules, data flow, schema/API changes, anything non-obvious
- Security & risk: every flagged concern
- Test coverage: what needs unit, integration/e2e, or manual coverage
- Open questions — never silently resolve a policy conflict; list it

If the design deviates from or supersedes an ADR, say so explicitly and note that `/sdlc:adr` will be needed.

## 2. Review and commit

Ask the product owner to confirm the spec solves the intent. Revise until approved, set `status: approved`, and commit:

```
spec: add <slug>
```

Do not write a plan or touch source. Next step: enter plan mode and run `/sdlc:generate-plan <slug>`.
