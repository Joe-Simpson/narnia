#!/usr/bin/env bash
# Stop hook: run the configured quality gates before the session may end.
#
# - Skips on re-entry (stop_hook_active) so a failing gate can't loop forever.
# - Skips when the content under srcPaths is identical to the last passing run
#   (marker: <git-dir>/sdlc-verified holds the tree hash of srcPaths, tracked and
#   untracked, so committing verified work doesn't re-run the gates).
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
MARKER=$(git rev-parse --git-path sdlc-verified 2>/dev/null) || exit 0
UNTRACKED=$(git ls-files --others --exclude-standard -- "${SRC[@]}" 2>/dev/null)

# Content hash of srcPaths as they stand on disk, built in a throwaway index so
# the real one is untouched. Independent of HEAD, so a commit alone is a no-op.
tree_state() {
  local idx rc
  idx=$(mktemp) || return 1
  cp "$(git rev-parse --git-path index)" "$idx" 2>/dev/null || : >"$idx"
  GIT_INDEX_FILE="$idx" git add -A -- "${SRC[@]}" >/dev/null 2>&1 &&
    GIT_INDEX_FILE="$idx" git ls-files -s -- "${SRC[@]}" | git hash-object --stdin
  rc=$?
  rm -f "$idx"
  return $rc
}
STATE=$(tree_state 2>/dev/null)

[ -n "$STATE" ] && [ -f "$MARKER" ] && [ "$(cat "$MARKER")" = "$STATE" ] && exit 0

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

[ -n "$STATE" ] && echo "$STATE" >"$MARKER"
exit 0
