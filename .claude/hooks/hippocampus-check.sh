#!/usr/bin/env bash
# Stop hook (hub): block ending the session while hippocampus has uncommitted, non-conformant changes.
# Inert when hippocampus or its dependencies are absent, or has no pending changes.
input=$(cat)
case "$input" in *'"stop_hook_active":true'* | *'"stop_hook_active": true'*) exit 0 ;; esac

root="${CLAUDE_PROJECT_DIR:-$PWD}/hippocampus"
[ -f "$root/package.json" ] && [ -d "$root/node_modules" ] || exit 0
[ -n "$(git -C "$root" status --porcelain 2>/dev/null)" ] || exit 0

if ! out=$(cd "$root" && npm run -s okf:check 2>&1); then
  echo "hippocampus has OKF errors; fix them, then run 'npm run okf:check' in hippocampus/." >&2
  echo "$out" | head -20 >&2
  exit 2
fi
exit 0
