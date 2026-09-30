# spec/

The "what" layer: requirements, testable acceptance criteria, design and security notes for an approved intent.

- Create with `/sdlc:generate-spec <slug>`
- Lifecycle: `draft → approved`. `/sdlc:generate-plan` refuses anything not `approved`
- Acceptance criteria (`AC-n`) are the targets for tests and for the `verifier` and `pr-reviewer` agents
- Commits: `spec: add <slug>`, `spec: update <slug>`
- Bug fast path: small bug fixes may skip the spec — the plan links the issue instead

Process reference: https://github.com/Joe-Simpson/narnia/blob/main/docs/sdlc.md
