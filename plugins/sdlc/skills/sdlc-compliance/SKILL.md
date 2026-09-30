---
name: sdlc-compliance
description: Enforce the intent → spec → plan artifact chain before any source file is modified. Use when starting an implementation task, beginning a coding session, or about to create, edit or delete a file under the repo's source paths (.claude/sdlc.json srcPaths).
---

# SDLC compliance

Applies only in repos with `.claude/sdlc.json`. Read it for `srcPaths`, `artifactRoot`, `bugFastPath`.

## Before editing source

Resolve the slug from the branch (`<type>/<slug>`). Then check:

1. `plan/<slug>.md` exists **and is committed** on this branch
2. Full chain: the plan references `spec/<slug>.md`, which references `intent/<slug>.md`, both `approved`
3. Bug fast path (`bugFastPath: true`, `fix/` branch): the plan references `issue #<n>` instead of a spec

Tooling branches (`chore/`, `ci/`, `docs/`, `build/`, `style/`) carry `Slug: none` and must not touch source paths.

The `guard-src-edit` hook blocks source edits without a committed plan when `enforcePlanGate` is on — but don't wait to be blocked. If the chain is incomplete, stop and tell the user what is missing:

| Missing | Next step |
| ------- | --------- |
| branch  | `git switch -c <type>/<slug> origin/<default>` |
| intent  | `/sdlc:capture-intent [#issue]` |
| spec    | `/sdlc:generate-spec <slug>` |
| plan    | plan mode, then `/sdlc:generate-plan <slug>` |

## During implementation

- The plan is the audit record. If the approach diverges, update `plan/<slug>.md` in the same PR
- Tick off steps in the plan as they are completed
- Do not declare the task complete until every gate in `sdlc.json` passes and the `verifier` agent returns PASS

## After implementation

Set the plan's status to `implemented` and commit `plan: mark <slug> implemented`.
