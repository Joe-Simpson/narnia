---
name: handoff
description: Write or resume a session handoff for the current branch (.claude/handoff/<slug>.md). Use at the end of a session or when told to hand off, when the Stop hook says the handoff is missing or out of date, and at the start of a session on a branch that already has a handoff file.
---
<!-- sdlc-handoff v1 -->

# Handoff

A handoff lets the next session (local or claude.ai/code, any machine) continue without re-deriving state. One file per branch: `.claude/handoff/<slug>.md`, where `<slug>` is the branch name without its `<type>/` prefix. It is committed on the branch.

## Resume (start of a session)
1. Read `.claude/handoff/<slug>.md` for the current branch (the SessionStart hook prints it).
2. Check it against reality: `git log --oneline <head>..HEAD` and `git status`. If the code moved since `head`, say what changed before continuing.
3. Continue from **Next steps**. Do not redo what **Done** lists.

## Write (end of a session)
1. Copy `template.md` from this skill's directory to `.claude/handoff/<slug>.md` if the file doesn't exist; otherwise update it in place.
2. Fill every section from what actually happened, not from the plan: Goal, Done, Next steps (ordered, concrete, each startable cold), Decisions and why, Blockers, How to verify (exact commands), Files touched, Links.
3. Set front matter: `head` = `git rev-parse --short HEAD` after your last commit, `updated` = now (ISO-8601 UTC), `origin` = `cloud` if `$CLAUDE_CODE_REMOTE` is `true`, else `local`, and `stage`: `open`, `blocked`, `ready-for-review` or `done`.
4. Commit it with the work (or as `docs: update handoff`) and push if the branch is already pushed.

## Rules
- Facts only: no speculation, no secrets, no tokens or `.env` contents.
- Link to the issue, PR and intent/spec/plan files instead of copying them.
- Keep it under about 60 lines. If it is longer, the detail belongs in the plan or an ADR.
- When the branch merges, the handoff is deleted (stage `done`, then remove the file in the cleanup commit).
