---
name: adopt
description: Onboard a repo onto the shared SDLC — writes .claude/sdlc.json, enables the plugin, and installs the repo-level files a plugin can't ship (REVIEW.md, PR template, slug CI check, commitlint, artifact directories).
disable-model-invocation: true
---

# Adopt the SDLC in this repo

Run from the repo's **git root** (where cloud sessions and CI start). Work on a `chore/adopt-sdlc` branch; the PR uses `Slug: none`.

Templates live in this skill's `templates/` directory. `{{PLACEHOLDERS}}` must be filled — never commit a template with placeholders left in.

## 1. Survey (read-only)

- Package layout: is the app at the git root or in a subdirectory (→ `workdir`)? Which directories are source (→ `srcPaths`)?
- Available npm scripts for typecheck, lint, test, coverage, format (→ `gates`, `format`)
- Existing `CLAUDE.md`, `.claude/`, `.husky/`, `.github/`, `docs/adr/`, commit style (`git log --oneline -20`)
- Issue-driven? (`gh issue list --limit 5`) → `slug.issueLinked` and pattern `^[0-9]+-[a-z0-9]+(-[a-z0-9]+)*$`
- Stack-specific rules already written down (e.g. gotchas in `CLAUDE.md`) that belong in local stack skills

Summarise findings and proposed config values; get the user's confirmation before writing.

## 2. Claude config

| Write | From | Notes |
| ----- | ---- | ----- |
| `.claude/sdlc.json` | `templates/sdlc.json` | Fill from the survey. Leave `enforcePlanGate: true` unless the user opts out |
| `.claude/settings.json` | `templates/settings.json` | Merge into an existing file; add allow rules for each gate command |
| `.claude/security-checklist.md` | — | Stack-specific checks only (auth model, DB policies, platform secrets). The plugin covers generic web checks |
| `.claude/skills/<stack>/SKILL.md` | — | One skill per stack area; list each in `stackSkills`. Move gotchas out of `CLAUDE.md` into these |

## 3. Repo-level files

| Write | From |
| ----- | ---- |
| `intent/README.md`, `spec/README.md`, `plan/README.md` (under `artifactRoot`) | `templates/artifacts/*-README.md` |
| `REVIEW.md` | `templates/REVIEW.md` — fill the stack pass (e.g. "Data access — RLS policies and query patterns per the supabase-standards skill") |
| `.github/claude-review.md` | `templates/github/claude-review.md` |
| `.github/pull_request_template.md` | `templates/github/pull_request_template.md` (drop `Closes #` if not issue-driven) |
| `.github/workflows/pr-slug.yml` | `templates/github/workflows/pr-slug.yml` |
| `<workdir>/.commitlintrc.js` + `.husky/commit-msg` (in the active hooks path) | `templates/commitlintrc.js`, `templates/husky-commit-msg`; install `@commitlint/cli @commitlint/config-conventional` (and `husky` if absent) as devDependencies in `workdir` |

Git hooks run from wherever `git config core.hooksPath` points — check it rather than assuming. If `workdir` isn't `.`, commitlint and its config live in `workdir` (that's where `node_modules` is), so the `commit-msg` hook must make the message path absolute and `cd` there:

```sh
msg="$1"; case "$msg" in /*) ;; *) msg="$PWD/$msg" ;; esac
cd <workdir> && npx --no -- commitlint --edit "$msg"
```

## 4. Instructions

- Add an **SDLC** section to `CLAUDE.md` (≤15 lines): the chain, slug format, branch `<type>/<slug>`, commit format, PR `Slug:` line, and "no source edits without a committed plan". Link to the Narnia `docs/sdlc.md` instead of restating it.
- If `CLAUDE.md` is not at the git root, add a thin root `CLAUDE.md` that imports it (`@<workdir>/CLAUDE.md`).
- Update `CONTRIBUTING.md` (if present) so it doesn't contradict the new process.

## 5. Verify and commit

- `jq . .claude/sdlc.json .claude/settings.json` parse cleanly; no `{{` left: `grep -rn '{{' .claude REVIEW.md .github intent spec plan`
- Every gate command runs from `workdir`
- A deliberately bad commit message is rejected by commitlint
- Commit as `chore: adopt shared sdlc` (split if large: `ci:`, `docs:`, `build:`), open the PR with `Slug: none`, and check the `PR Slug` job passes
