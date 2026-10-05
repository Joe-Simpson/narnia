# 0005 — Session handoff, vendored into repos

**Date:** 2026-10-05
**Status:** Accepted

## Context

Sessions need to pick up where others stopped, including sessions run remotely in claude.ai/code on a single repo. The docs for cloud sessions say: one repo clone, no access to `~/Narnia` or hippocampus, **plugins and marketplaces declared in `.claude/settings.json` are not installed**, while repo-committed `CLAUDE.md`, `.claude/{skills,agents,commands}` and (single-repo sessions) `settings.json` hooks do run. Work done there drifts from the hub's shared memory unless it leaves a trail the hub can find.

## Decision

- **Repo-level handoff:** `.claude/handoff/<slug>.md` per branch, committed on the branch, so a remote session pushes it and the hub can fetch it.
- **Vendored, not plugin-shipped.** A `handoff` skill and two hooks (SessionStart prints the handoff; Stop blocks until it is current) are copied into each repo by `/sdlc:adopt` from `skills/adopt/templates/handoff/`, carrying an `sdlc-handoff vN` marker. This is the one place the plugin deliberately ships files into repos for behaviour, because a plugin component would be inert in the cloud.
- **No new `sdlc.json` keys.** The hooks are self-contained bash + git.
- **Hub side:** a general handoff in hippocampus links to repo handoffs; `/hub-sync` and an offline `okf:drift` check compare the registry's `repo@sha` with each repo's HEAD (see hippocampus decision 0002).

Alternatives: plugin-only handoff (silently absent in cloud sessions); one `HANDOFF.md` per repo (conflicts between parallel branches); appending to the plan file (only works where the SDLC chain exists).

## Consequences

- Vendored copies can lag the template; the marker lets `/hub-sync` flag them, and re-running adopt refreshes them. Plugin 1.1.0 (minor: new files, no breaking `sdlc.json` change).
- The plugin's own gates are still local-only; vendoring more of the SDLC for cloud use is a separate decision.
- A repo's Stop hook now blocks ending a session on a feature branch until the handoff is current (bounded by `stop_hook_active`).
