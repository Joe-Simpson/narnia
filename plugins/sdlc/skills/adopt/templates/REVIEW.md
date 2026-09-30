# Review Policy

All PRs receive an automated review pass before human sign-off. The agent that wrote the code cannot approve its own PR.

## Finding Severity

| Level | Meaning | Gate |
| ----- | ------- | ---- |
| **Critical** | Breaks behaviour, leaks data, or violates a policy | Blocks merge |
| **Important** | Logic error, security gap, or spec divergence | Blocks merge or needs an explicit written waiver |
| **Suggestion** | Style, performance hint, or minor concern | Does not block merge |

Reserve Important and above for findings that break behaviour, leak data or breach a policy. Style nits are Suggestions.

## Automated Review Passes

Run in this order on every PR (`/sdlc:review-pr` locally, the `pr-reviewer` agent, or the CI automation following `.github/claude-review.md`):

1. **Plan compliance** — every change is accounted for in `plan/<slug>.md`; no undeclared changes
2. **Correctness** — logic errors, edge cases, off-by-one, unreachable code, untested new logic
3. **Security** — `/sdlc:security-review` plus `{{SECURITY_CHECKLIST}}`
4. **{{STACK_PASS_NAME}}** — {{STACK_PASS_DESCRIPTION}}
5. **Spec compliance** — every acceptance criterion in `spec/<slug>.md` (or the linked issue on the bug fast path) is demonstrably satisfied

## Human Review Focus

- Does the change achieve what `intent/<slug>.md` (or the issue) described?
- Is the risk acceptable for the project's current stage?
- Are any Important/Critical waivers adequately justified?

## Feedback Loop

When a recurring mistake reaches review that the repo's instructions should have caught, update `CLAUDE.md` or the relevant stack skill in `.claude/skills/` — in a prerequisite PR, before the feature PR merges.
