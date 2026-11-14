#!/usr/bin/env bash
# Open (or attach to) the Narnia hub tmux session: hub + one window per app repo + one per worktree.
set -euo pipefail

SESSION=narnia
ROOT="$HOME/Narnia"
REPOS=(butters roaming-nova skittles taste-the-rainbow)

go() {
  if [[ -n "${TMUX:-}" ]]; then tmux switch-client -t "$SESSION"; else tmux attach -t "$SESSION"; fi
}

if tmux has-session -t "$SESSION" 2>/dev/null; then
  go
  exit 0
fi

tmux new-session -d -s "$SESSION" -n hub -c "$ROOT"

for repo in "${REPOS[@]}"; do
  [[ -d "$ROOT/$repo" ]] && tmux new-window -t "$SESSION" -n "$repo" -c "$ROOT/$repo"
done

for repo in "${REPOS[@]}"; do
  [[ -e "$ROOT/$repo/.git" ]] || continue
  while IFS= read -r line; do
    path="${line#worktree }"
    [[ "$path" == "$ROOT/.worktrees/"* ]] || continue
    tmux new-window -t "$SESSION" -n "$repo:$(basename "$path")" -c "$path"
  done < <(git -C "$ROOT/$repo" worktree list --porcelain | grep '^worktree ')
done

tmux select-window -t "$SESSION:hub"
go
