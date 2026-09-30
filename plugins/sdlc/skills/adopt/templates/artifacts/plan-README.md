# plan/

The "how" layer and the audit record: the step-by-step implementation plan for a slug.

- Create in plan mode with `/sdlc:generate-plan <slug>`
- **No source edits without a committed `plan/<slug>.md`** — the `guard-src-edit` hook and the `PR Slug` CI check both enforce this
- Lifecycle: `planned → implemented`. If implementation diverges, update the plan in the same PR
- Commits: `plan: add <slug>`, `plan: mark <slug> implemented`

Process reference: https://github.com/Joe-Simpson/narnia/blob/main/docs/sdlc.md
