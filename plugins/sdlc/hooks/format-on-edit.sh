#!/usr/bin/env bash
# PostToolUse[Write|Edit|MultiEdit]: auto-format the edited file with the repo's formatter.
# Uses sdlc.json "format" (e.g. "npx prettier --write"); skipped when unset.
source "$(dirname "$0")/lib/config.sh"
sdlc_init

FORMAT=$(sdlc_cfg "c.format")
[ -n "$FORMAT" ] || exit 0

FILE=$(sdlc_input "j.tool_input && j.tool_input.file_path")
[ -f "$FILE" ] || exit 0

case "$FILE" in
  *.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs | *.css | *.json | *.md | *.html | *.yml | *.yaml)
    WORKDIR=$(sdlc_cfg "c.workdir || '.'")
    (cd "$SDLC_ROOT/$WORKDIR" && eval "$FORMAT \"\$FILE\"") >/dev/null 2>&1
    ;;
esac

exit 0
