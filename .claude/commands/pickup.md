---
description: Resume from the open hub handoff: summarise where things stand, check for drift, and continue a chosen thread
disable-model-invocation: true
argument-hint: [repo/slug to resume, optional]
---

Pick up where the last session left off. Optional target: $ARGUMENTS

1. **Read** the one `stage: open` file in `hippocampus/handoffs/` (if none: say so and fall back to the newest handoff and open dispatches). Read the repo handoffs it links.
2. **Check reality** before trusting it: run `/hub-sync` steps 1-3 (read-only). For each linked repo handoff compare its `head` to the branch's current HEAD (local worktree or `origin/<branch>`) and flag any branch where a cloud session pushed newer commits or a newer handoff than the hub recorded.
3. **Summarise** in a short table: thread, repo/branch, last known state, what changed since, next step. Call out anything contradicted by reality.
4. **Choose.** If no target was given, ask which thread to continue (or "just show me").
5. **Continue.** For the chosen thread: create or reuse its worktree with `/worktree create <repo> <slug> --from origin/<branch>` when the branch only exists remotely, then spawn a `repo-worker` with a brief that names the worktree, owned paths, the repo handoff to read first, and the return format. Remind the worker to update `.claude/handoff/<slug>.md` before finishing. Follow `/dispatch` rules (approval before fan-out when more than one worker).
6. **Close the loop.** When the session ends or the plan changes, run `/handoff` so the next pickup starts from the truth.
