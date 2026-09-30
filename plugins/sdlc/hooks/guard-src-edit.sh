#!/usr/bin/env bash
# PreToolUse[Write|Edit|MultiEdit]: enforce "no source edits without a committed plan".
# Active only when sdlc.json sets "enforcePlanGate": true.
#
# Allowed when:
#   - the file is outside srcPaths
#   - the branch type is a tooling type (chore/ci/docs/build/style) — these PRs carry `Slug: none`
#   - plan/<branch-slug>.md is committed on the current branch
source "$(dirname "$0")/lib/config.sh"
sdlc_init

[ "$(sdlc_cfg 'c.enforcePlanGate === true')" = "true" ] || exit 0

FILE=$(sdlc_input "j.tool_input && j.tool_input.file_path")
[ -n "$FILE" ] || exit 0
REL="${FILE#"$SDLC_ROOT"/}"
sdlc_is_src_path "$REL" || exit 0

TYPE=$(sdlc_branch_type)
SLUG=$(sdlc_branch_slug)
BRANCH=$(git branch --show-current 2>/dev/null)

case "$TYPE" in chore | ci | docs | build | style) exit 0 ;; esac

ARTIFACTS=$(sdlc_cfg "c.artifactRoot || '.'")
PLAN="$ARTIFACTS/plan/$SLUG.md"
PLAN="${PLAN#./}"

if [ -z "$SLUG" ]; then
  echo "Blocked edit to $REL: branch '$BRANCH' has no <type>/<slug> form, so there is no plan to implement." >&2
  echo "Create a branch like feat/<slug>, then run /sdlc:generate-plan <slug> in plan mode." >&2
  exit 2
fi

if ! git cat-file -e "HEAD:$PLAN" 2>/dev/null; then
  echo "Blocked edit to $REL: $PLAN is not committed on this branch." >&2
  echo "The SDLC requires a committed plan before source changes. Run /sdlc:generate-plan $SLUG in plan mode (or /sdlc:fix-bug for the bug fast path)." >&2
  exit 2
fi

exit 0
