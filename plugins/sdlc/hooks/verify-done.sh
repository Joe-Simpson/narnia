#!/usr/bin/env bash
# Stop hook: run the configured quality gates before the session may end.
#
# - Skips on re-entry (stop_hook_active) so a failing gate can't loop forever.
# - Skips when nothing under srcPaths changed since the last passing run
#   (marker: .git/sdlc-verified holds "<HEAD sha> <working-tree hash>").
# - Exit 2 blocks the stop and feeds the failures back to Claude.
source "$(dirname "$0")/lib/config.sh"
sdlc_init

[ "$(sdlc_input 'j.stop_hook_active')" = "true" ] && exit 0

WORKDIR=$(sdlc_cfg "c.workdir || '.'")
[ -d "$SDLC_ROOT/$WORKDIR/node_modules" ] || [ ! -f "$SDLC_ROOT/$WORKDIR/package.json" ] || {
  echo "sdlc: skipping verification — run npm install in $WORKDIR first." >&2
  exit 0
}

mapfile -t SRC < <(sdlc_cfg "c.srcPaths || ['src/']")
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null) || exit 0
MARKER="$GIT_DIR/sdlc-verified"
UNTRACKED=$(git ls-files --others --exclude-standard -- "${SRC[@]}" 2>/dev/null)
STATE="$(git rev-parse HEAD 2>/dev/null) $({
  git diff HEAD -- "${SRC[@]}" 2>/dev/null
  [ -n "$UNTRACKED" ] && printf '%s\n' "$UNTRACKED" | git hash-object --stdin-paths
} | git hash-object --stdin)"

[ -f "$MARKER" ] && [ "$(cat "$MARKER")" = "$STATE" ] && exit 0

# Nothing to verify if no source changes exist relative to the default branch or the working tree.
BASE=$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD origin/master 2>/dev/null || echo "")
if [ -n "$BASE" ] && [ -z "$UNTRACKED" ] && git diff --quiet "$BASE" -- "${SRC[@]}" 2>/dev/null; then
  exit 0
fi

FAILURES=""
while IFS= read -r gate; do
  [ -n "$gate" ] || continue
  if ! sdlc_run_gate "$gate"; then
    FAILURES="${FAILURES}\n  • ${gate}  →  $(sdlc_cfg "c.gates['$gate']")"
  fi
done < <(sdlc_cfg "c.stopGate || ['typecheck','lint','test']")

if [ -n "$FAILURES" ]; then
  printf "Verification failed — fix these before finishing (commands run in %s/):%b\n" "$WORKDIR" "$FAILURES" >&2
  exit 2
fi

echo "$STATE" >"$MARKER"
exit 0
