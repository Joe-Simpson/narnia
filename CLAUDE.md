# CLAUDE.md — Narnia

> **Scope:** this file is for working on the Narnia repo itself (`plugins/`, `docs/`, `.github/`). If your task is inside an app repo (`butters/`, `roaming-nova/`, `skittles/`, `taste-the-rainbow/`), ignore this file — follow that repo's `CLAUDE.md` and the `sdlc` plugin.

Narnia is a Claude Code plugin marketplace that distributes one shared SDLC to several app repos. The app directories beside it are **separate git repos** and are gitignored here — never commit them to Narnia.

## Layout

- `.claude-plugin/marketplace.json` — marketplace manifest (`narnia`)
- `plugins/sdlc/` — the SDLC plugin (`skills/`, `agents/`, `hooks/`, `.claude-plugin/plugin.json`); its README lists every component
- `.github/workflows/pr-slug.yml` — reusable workflow, called by app repos as `Joe-Simpson/narnia/.github/workflows/pr-slug.yml@v1`
- `docs/` — process (`sdlc.md`), consumer contract (`repo-contract.md`), onboarding (`adopting.md`), ADRs

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
