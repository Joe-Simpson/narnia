---
description: Plan and fan out a goal across app repos and worktrees, with approval before any worker starts
disable-model-invocation: true
argument-hint: <goal>
---

Orchestrate: $ARGUMENTS

Follow hippocampus `conventions/dispatch.md` and `conventions/worktrees.md`.

1. **Context.** Read `hippocampus/index.md`, the `Repo` entries for the repos involved (re-verify any that are stale), and relevant conventions and learnings. Say which concepts you used.
2. **Plan.** Decompose the goal into at most 5 workers, one per repo/worktree, with non-overlapping owned paths. For each: repo, slug, branch, owned paths, acceptance criteria, the repo's process entry point, and dependencies between workers. Fix any cross-repo contract (API shape, shared types) up front.
3. **Approval.** Present the plan and wait for the user to approve or change it. Do not create worktrees or spawn anything before that.
4. **Fan out.** Create worktrees with `/worktree create`, then spawn independent workers in one message using the `repo-worker` agent, each with a full brief (goal, worktree path, owned paths, acceptance, return format). Run dependent workers after their dependencies finish.
5. **Fan in.** Review each report and diff yourself; re-run checks where it matters. Merge in dependency order only with the user's go-ahead.
6. **Remember.** Draft a `Dispatch` entry (goal, workers table, outcome) plus any worthwhile "Proposed memory" from reports, and save them with `/remember`.
