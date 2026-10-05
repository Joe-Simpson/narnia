# Handoffs

One file per branch, `<slug>.md`, so the next session (local or claude.ai/code) can pick up where the last one stopped. Written by the `handoff` skill; enforced by a Stop hook (`.claude/hooks/handoff-stop.sh`) and read back by a SessionStart hook (`.claude/hooks/handoff-start.sh`).

Delete a branch's handoff when the branch merges. These files are vendored from the Narnia `sdlc` plugin (`sdlc-handoff v1`); update them by re-running `/sdlc:adopt`, not by hand.
