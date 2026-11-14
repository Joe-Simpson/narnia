---
description: Fetch every app repo and report drift against hippocampus, remote branches with handoffs, and stale vendored files; reconcile on approval
disable-model-invocation: true
---

Sync the hub's picture with reality. Read-only until the user approves the reconcile step (step 4). Work from `~/Narnia`.

1. **Offline drift.** `cd hippocampus && npm run -s okf:drift` (registry `repo@sha` vs each repo's HEAD).
2. **Fetch and compare.** For each `hippocampus/repos/*.md` (skip `index.md`, `_template.md`): `git -C <repo> fetch --prune` (it is a read-only fetch; if it fails, say so and carry on with local data). Then, per repo:
   - registry SHA vs `origin/<default>`: commits behind, and whether `CLAUDE.md`, `docs/adr/`, `.claude/` or `REVIEW.md` changed in between (`git diff --stat <sha>..origin/<default> -- <paths>`)
   - remote branches (`git branch -r --no-merged origin/<default>`) that carry `.claude/handoff/*.md` (`git ls-tree -r --name-only origin/<branch> .claude/handoff/`); for each, read the handoff's `stage`, `head`, `updated`, `origin` front matter (`git show origin/<branch>:<path>`). `origin: cloud` ones are remote work the hub hasn't seen
   - handoff files on branches already merged into `origin/<default>` (should have been deleted)
   - vendored handoff files (`.claude/skills/handoff/SKILL.md`, `.claude/hooks/handoff-*.sh`) missing, or whose `sdlc-handoff vN` marker is older than `plugins/sdlc/skills/adopt/templates/handoff/`; for repos that haven't adopted the SDLC say "not adopted" instead
   - open PRs (`gh pr list -R <owner/repo> --state open`) if `gh` is available
3. **Report** one table (repo, registry SHA, behind, remote handoffs, notes) and a short "needs attention" list. Do not paste handoff bodies; cite file and branch.
4. **Reconcile (ask first).** Offer to update each drifted `repos/<name>.md`: new `repo@sha` source, `generated.at`, `stale_after` one week out, and any changed facts, never `verified`. On approval, edit, append a **Update** line to `hippocampus/log.md`, run `npm run okf:check`, show the diff and commit in hippocampus.
