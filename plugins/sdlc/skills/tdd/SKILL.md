---
name: tdd
description: Test-driven development discipline (Red → Green → Refactor). Use when writing or changing tests, fixing a bug, or adding any new unit of logic.
---

# TDD

## Red → Green → Refactor

1. **Red** — write a failing test that describes the desired behaviour; run just that test and confirm it fails for the right reason (the assertion, not a setup error)
2. **Green** — write the minimum code to pass it; run the test, then the full test gate
3. **Refactor** — remove duplication and improve names without changing behaviour; tests stay green after each change

Write the test first even when the fix looks obvious — it becomes the regression guard. Commit tests and implementation as separate conventional commits when practical (`test(scope): …` then `feat|fix(scope): …`).

## Where tests go and how to write them

Stack-specific rules — file location, mocking patterns, environment quirks, coverage thresholds — live in the repo, not here. Before writing tests, load the testing guidance from the repo's `CLAUDE.md` and the `stackSkills` in `.claude/sdlc.json`. The test commands are in `sdlc.json` → `gates`.

## What good tests look like

- Test observable behaviour (inputs → outputs, rendered text, HTTP status, persisted rows), not implementation details
- One behaviour per test; name it as a sentence describing that behaviour
- Arrange / act / assert (or given / when / then) — visibly separated
- Cover every conditional branch and error path in new logic
- Use realistic fixtures typed against the real interfaces
- Don't test framework internals, configuration files, or pure bootstrapping code

## Coverage

Coverage thresholds are the repo's (see `CLAUDE.md` / `gates.coverage`). A coverage drop is a failure even when every test passes — add tests, don't lower thresholds.
