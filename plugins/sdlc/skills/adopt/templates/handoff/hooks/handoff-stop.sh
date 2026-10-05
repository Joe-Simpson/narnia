#!/usr/bin/env bash
# sdlc-handoff v1 — Stop hook, vendored into the repo by /sdlc:adopt so it also runs in cloud sessions.
#
# On a feature branch with commits ahead of the default branch (or a dirty tree), block the stop
# until .claude/handoff/<slug>.md is current, so the next session can pick up where this one ended.
# Exit 2 blocks; every other path exits 0. Skips on re-entry (stop_hook_active).
input=$(cat)
case "$input" in *'"stop_hook_active":true'* | *'"stop_hook_active": true'*) exit 0 ;; esac

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
branch=$(git branch --show-current 2>/dev/null)
[ -n "$branch" ] || exit 0 # detached HEAD

default=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
default=${default#origin/}
if [ -z "$default" ]; then
  for c in main master; do
    if git show-ref --verify --quiet "refs/heads/$c" || git show-ref --verify --quiet "refs/remotes/origin/$c"; then
      default=$c
      break
    fi
  done
fi
[ -n "$default" ] || exit 0
[ "$branch" != "$default" ] || exit 0

base=$default
git show-ref --verify --quiet "refs/remotes/origin/$default" && base="origin/$default"
ahead=$(git rev-list --count "$base..HEAD" 2>/dev/null || echo 0)
dirty=$(git status --porcelain -- . ':(exclude).claude/handoff' 2>/dev/null | head -1)
[ "$ahead" -gt 0 ] || [ -n "$dirty" ] || exit 0

slug=${branch#*/}
file=".claude/handoff/$slug.md"

# Current = rewritten in the working tree, or (with a clean tree) last touched by HEAD itself.
if [ -f "$file" ]; then
  [ -n "$(git status --porcelain -- "$file" 2>/dev/null)" ] && exit 0
  [ -z "$dirty" ] && [ "$(git log -1 --format=%H -- "$file" 2>/dev/null)" = "$(git rev-parse HEAD)" ] && exit 0
  why="is out of date"
else
  why="is missing"
fi

echo "handoff: $file $why. Write it (Goal, Done, Next steps, Decisions, Blockers, How to verify; see the handoff skill), commit it, then finish." >&2
exit 2
