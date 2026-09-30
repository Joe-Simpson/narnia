---
name: pre-pr
description: Run the repo's full local quality gate and self-review checklist before committing, pushing or opening a PR. Use before any PR.
---

# Pre-PR gate

## 1. Run every gate

Read `.claude/sdlc.json`. From `workdir`, run each command in `gates` (typecheck, lint, test, coverage, …). Every one must pass; lint warnings count as failures if the repo uses `--max-warnings 0`. If the change touches build config or dependencies, also run the repo's build.

## 2. Artifact chain

- Branch is `<type>/<slug>` from an up-to-date default branch
- For source changes: `plan/<slug>.md` is committed and matches what was built (update it if not); status set to `implemented` when done
- Every spec acceptance criterion has a test or a documented manual check

## 3. Repo checklist

Walk the PR checklist in the repo's `CLAUDE.md` / `CONTRIBUTING.md` line by line and fix anything that fails. Typical items: docs/setup updated for new env vars, ADR written for significant decisions, changelog updated, no stray `console.log`.

## 4. Commits and PR body

- Conventional commits, one logical change each (see the `conventional-commits` skill)
- PR body from the repo template: `Slug: <slug>` (or `none` for tooling/docs), plus `Closes #<n>` for issue-linked work

Optionally run `/sdlc:review-pr` or spawn the `pr-reviewer` agent for a findings pass before opening the PR.
