# 0002 — Optional issue-linked slugs

**Date:** 2026-09-30
**Status:** Accepted

## Context

roaming-nova names work with descriptive slugs (`player-health-system`). skittles is driven by GitHub issues (`#94`), and its commits already reference issue numbers. Forcing one style would either lose the issue link or make descriptive-only repos invent issues.

## Decision

Slug format is per repo (`sdlc.json` → `slug.pattern`, `slug.issueLinked`). Issue-linked repos use `<issue>-<kebab-description>` (`94-player-career-tab`); `/sdlc:capture-intent #94` prefills the intent from the issue, and the PR carries both `Slug:` and `Closes #94`.

## Consequences

- The artifact trail, branch and PR are traceable to the issue without extra metadata
- The reusable PR Slug workflow takes the pattern as an input, so both styles share one check
- Slugs stay readable because the description is still part of them
