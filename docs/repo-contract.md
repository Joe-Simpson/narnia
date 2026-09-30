# Repo contract

What an app repo provides so the `sdlc` plugin can work in it. `/sdlc:adopt` sets all of this up.

## `.claude/sdlc.json`

At the git root. Its presence is what switches the plugin's hooks on.

| Key | Type | Default | Used by |
| --- | ---- | ------- | ------- |
| `workdir` | string | `"."` | Directory (relative to the git root) where gate and format commands run |
| `srcPaths` | string[] | `["src/"]` | Path prefixes (relative to the git root) that count as source. Edits here need a plan |
| `artifactRoot` | string | `"."` | Directory holding `intent/`, `spec/`, `plan/` |
| `slug.pattern` | regex | `^[a-z0-9]+(-[a-z0-9]+)*$` | Skills; keep in sync with the PR Slug workflow input |
| `slug.issueLinked` | bool | `false` | Prefix slugs with the GitHub issue number |
| `gates` | object | — | Named commands: `typecheck`, `lint`, `test`, `coverage`, … |
| `stopGate` | string[] | `["typecheck","lint","test"]` | Gates the Stop hook runs before a session may end |
| `format` | string | unset | Formatter command; the edited file path is appended. Unset disables format-on-edit |
| `enforcePlanGate` | bool | `false` | Block source edits without a committed plan |
| `bugFastPath` | bool | `false` | Allow issue + plan (no intent/spec) for small bug fixes |
| `stackSkills` | string[] | `[]` | Repo-local skills the SDLC skills and agents must load |
| `securityChecklist` | path | unset | Repo-specific security checklist appended to `/sdlc:security-review` |

## `.claude/settings.json`

Enables the plugin (see the README) and holds the repo's permission allow/deny lists.

## Files at the git root

- `CLAUDE.md` — project overview, commands, architecture, conventions, and a short SDLC section. If the app lives in a subdirectory, the root file imports it with `@<workdir>/CLAUDE.md`
- `REVIEW.md` — severity levels and review passes
- `.github/claude-review.md` — how the CI review automation applies `REVIEW.md`
- `.github/pull_request_template.md` — with a `Slug:` line
- `.github/workflows/pr-slug.yml` — calls `Joe-Simpson/narnia/.github/workflows/pr-slug.yml@v1`
- `.commitlintrc.js` + `.husky/commit-msg` — commit format enforcement
- `intent/`, `spec/`, `plan/` under `artifactRoot`, each with a README

## Optional overrides

- `intent/_template.md`, `spec/_template.md`, `plan/_template.md` replace the plugin's bundled templates
- Repo-local skills with the same purpose as a plugin skill (e.g. a stack-specific `new-route`) are fine — plugin skills are namespaced `sdlc:` so nothing collides
