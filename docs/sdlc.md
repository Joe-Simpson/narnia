# The AI-native SDLC

Every change flows through committed artifacts before source code is touched. Agents do most of the writing; humans approve each stage.

```
intent ──► spec ──► plan ──► code ──► verify ──► review ──► merge
 (why)    (what)   (how)    (TDD)   (verifier) (pr-reviewer + human)
```

## Stages

| Stage | Artifact | Skill | Human gate | Commit |
| ----- | -------- | ----- | ---------- | ------ |
| Intent | `intent/<slug>.md` | `/sdlc:capture-intent [#issue]` | Originator sets `status: approved` | `intent: add <slug>` |
| Spec | `spec/<slug>.md` | `/sdlc:generate-spec <slug>` | Product owner approves | `spec: add <slug>` |
| Plan | `plan/<slug>.md` | `/sdlc:generate-plan <slug>` (plan mode) | Engineer approves the plan | `plan: add <slug>` |
| Code | source + tests | `tdd` skill, `/sdlc:fix-bug` | — | `test:` then `feat:`/`fix:` |
| Verify | report | `verifier` agent | — | `plan: mark <slug> implemented` |
| Review | PR comments | `/sdlc:review-pr`, `pr-reviewer` agent | Human merges | — |

Each artifact references the one before it (`spec:` → `intent:`, plan → spec). The plan is the **audit record**: if the implementation diverges, the plan is updated in the same PR.

## Slugs

One slug names everything for a change: `intent/<slug>.md`, `spec/<slug>.md`, `plan/<slug>.md`, the branch `<type>/<slug>`, and the PR's `Slug:` line.

- Lowercase and hyphen-separated: `player-health-system`
- **Issue-linked repos** (`slug.issueLinked: true`) prefix the GitHub issue number: `94-player-career-tab`. The PR body also carries `Closes #94`.

## Bug fast path

When `bugFastPath` is on, a small, behaviour-restoring bug fix may skip intent and spec: the GitHub issue stands in for them and the plan's `spec:` field says `issue #<n>`. The plan and the failing-test-first rule still apply. If the fix changes intended behaviour, use the full chain.

## Branches & PRs

- Branch from an up-to-date default branch as `<type>/<slug>`; `<type>` is a commit type
- Tooling, CI and docs PRs use a `chore/`, `ci/`, `docs/`, `build/` or `style/` branch with `Slug: none`, and may not touch source paths
- The PR body's `Slug:` line wins over the branch name
- The **PR Slug** check (reusable workflow in this repo) fails a PR that touches source without a committed `plan/<slug>.md`

## Commits

Conventional commits — `<type>(<scope>): <subject>`, lowercase, imperative, ≤100 chars — with the extra types `intent`, `spec`, `plan`. commitlint enforces this in each repo's husky `commit-msg` hook. See the `conventional-commits` skill.

## Enforcement

The process is enforced in layers, so skipping one layer doesn't skip the rule:

| Rule | Skill (advisory) | Hook (local, blocking) | CI (remote, blocking) |
| ---- | ---------------- | ---------------------- | --------------------- |
| No source edit without a committed plan | `sdlc-compliance` | `guard-src-edit` (when `enforcePlanGate`) | PR Slug |
| Gates pass before finishing | `pre-pr` | `verify-done` (Stop) | repo `ci.yml` |
| No force-push; tests before pushing main | — | `guard-push` | branch protection |
| Commit format | `conventional-commits` | husky `commit-msg` | `pr-reviewer` flags violations |
| Consistent formatting | — | `format-on-edit` | repo `format:check` |

## Where knowledge lives

| Kind of knowledge | Home |
| ----------------- | ---- |
| The process itself | this file + the `sdlc` plugin |
| Repo commands, architecture, conventions | the repo's `CLAUDE.md` (keep it short) |
| Stack rules and gotchas | the repo's `.claude/skills/<stack>/` (loaded only when relevant) |
| Why a decision was made | the repo's `docs/adr/` (`/sdlc:adr`) |
| Review policy | the repo's `REVIEW.md` |

When review catches a mistake the instructions should have prevented, fix the instruction (CLAUDE.md or a stack skill) in a prerequisite PR.
