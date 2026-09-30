---
name: fix-bug
description: TDD bug fix — prove the bug with a failing test, commit it, then make the minimal fix. Enforces the artifact chain (or the bug fast path).
argument-hint: "<slug>"
disable-model-invocation: true
---

# Fix bug (test first)

**No bug fix lands without a regression test that failed before the fix.** The test is the proof the bug existed and the proof it is gone.

## 1. Confirm the artifacts

Read `.claude/sdlc.json`. `<artifactRoot>/plan/<slug>.md` must be committed on the current `fix/<slug>` branch.

- Full chain: `intent/<slug>.md` and `spec/<slug>.md` exist too; the spec's acceptance criteria are the test targets.
- Bug fast path (`bugFastPath: true`): the plan links the issue (`spec: issue #<n>`); the issue's expected behaviour is the test target.

If the plan is missing, stop: enter plan mode and run `/sdlc:generate-plan <slug>` (and `/sdlc:capture-intent #<n>` first if there's no issue or intent).

## 2. Investigate before touching code

1. Locate the exact failing code path — read the file, not just the error
2. State the root cause in one sentence
3. Consider at least two fixes; pick the simplest, most targeted one (no unrelated cleanup)
4. Load the repo's `stackSkills` for testing patterns and known gotchas

## 3. RED — write the failing test

- Put it where the repo's conventions say (co-located or mirrored test tree — check `CLAUDE.md` / stack skills)
- Name it after the defect, e.g. `it('keeps all-day events visible after midnight rollover')`
- Run just that test and confirm it fails **for the right reason** (the assertion, not a setup error). If it passes, the test is wrong or the bug is already fixed — stop and investigate.
- Commit: `test(<scope>): reproduce <short description>`

## 4. GREEN — minimal fix

- Change only what `plan/<slug>.md` names; update the plan if reality differs
- Run the test, then the full test gate for regressions
- Commit: `fix(<scope>): <short description>` (use `fix(#<n>): …` if the repo scopes by issue)

## 5. REFACTOR (optional) — separate `refactor(<scope>):` commit, tests green after each change

## 6. Verify

Run every gate in `.claude/sdlc.json` → `gates`, then spawn the `verifier` agent for an independent check. If the bug was caused by a non-obvious gotcha, record it in the matching stack skill so the next agent doesn't repeat it.
