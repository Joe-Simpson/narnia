---
description: Write the hub handoff so the next session (here or elsewhere) can pick up where this one stopped
disable-model-invocation: true
argument-hint: [slug for the handoff file]
---

Write a hub handoff. Optional slug: $ARGUMENTS (default: a short kebab-case name for this session's focus).

1. **Gather** (same collection as `/hub-sync` steps 1-2, but do not reconcile): open dispatches in `hippocampus/dispatches/` (`stage: planned|in-progress`), worktrees under `~/Narnia/.worktrees/`, each repo's current branch and any `.claude/handoff/<slug>.md` for it (local worktrees and remote `origin/*` branches), and open PRs.
2. **Repo handoffs.** For every worktree or branch with unfinished work whose repo handoff is missing or stale, say so; offer to run the `handoff` skill there (the repo's own Stop hook will insist anyway). Do not write into repos without the user's say-so.
3. **Draft** `hippocampus/handoffs/YYYY-MM-DD-<slug>.md` from `handoffs/_template.md`: Focus, Open dispatches (links), Repo handoffs table (repo, branch, path, head SHA, stage, origin), Pending decisions, Next actions (concrete, startable cold). Link, never copy, repo detail. `generated: {by: claude-code, at: <now>}`; never a `human:` actor.
4. **Supersede.** Set the previous `open` handoff to `stage: superseded`, `status: deprecated`, add it to the new one's `sources`, and update `handoffs/index.md` and `log.md`. There must be exactly one `open`.
5. **Validate and commit.** `cd hippocampus && npm run okf:check`; show the user the handoff and commit it in the hippocampus repo after they agree.
6. **Going remote?** If the next session runs in claude.ai/code, the repo handoff must be committed and pushed first (`claude --cloud` clones the remote branch, not the local checkout), then start it with `claude --cloud "Continue per .claude/handoff/<slug>.md"` from that repo. Print the exact commands but do not push anything without explicit confirmation.
