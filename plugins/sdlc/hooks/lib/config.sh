#!/usr/bin/env bash
# Shared helpers for sdlc plugin hooks. Source this file; do not execute it.
#
# Every hook calls `sdlc_init` first. If the repo has no .claude/sdlc.json the
# hook exits 0 immediately, so enabling the plugin in an unadopted repo is inert.

SDLC_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SDLC_CONFIG="$SDLC_ROOT/.claude/sdlc.json"
SDLC_INPUT=""

# Read hook JSON from stdin and bail out if the repo has not adopted the SDLC.
sdlc_init() {
  SDLC_INPUT=$(cat)
  [ -f "$SDLC_CONFIG" ] || exit 0
  cd "$SDLC_ROOT" || exit 0
}

# sdlc_cfg <js-expression over `c`> — print a value from sdlc.json.
# Arrays print one item per line; missing values print nothing.
sdlc_cfg() {
  node -e '
    const c = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
    let v;
    try { v = (new Function("c", "return (" + process.argv[2] + ")"))(c); } catch { v = undefined; }
    if (v === undefined || v === null) process.exit(0);
    if (Array.isArray(v)) v.forEach((x) => console.log(x));
    else console.log(v);
  ' "$SDLC_CONFIG" "$1" 2>/dev/null
}

# sdlc_input <js-expression over `j`> — print a value from the hook input JSON.
sdlc_input() {
  printf '%s' "$SDLC_INPUT" | node -e '
    let d = "";
    process.stdin.on("data", (x) => (d += x));
    process.stdin.on("end", () => {
      let v;
      try { v = (new Function("j", "return (" + process.argv[1] + ")"))(JSON.parse(d)); } catch { v = undefined; }
      if (v !== undefined && v !== null) process.stdout.write(String(v));
    });
  ' "$1" 2>/dev/null
}

# Run a named gate from config (e.g. "test") inside the configured workdir.
sdlc_run_gate() {
  local cmd workdir
  cmd=$(sdlc_cfg "c.gates && c.gates['$1']")
  [ -n "$cmd" ] || return 0
  workdir=$(sdlc_cfg "c.workdir || '.'")
  (cd "$SDLC_ROOT/$workdir" && eval "$cmd") >/dev/null 2>&1
}

# Current branch slug: the part after "<type>/" (empty if the branch has no type prefix).
sdlc_branch_type() { git branch --show-current 2>/dev/null | sed -n 's#^\([a-z]*\)/.*#\1#p'; }
sdlc_branch_slug() { git branch --show-current 2>/dev/null | sed -n 's#^[a-z]*/##p'; }

# True if the given repo-relative path is under one of the configured srcPaths.
sdlc_is_src_path() {
  local rel="$1" p
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    case "$rel" in "$p"*) return 0 ;; esac
  done < <(sdlc_cfg "c.srcPaths || ['src/']")
  return 1
}
