---
name: generate-readme
description: Generate a short README.md for a directory — a navigation index for agents and humans.
argument-hint: "<directory>"
disable-model-invocation: true
---

# Generate directory README

Target: `$ARGUMENTS` (relative to the repo root).

1. List the files and subdirectories in the target
2. Skim each (the first ~30 lines is usually enough) to learn its purpose
3. Write `<target>/README.md` containing:
   - **Purpose** — one line
   - **Contents** — table of `name` → one-sentence description
   - **Usage** — how an agent starting a task should use this directory
   - **Conventions** — naming rules, status lifecycles, structural patterns
4. Keep it **under 60 lines** — a navigation aid, not documentation
5. Commit: `docs: add README for <directory>`

Never generate READMEs for `node_modules/`, `dist/`, `coverage/`, `.git/`, or directories that only hold generated files.
