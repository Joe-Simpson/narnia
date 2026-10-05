---
name: hippocampus
description: Read or write the hippocampus shared-memory bundle (~/Narnia/hippocampus, OKF v0.2). Use when you need cross-repo context (repo registry, shared conventions, past dispatches, learnings), when saving a durable lesson, or when editing any markdown under hippocampus/.
---

# Hippocampus

Shared cross-repo memory in Open Knowledge Format. Full rules: `hippocampus/CLAUDE.md` and `hippocampus/conventions/memory-protocol.md`.

## Reading
1. Open `hippocampus/index.md`, then one directory's `index.md`, then only the concepts that match.
2. Check `status`, `stale_after`, `verified`. If a `Repo` entry is stale, re-verify against the repo and bump the date before relying on it.

## Writing (hub session only; workers propose)
1. Copy the directory's `_template.md`. Types and homes: `Repo`→`repos/`, `Decision`→`decisions/`, `Convention`→`conventions/`, `Runbook`→`runbooks/`, `Learning`→`learnings/`, `Dispatch`→`dispatches/`.
2. Fill `type`, `title`, one-sentence `description`, non-empty `tags`, `status`, `generated: {by: claude-code, at: <ISO timestamp>}`. Never write a `human:` actor.
3. Link with bundle-relative `/` paths; cite repo facts as `repo@sha` in `sources`.
4. Add the entry to the directory's `index.md` (no front matter) and a line to `log.md` under today's `## YYYY-MM-DD` heading.
5. `cd hippocampus && npm run okf:check` must pass, then commit there (it is its own repo).

Do not save what the repo already records (code, git history, its `CLAUDE.md`) or session-only context.
