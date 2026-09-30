# 0001 — Distribute the SDLC as a Claude Code plugin marketplace

**Date:** 2026-09-30
**Status:** Accepted

## Context

roaming-nova, butters and skittles each carried their own copies of SDLC skills, agents and hooks, and those copies had drifted (skittles had none at all). The apps are separate git repos that sit side by side in `~/Narnia`. Sessions run locally, in claude.ai/code cloud sessions, and in GitHub Actions — the last two see only the single app repo, never its parent directory.

## Decision

Make Narnia its own GitHub repo acting as a Claude Code **plugin marketplace** with one plugin, `sdlc`. App repos enable it from their committed `.claude/settings.json` (`extraKnownMarketplaces` + `enabledPlugins`). Repo-level files a plugin can't ship are handled by a reusable GitHub workflow (slug check) and templates installed by `/sdlc:adopt`.

Alternatives considered:

- **Parent-directory inheritance** (`~/Narnia/CLAUDE.md` and `.claude/`): no publishing needed, but only works for local sessions launched from this machine, and project settings/hooks don't cascade from parent directories. Rejected.
- **Vendored copies via a sync script**: works everywhere, but reintroduces the drift and duplication this repo exists to remove. Rejected.

## Consequences

- One place to change a skill, agent or hook; apps pick it up on the next marketplace refresh
- Plugin skills are namespaced (`/sdlc:review-pr`), so they never collide with built-ins or repo-local skills
- Narnia must be reachable from wherever sessions run — if it is private, cloud sessions need GitHub access to it, and the reusable workflow needs Actions access granted to the owner's repos
- Changes affect every adopted repo at once; releases are versioned and the workflow is pinned to `@v1`
