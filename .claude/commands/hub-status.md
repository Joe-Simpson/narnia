---
description: Show branch, worktree and PR state of every app repo against the hippocampus registry
disable-model-invocation: true
---

Report the state of the command centre. Read-only.

1. For each `hippocampus/repos/*.md` (skip `index.md`, `_template.md`): current branch and dirty/clean (`git -C <repo> status -sb`), short HEAD vs the `repo@sha` in its `sources`, and whether `stale_after` has passed.
2. All worktrees under `~/Narnia/.worktrees/` with branch, ahead/behind and dirty state.
3. Open PRs per repo if `gh` is available (`gh pr list -R <remote> --state open`).
4. Summarise as one table plus a short list of things needing attention (stale registry entries, dirty worktrees, merged branches whose worktree still exists, uncommitted changes in hippocampus).

For remote-session drift (fetching, remote handoffs, reconciling the registry) use `/hub-sync`; to resume work use `/pickup`; to end a session cleanly use `/handoff`.
