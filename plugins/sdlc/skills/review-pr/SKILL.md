---
name: review-pr
description: Review the current branch against the default branch using the repo's REVIEW.md policy — plan compliance, correctness, security, stack rules, spec compliance.
argument-hint: "[base-branch]"
disable-model-invocation: true
---

# Review PR

For an independent review in a fresh context, spawn the `pr-reviewer` agent instead; use this skill to self-review before opening a PR.

## 1. Gather context

1. Base = `$ARGUMENTS` or the default branch. Run `git diff <base>...HEAD` and note every changed file.
2. Resolve the slug: PR body `Slug:` line (if a PR exists: `gh pr view --json body`), else the branch name `<type>/<slug>`, else `intent|spec|plan/<slug>.md` paths in the diff. `Slug: none` means a tooling/docs PR with no artifacts.
3. Read `intent/`, `spec/`, `plan/<slug>.md`, the repo's `REVIEW.md`, `CLAUDE.md`, and the `stackSkills` from `.claude/sdlc.json`.

## 2. Run the passes

Use the pass list and order in `REVIEW.md`. If the repo has none, use:

1. **Plan compliance** — every change is accounted for in the plan; flag undeclared changes and unrecorded plan drift
2. **Correctness** — logic errors, edge cases, off-by-one, unreachable code, missing tests for new logic
3. **Security** — `/sdlc:security-review` plus the repo's `securityChecklist`
4. **Stack rules** — the conventions in the `stackSkills` and `CLAUDE.md`
5. **Spec compliance** — map each acceptance criterion to the diff and tests; flag any unsatisfied

Also check commit subjects follow conventional commits (hooks can be bypassed locally).

## 3. Verify, then report

Confirm every Critical/Important finding against the code (trace call sites, check for covering tests). Drop anything you can't back with evidence; downgrade uncertain items to Suggestion.

Group findings Critical → Important → Suggestion. For each: **File** `path:line`, **Finding** (what and why it matters), **Suggestion** (required for Critical/Important). Close with `Summary: N Critical, M Important, P Suggestions`.

Do not approve, push, or edit files. If a finding is a mistake the repo's instructions should have prevented, recommend the instruction update (REVIEW.md feedback loop).
