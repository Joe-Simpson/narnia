# 0003 — Per-repo configuration in `.claude/sdlc.json`

**Date:** 2026-09-30
**Status:** Accepted

## Context

The original hooks and commands hard-coded roaming-nova's paths and commands (`src/`, `npm run test:coverage`). Repos differ: skittles lives in a subdirectory and uses `npm run test:run`; butters runs two test suites and has no coverage gate.

## Decision

Plugin components read a single file, `.claude/sdlc.json`, for everything that varies (paths, gate commands, toggles, stack skills). Hooks exit 0 when the file is absent. Stack-specific knowledge stays in repo-local skills referenced by `stackSkills` rather than in the plugin.

Alternatives: environment variables (not committed, invisible to cloud sessions), or reading commands out of `CLAUDE.md` prose (unreliable for hooks, which are scripts).

## Consequences

- One plugin serves repos with different layouts and toolchains
- Enabling the plugin somewhere it isn't configured is harmless
- The schema is a contract (`docs/repo-contract.md`); breaking changes need a major version bump
