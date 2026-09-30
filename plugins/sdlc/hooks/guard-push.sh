#!/usr/bin/env bash
# PreToolUse[Bash]: gate `git push`.
# - Blocks every force-push variant unconditionally.
# - Requires the configured test gate to pass before pushing to main/master.
source "$(dirname "$0")/lib/config.sh"
sdlc_init

COMMAND=$(sdlc_input "j.tool_input && j.tool_input.command")
echo "$COMMAND" | grep -qE '(^|[;&|]\s*)git\s+push\b' || exit 0

if echo "$COMMAND" | grep -qE '\s(--force|--force-with-lease|--force-if-includes|-f)\b|\s\+[^ ]+'; then
  echo "Force push is blocked by the sdlc plugin. Open a PR and merge normally instead." >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'git\s+push\b.*\b(main|master)\b'; then
  if ! sdlc_run_gate test; then
    echo "Tests must pass before pushing to main. Run: $(sdlc_cfg "c.gates && c.gates.test")" >&2
    exit 2
  fi
fi

exit 0
