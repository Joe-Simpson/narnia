---
description: Save a validated entry (or a worker's proposed memory) into the hippocampus bundle
disable-model-invocation: true
argument-hint: <what to remember, or paste a worker's "Proposed memory" block>
---

Save to hippocampus: $ARGUMENTS

Use the `hippocampus` skill. Pick the type from the content (`Repo`, `Decision`, `Convention`, `Runbook`, `Learning`, `Dispatch`); if an existing concept already covers it, update that one instead of adding a duplicate. Reject anything the repo already records or that only matters to this session, and say why.

Then: write the entry from the directory's `_template.md`; update that directory's `index.md` and `log.md`; run `cd ~/Narnia/hippocampus && npm run okf:check` and fix every error; show the user the diff and commit in the hippocampus repo with a conventional message after they agree.
