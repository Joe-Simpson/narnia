# sdlc plugin

The shared AI-native SDLC: `intent → spec → plan → code → verify`. Process: [docs/sdlc.md](../../docs/sdlc.md). Configuration contract: [docs/repo-contract.md](../../docs/repo-contract.md).

Every component reads the consuming repo's `.claude/sdlc.json`. Without that file the hooks do nothing and the skills tell you to run `/sdlc:adopt`.

## Skills

| Skill | Invoked by | What it does |
| ----- | ---------- | ------------ |
| `/sdlc:capture-intent [#issue]` | you | Writes `intent/<slug>.md`; prefills from a GitHub issue |
| `/sdlc:generate-spec <slug>` | you | Approved intent → `spec/<slug>.md` with testable acceptance criteria |
| `/sdlc:generate-plan <slug>` | you (plan mode) | Approved spec (or issue, on the bug fast path) → `plan/<slug>.md` |
| `/sdlc:fix-bug <slug>` | you | Failing test → commit → minimal fix → verify |
| `/sdlc:review-pr [base]` | you | Self-review of the branch against `REVIEW.md` |
| `/sdlc:pre-pr` | you or Claude | Runs every gate plus the repo's PR checklist |
| `/sdlc:security-review` | you or Claude | Generic web checklist + the repo's `securityChecklist` |
| `/sdlc:adr` | you or Claude | Next-numbered ADR in the repo's existing format |
| `/sdlc:generate-readme <dir>` | you | Short navigation README for a directory |
| `/sdlc:adopt` | you | Onboards a repo: `sdlc.json`, settings, REVIEW.md, PR template, CI, commitlint |
| `sdlc-compliance` | Claude, automatically | Checks the artifact chain before source edits |
| `tdd` | Claude, automatically | Red → Green → Refactor discipline |
| `conventional-commits` | Claude, automatically | Commit format and splitting rules |

Artifact templates are bundled beside their skills (`skills/*/template.md`); a repo can override them with `intent|spec|plan/_template.md`.

## Agents

Plugin agents are namespaced: spawn them as `sdlc:verifier` and `sdlc:pr-reviewer`.

| Agent | Use it for |
| ----- | ---------- |
| `verifier` | Independent PASS/FAIL after implementation: runs the gates, checks plan conformance and acceptance-criteria coverage. Never fixes |
| `pr-reviewer` | Independent severity-ranked review of a branch against `REVIEW.md`. Never approves or pushes |

## Hooks

| Hook | Event | Blocks when | Config keys |
| ---- | ----- | ----------- | ----------- |
| `guard-src-edit.sh` | PreToolUse Write/Edit | Editing under `srcPaths` without a committed `plan/<branch-slug>.md` (tooling branches exempt) | `enforcePlanGate`, `srcPaths`, `artifactRoot` |
| `guard-push.sh` | PreToolUse Bash | Any force-push; pushing main/master with failing tests | `gates.test`, `workdir` |
| `format-on-edit.sh` | PostToolUse Write/Edit | never — formats the edited file | `format`, `workdir` |
| `verify-done.sh` | Stop | Any `stopGate` command fails. Skips on re-entry, when no source changed vs the default branch, or when the same state already passed | `stopGate`, `gates`, `srcPaths`, `workdir` |

### Handoff (vendored, not a plugin hook)

`/sdlc:adopt` copies a `handoff` skill and two hooks (`handoff-start.sh` SessionStart, `handoff-stop.sh` Stop) from `skills/adopt/templates/handoff/` into each repo's own `.claude/`, because cloud sessions don't load plugins. Per branch they keep `.claude/handoff/<slug>.md` current: Stop blocks (exit 2) when the branch has work but its handoff is missing or stale; SessionStart prints it. They need no `sdlc.json` and are tested by `hooks/tests/run.sh`. Version marker: `sdlc-handoff v1`.

Shared helpers are in `hooks/lib/config.sh`. Test the hooks with `bash hooks/tests/run.sh`.
