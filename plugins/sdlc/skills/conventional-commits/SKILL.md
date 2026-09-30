---
name: conventional-commits
description: Conventional commit format and commit-splitting rules, including the SDLC artifact commit types (intent, spec, plan). Use when about to run git commit, writing a commit message, or reviewing a PR's commit history.
---

# Conventional commits

```
<type>(<optional scope>): <subject>

<optional body>
```

## Types

| Type | Use for |
| ---- | ------- |
| `feat` | New user-visible feature |
| `fix` | Bug fix in production code |
| `test` | Tests only — no production code |
| `refactor` | Restructuring without behaviour change |
| `perf` | Performance improvement |
| `docs` | Documentation only |
| `style` | Formatting / whitespace only |
| `chore` | Maintenance (deps, config tweaks) |
| `ci` | CI/CD configuration |
| `build` | Build system (bundler, tsconfig, package.json) |
| `intent` / `spec` / `plan` | SDLC artifact commits |

## Rules

- Subject **starts lowercase** (proper nouns later are fine), is **imperative** ("add", not "added"), **≤100 chars**, no trailing period
- Scope is optional: a module (`feat(scoring): …`) or, in issue-linked repos, the issue (`fix(#94): …`)
- `commitlint` enforces this via the husky `commit-msg` hook where installed — never bypass it with `--no-verify`
- With squash-merge, the PR title becomes the commit on the default branch — keep PR titles in this format too

## SDLC artifact commits

```
intent: add <slug>
spec: add <slug>
plan: add <slug>
plan: mark <slug> implemented
```

## Splitting

Each commit is one logical, independently revertable change.

```
test(physics): add failing test for gravity acceleration
feat(physics): implement gravity acceleration
refactor(physics): extract gravity constant
```

Never bundle: artifact commits with source commits; formatting with logic changes; a feature with an unrelated refactor.
