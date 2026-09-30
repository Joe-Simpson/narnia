# Narnia

Shared AI-native SDLC tooling for my app repos, published as a **Claude Code plugin marketplace**.

Every app follows the same process — `intent → spec → plan → code → verify` — and gets the same skills, agents, hooks and CI checks from here instead of keeping its own copies.

## Layout

```
Narnia/
├── .claude-plugin/marketplace.json   # marketplace "narnia" — lists the plugins below
├── plugins/
│   └── sdlc/                         # the SDLC plugin: skills, agents, hooks (see its README)
├── .github/workflows/pr-slug.yml     # reusable workflow: validates a PR's slug + committed plan
├── docs/
│   ├── sdlc.md                       # the process: stages, artifacts, gates, who does what
│   ├── repo-contract.md              # what an app repo must provide (.claude/sdlc.json schema, etc.)
│   ├── adopting.md                   # onboarding checklist + status of each app repo
│   └── adr/                          # decisions about this repo's design
├── CLAUDE.md                         # instructions for agents editing this repo
└── butters/ roaming-nova/ skittles/ taste-the-rainbow/   # app repos (separate git repos, gitignored here)
```

## Using it in an app repo

1. Commit this to the app's `.claude/settings.json` (at the git root):

   ```json
   {
     "extraKnownMarketplaces": {
       "narnia": { "source": { "source": "github", "repo": "Joe-Simpson/narnia" } }
     },
     "enabledPlugins": { "sdlc@narnia": true }
   }
   ```

   Claude Code prompts to install the marketplace the first time the repo is opened (local CLI, claude.ai/code and GitHub Actions alike).

2. Run `/sdlc:adopt` to write `.claude/sdlc.json` and install the repo-level files (REVIEW.md, PR template, slug CI check, commitlint, artifact directories).

Until a repo has `.claude/sdlc.json`, the plugin's hooks do nothing.

## Everyday use

| I want to… | Run |
| ---------- | --- |
| Start a feature or bug from an issue | `/sdlc:capture-intent #94` |
| Write the spec | `/sdlc:generate-spec 94-player-career-tab` |
| Plan the implementation (plan mode) | `/sdlc:generate-plan 94-player-career-tab` |
| Fix a bug test-first | `/sdlc:fix-bug <slug>` |
| Check my branch before a PR | `/sdlc:pre-pr`, then `/sdlc:review-pr` |
| Get an independent check | ask for the `verifier` or `pr-reviewer` agent |
| Record a decision | `/sdlc:adr` |

Full process: [docs/sdlc.md](docs/sdlc.md).

## Developing the plugin

- Try local changes without pushing: `claude --plugin-dir ~/Narnia/plugins/sdlc` from inside an app repo
- Validate the marketplace: `claude plugin validate ~/Narnia`
- Hook scripts are plain bash; test them by piping hook JSON on stdin (see `plugins/sdlc/README.md`)
- Release: bump `plugins/sdlc/.claude-plugin/plugin.json` `version`, commit, tag `vX.Y.Z`, and move the `v1` tag (the reusable workflow is referenced as `@v1`)
