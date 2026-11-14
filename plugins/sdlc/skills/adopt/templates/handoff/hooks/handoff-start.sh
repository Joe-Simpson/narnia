#!/usr/bin/env bash
# sdlc-handoff v1 — SessionStart hook (startup|resume), vendored by /sdlc:adopt.
# Prints this branch's handoff, if one exists, so it lands in the session's context. Silent otherwise.
cat >/dev/null
cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
branch=$(git branch --show-current 2>/dev/null)
[ -n "$branch" ] || exit 0
file=".claude/handoff/${branch#*/}.md"
[ -f "$file" ] || exit 0
echo "Handoff from a previous session on branch $branch ($file). Continue from its Next steps and update it before you finish:"
echo
cat "$file"
exit 0
