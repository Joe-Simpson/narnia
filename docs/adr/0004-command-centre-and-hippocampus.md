# 0004 — Command centre and hippocampus shared memory

**Date:** 2026-10-04
**Status:** Accepted

## Context

`~/Narnia` now orchestrates several app repos and worktrees from one session. ADR-0001 rejected parent-directory inheritance for the SDLC because project settings and hooks do not cascade and cloud sessions only see one repo. The hub still needs cross-repo memory, a worktree convention and a dispatch routine. roaming-nova already follows Google's Open Knowledge Format (its ADR-0011).

## Decision

- **Hub tooling is local-only** in `~/Narnia/.claude/` (commands, a worker agent, a skill, one Stop hook). It coordinates; each repo remains self-sufficient under its own `CLAUDE.md` and the `sdlc` plugin.
- **Shared memory is `hippocampus/`**, a separate private git repo (gitignored here), an OKF v0.2 bundle with a house profile and a checker ported from roaming-nova (`npm run okf:check`). Types: `Repo`, `Decision`, `Convention`, `Runbook`, `Learning`, `Dispatch`.
- **Orchestrator-worker:** max 5 concurrent workers, one worktree each at `.worktrees/<repo>/<slug>`, non-overlapping owned paths, plan approval before fan-out. Only the hub writes to hippocampus; workers return proposed memory.
- **No change to `plugins/sdlc`**, which stays stack-agnostic and cloud-safe.

Alternatives: keep memory in the public Narnia repo (leaks cross-repo notes, mixes with plugin content); extend the plugin with a knowledge feature (cloud sessions could not see local-only memory, and the profile is not stack-agnostic); rely on auto-memory alone (personal, unstructured, per-project).

## Consequences

- Cloud and CI runs never see hippocampus or the hub; anything a repo needs alone stays in that repo.
- The OKF profile is a fork of roaming-nova's and can drift; the decision is recorded in hippocampus `decisions/0001`.
- Registry entries go stale, so each carries `stale_after` and the checker warns.
