# CLAUDE.md — Narnia

> **Scope:** this file covers working on the Narnia repo itself (`plugins/`, `docs/`, `.github/`) and the **Command centre** section below (orchestrating from this directory). If your task is inside an app repo (`butters/`, `roaming-nova/`, `skittles/`, `taste-the-rainbow/`), ignore this file — follow that repo's `CLAUDE.md` and the `sdlc` plugin.

Narnia is a Claude Code plugin marketplace that distributes one shared SDLC to several app repos. The app directories beside it are **separate git repos** and are gitignored here — never commit them to Narnia.

## Layout

- `.claude-plugin/marketplace.json` — marketplace manifest (`narnia`)
- `plugins/sdlc/` — the SDLC plugin (`skills/`, `agents/`, `hooks/`, `.claude-plugin/plugin.json`); its README lists every component
- `.github/workflows/pr-slug.yml` — reusable workflow, called by app repos as `Joe-Simpson/narnia/.github/workflows/pr-slug.yml@v1`
- `docs/` — process (`sdlc.md`), consumer contract (`repo-contract.md`), onboarding (`adopting.md`), ADRs

## Command centre

A session started in `~/Narnia` is the **hub**: it orchestrates workers across the app repos and their worktrees. Hub tooling is local-only (see ADR-0004) and lives in `.claude/`; it never changes what an app repo does when run alone.

- **Shared memory:** `hippocampus/` (a separate private git repo, OKF v0.2). Read its `index.md` first and drill down; check `stale_after` before trusting a `Repo` entry. Only the hub writes to it, via `/remember`; workers return a "Proposed memory" block. Rules: `hippocampus/CLAUDE.md`. Use the `hippocampus` skill.
- **Worktrees:** one per worker at `.worktrees/<repo>/<slug>` on `claude/<slug>`. Use `/worktree`.
- **Dispatch:** `/dispatch <goal>` plans a fan-out (max 5 workers, non-overlapping owned paths), waits for approval, then spawns `repo-worker` agents. Review every diff before merging; verification is the bottleneck.
- **Overview:** `/hub-status` shows repo, worktree and PR state against the registry.
- **Handoff:** `/handoff` writes a hub handoff (`hippocampus/handoffs/`, one `open` at a time, linking each repo's `.claude/handoff/<slug>.md`); `/pickup` resumes from it. Repo handoffs are vendored into each repo by `/sdlc:adopt` because cloud sessions don't load plugins (ADR-0005).
- **Drift from remote work:** `/hub-sync` fetches every repo and reports drift, remote branches carrying handoffs and outdated vendored files, then reconciles the registry on approval. `npm run okf:drift` (in hippocampus) is the offline check. Repo facts live in the repo; hippocampus keeps pointers.
- **Hooks:** SessionStart prints the open handoff and any drift count; Stop blocks ending the session while hippocampus has uncommitted changes that fail `npm run okf:check`.

## Rules for plugin content

- **Stack-agnostic.** Nothing in `plugins/sdlc` may mention a specific framework, database or app. Anything stack-specific belongs in the app repo's own `.claude/skills/` and is referenced via `sdlc.json` → `stackSkills`.
- **Config, not constants.** Paths, commands and toggles come from the consuming repo's `.claude/sdlc.json`. Adding a key means updating `docs/repo-contract.md` and the `adopt` template in the same commit.
- **Inert without config.** Every hook must `exit 0` when `.claude/sdlc.json` is absent (`hooks/lib/config.sh` → `sdlc_init`).
- **Hooks exit 2 to block**, with a one-line reason and the next step on stderr. Stop hooks must honour `stop_hook_active`.
- User-triggered workflow skills set `disable-model-invocation: true`; discipline skills (`sdlc-compliance`, `tdd`, `conventional-commits`) stay auto-invocable with trigger-rich descriptions.
- Keep templates in sync: artifact templates are bundled beside their skills (`skills/*/template.md`); repo-level templates live in `skills/adopt/templates/`.

## Verifying changes

```bash
claude plugin validate .                          # manifest + plugin structure
bash plugins/sdlc/hooks/tests/run.sh              # hook behaviour against a scratch repo
```

Then smoke-test in an adopted app repo: `claude --plugin-dir ~/Narnia/plugins/sdlc`, check `/sdlc:` completion, `/agents`, and `/hooks`.

## Releasing

Conventional commits. Bump `plugins/sdlc/.claude-plugin/plugin.json` version (semver: breaking `sdlc.json` changes are major), tag `vX.Y.Z`, move the `v1` tag. Record significant design changes as an ADR in `docs/adr/` and add a row to `docs/adopting.md` if consumers must act.
