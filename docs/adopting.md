# Adopting the SDLC

## Status

| Repo | Status | Notes |
| ---- | ------ | ----- |
| skittles | Adopting (v1 pilot) | Issue-linked slugs (`94-player-career-tab`), app in `skittles-app/`, Supabase stack skills |
| roaming-nova | Not yet — origin of the process | Keeps its local copies until migrated |
| butters | Not yet | Earlier variant (bugfix, adr, pre-pr, route/widget scaffolds) |
| taste-the-rainbow | Not yet | Bare Vite template; needs a CLAUDE.md first |

## Checklist for a new repo

1. Branch `chore/adopt-sdlc` from the default branch
2. Enable the plugin in `.claude/settings.json` (see the README), start a new session, and run `/sdlc:adopt`
3. Move stack-specific rules and gotchas out of `CLAUDE.md` into `.claude/skills/<stack>/` and list them in `stackSkills`
4. Write `.claude/security-checklist.md` for the stack
5. Open the PR with `Slug: none`; confirm the `PR Slug` check passes
6. Take one real issue through the full chain as a pilot, and feed friction back into this repo

## Migrating an existing variant (roaming-nova, butters)

These repos already have local copies of what the plugin now provides. Migrating means **deleting** the local generic copies and keeping only the stack-specific ones.

| Local file | After migration |
| ---------- | --------------- |
| `.claude/commands/{capture-intent,generate-spec,generate-plan,fix-bug,review-pr,generate-readme}.md` | delete — use `/sdlc:*` |
| `.claude/commands/security-review.md` | keep the stack-specific parts as `.claude/security-checklist.md`; delete the rest |
| `.claude/skills/{sdlc-compliance,tdd,conventional-commits}` | delete; move stack-specific test mocks (e.g. Three.js) into a stack skill |
| `.claude/skills/{bugfix,adr,pre-pr}` (butters) | delete — use `/sdlc:fix-bug`, `/sdlc:adr`, `/sdlc:pre-pr` |
| `.claude/agents/{verifier,pr-reviewer}.md` | delete |
| `.claude/hooks/*` and their `settings.json` wiring | delete; set `gates`, `stopGate` and `format` in `sdlc.json` |
| `.github/scripts/check-slug.sh` + `pr-slug.yml` | replace with the 15-line caller of the reusable workflow |
| `game-standards`, `new-route`, `new-widget`, … | keep — list in `stackSkills` |

butters has no intent/spec/plan artifacts yet; decide whether it adopts the full chain or runs with `enforcePlanGate: false` at first.
