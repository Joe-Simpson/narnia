---
description: Create, list or remove a per-worker git worktree under ~/Narnia/.worktrees
disable-model-invocation: true
argument-hint: create <repo> <slug> | list | remove <repo> <slug>
---

Manage worktrees per hippocampus `conventions/worktrees.md`. Arguments: $ARGUMENTS

Repo directory for `<repo>` is `~/Narnia/<repo>` (for `skittles` the git repo is `~/Narnia/skittles`; the app is in its `skittles-app/` subdirectory). Worktrees live at `~/Narnia/.worktrees/<repo>/<slug>` on branch `claude/<slug>`.

- **create**: confirm the repo exists and the main checkout is clean enough to branch from (`git -C <repo> status --short`); `git -C <repo> fetch` if it has a remote; `git -C <repo> worktree add ~/Narnia/.worktrees/<repo>/<slug> -b claude/<slug> <default-branch>`; run the repo's install command inside the worktree (see its hippocampus `Repo` entry); print the path.
- **list**: `git -C <repo> worktree list` for every repo in `hippocampus/repos/`, showing only worktrees under `.worktrees/`.
- **remove**: refuse if the worktree has uncommitted changes or unpushed commits unless the user says otherwise; show what will be removed and ask before `git worktree remove` and `git branch -d`.

Never force-remove or delete a branch with unmerged work without explicit confirmation.
