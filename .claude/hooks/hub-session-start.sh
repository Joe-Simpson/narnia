#!/usr/bin/env bash
# SessionStart hook (hub): tell the session where the last one stopped and which repos have moved.
# Output becomes session context. Inert when hippocampus or its dependencies are absent.
cat >/dev/null
root="${CLAUDE_PROJECT_DIR:-$PWD}/hippocampus"
[ -f "$root/package.json" ] && [ -d "$root/node_modules" ] || exit 0

open=$(grep -l '^stage: open$' "$root"/handoffs/20*.md 2>/dev/null | tail -1)
drift=$(cd "$root" && npm run -s okf:drift 2>&1 >/dev/null | grep -c '^warning:')

[ -n "$open" ] || [ "${drift:-0}" -gt 0 ] || exit 0
echo "Command centre:"
[ -n "$open" ] && echo "- Open handoff: hippocampus/handoffs/$(basename "$open"). Run /pickup to resume from it."
[ "${drift:-0}" -gt 0 ] && echo "- ${drift} repo registry entr$([ "$drift" = 1 ] && echo y || echo ies) behind the repo's HEAD (npm run okf:drift in hippocampus/). Run /hub-sync."
exit 0
