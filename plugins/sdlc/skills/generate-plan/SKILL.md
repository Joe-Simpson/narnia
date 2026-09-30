---
name: generate-plan
description: Produce plan/<slug>.md — the step-by-step implementation plan and audit record — from an approved spec (or, on the bug fast path, from an issue). Run in plan mode.
argument-hint: "<slug>"
disable-model-invocation: true
---

# Generate plan

Run this in plan mode. No source file is edited until the plan is committed — the `guard-src-edit` hook enforces this when `enforcePlanGate` is on.

## 0. Load context

1. Read `.claude/sdlc.json`; resolve `<artifactRoot>`, `srcPaths`, `gates`, `stackSkills`, `bugFastPath`.
2. Normal path: confirm `spec/<slug>.md` has `status: approved` and read it plus `intent/<slug>.md`.
3. **Bug fast path** (only if `bugFastPath` is true and the work is a bug fix with a small blast radius): the GitHub issue (or an `intent/<slug>.md` with `type: bugfix`) stands in for the spec. Read it with `gh issue view`. If the fix changes behaviour beyond restoring what was intended, stop and use the full chain.
4. Load the `stackSkills`, relevant ADRs and `CLAUDE.md` conventions.
5. Read every source file the change will touch. Understand current behaviour before proposing edits; look for existing helpers to reuse.

## 1. Draft the plan

Cover:

- Every file to create, modify or delete, naming the specific functions, components, tables or types
- Order of changes — dependencies first; each test before the code it covers (Red → Green → Refactor)
- Test cases by description (what each asserts), mapped to spec acceptance criteria
- Commit sequence using conventional commit types
- Docs that must change in the same PR (ADRs, setup docs, CLAUDE.md, changelog)
- Risks with mitigations, and rejected alternatives with reasons

Stress-test it: what could break, what is riskiest, what would a reviewer question? Refine until someone with no access to this conversation could execute it without asking questions.

## 2. Write and commit

Write `<artifactRoot>/plan/<slug>.md` from the repo's `plan/_template.md` if present, otherwise [template.md](template.md). Set `spec:` to the spec path, or to `issue #<n>` on the fast path. After the engineer approves, commit:

```
plan: add <slug>
```

Then exit plan mode and implement. If implementation diverges, update the plan in the same commit series — it is the audit record. When every step is done and the `verifier` agent passes, set `status: implemented` and commit `plan: mark <slug> implemented`.
