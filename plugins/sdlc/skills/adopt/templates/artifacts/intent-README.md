# intent/

The "why" layer of the SDLC artifact chain: one problem statement per change, written before any design.

- Create with `/sdlc:capture-intent [#issue]` — Claude asks clarifying questions and writes `<slug>.md`
- Lifecycle: `draft → approved → closed`. `/sdlc:generate-spec` refuses anything not `approved`
- Slugs are lowercase-hyphenated{{ISSUE_SLUG_NOTE}} and match across `intent/`, `spec/`, `plan/`, the branch and the PR
- Commits: `intent: add <slug>`, `intent: update <slug>`
- Template: the `sdlc` plugin's bundled template, unless `_template.md` exists here to override it

Process reference: https://github.com/Joe-Simpson/narnia/blob/main/docs/sdlc.md
