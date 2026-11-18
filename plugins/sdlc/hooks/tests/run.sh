#!/usr/bin/env bash
# Behaviour tests for the sdlc hooks. Builds a scratch git repo, pipes hook JSON
# on stdin, and checks exit codes. Run: bash plugins/sdlc/hooks/tests/run.sh
set -u
H="$(cd "$(dirname "$0")/.." && pwd)"
S="$(mktemp -d)"
trap 'rm -rf "$S"' EXIT
pass=0 failed=0

t() {
  local name="$1" hook="$2" json="$3" want="$4" rc
  echo "$json" | CLAUDE_PROJECT_DIR="$S" bash "$H/$hook" >/dev/null 2>&1
  rc=$?
  if [ "$rc" = "$want" ]; then pass=$((pass + 1)); else failed=$((failed + 1)); echo "FAIL: $name (exit $rc, want $want)"; fi
}
edit() { printf '{"tool_input":{"file_path":"%s"}}' "$S/$1"; }
push() { printf '{"tool_input":{"command":"%s"}}' "$1"; }

cd "$S" || exit 1
git init -q -b main && git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t

# Inert without config
t "no config: push -f" guard-push.sh "$(push 'git push -f')" 0
t "no config: src edit" guard-src-edit.sh "$(edit app/src/x.ts)" 0
t "no config: stop" verify-done.sh '{}' 0

mkdir -p .claude app/src app/node_modules && echo '{}' >app/package.json
cat >.claude/sdlc.json <<'JSON'
{"workdir":"app","srcPaths":["app/src/"],"enforcePlanGate":true,
 "gates":{"typecheck":"true","lint":"true","test":"exit ${FAILTEST:-0}"},
 "stopGate":["typecheck","lint","test"]}
JSON

# guard-push
t "force push" guard-push.sh "$(push 'git push --force origin x')" 2
t "force-with-lease" guard-push.sh "$(push 'git push --force-with-lease')" 2
t "+refspec" guard-push.sh "$(push 'git push origin +main')" 2
t "follow-tags allowed" guard-push.sh "$(push 'git push --follow-tags origin feat/x')" 0
t "push main, tests pass" guard-push.sh "$(push 'git push origin main')" 0
FAILTEST=1 t "push main, tests fail" guard-push.sh "$(push 'git push origin main')" 2
t "not a push" guard-push.sh "$(push 'ls -f')" 0

# guard-src-edit
git checkout -q -b feat/94-foo
t "src edit, no plan" guard-src-edit.sh "$(edit app/src/x.ts)" 2
t "non-src edit" guard-src-edit.sh "$(edit README.md)" 0
mkdir plan && echo x >plan/94-foo.md
t "plan uncommitted" guard-src-edit.sh "$(edit app/src/x.ts)" 2
git add plan && git commit -qm "plan: add 94-foo"
t "plan committed" guard-src-edit.sh "$(edit app/src/x.ts)" 0
git checkout -q -b chore/tooling main
t "chore branch" guard-src-edit.sh "$(edit app/src/x.ts)" 0
git checkout -q main
t "main branch" guard-src-edit.sh "$(edit app/src/x.ts)" 2

# verify-done
t "stop re-entry" verify-done.sh '{"stop_hook_active":true}' 0
echo a >app/src/x.ts
FAILTEST=1 t "new untracked file, failing test" verify-done.sh '{}' 2
t "passes" verify-done.sh '{}' 0
FAILTEST=1 t "cached, no change" verify-done.sh '{}' 0
echo b >>app/src/x.ts
FAILTEST=1 t "untracked file changed" verify-done.sh '{}' 2
git add app && git commit -qm x
FAILTEST=1 t "new commit" verify-done.sh '{}' 2
t "passes again" verify-done.sh '{}' 0
echo c >>app/src/x.ts
FAILTEST=1 t "tracked file modified" verify-done.sh '{}' 2
t "passes after edit" verify-done.sh '{}' 0
git add app && git commit -qm y
FAILTEST=1 t "commit of verified work: cached" verify-done.sh '{}' 0
echo d >app/README.md
FAILTEST=1 t "change outside srcPaths: cached" verify-done.sh '{}' 0

# --- vendored handoff hooks (templates copied into app repos by /sdlc:adopt) ---
HT="$H/../skills/adopt/templates/handoff/hooks"
HS="$(mktemp -d)"
trap 'rm -rf "$S" "$HS"' EXIT
th() {
  local name="$1" hook="$2" json="$3" want="$4" rc
  echo "$json" | CLAUDE_PROJECT_DIR="$HS" bash "$HT/$hook" >/dev/null 2>&1
  rc=$?
  if [ "$rc" = "$want" ]; then pass=$((pass + 1)); else failed=$((failed + 1)); echo "FAIL: $name (exit $rc, want $want)"; fi
}
# thout <name> <hook> <pattern|-> : stdout must match the pattern, or be empty when "-"
thout() {
  local name="$1" hook="$2" want="$3" out
  out=$(echo '{}' | CLAUDE_PROJECT_DIR="$HS" bash "$HT/$hook" 2>/dev/null)
  if { [ "$want" = "-" ] && [ -z "$out" ]; } || { [ "$want" != "-" ] && printf '%s' "$out" | grep -q -- "$want"; }; then
    pass=$((pass + 1))
  else failed=$((failed + 1)); echo "FAIL: $name (stdout: $out)"; fi
}

cd "$HS" || exit 1
git init -q -b main && git commit -q --allow-empty -m init
t_head() { printf -- '---\ntype: Handoff\nslug: %s\nstage: open\n---\n\n# %s\n\nNext: do the thing.\n' "$1" "$1"; }

# on the default branch both hooks are silent
th "handoff stop: default branch" handoff-stop.sh '{}' 0
thout "handoff start: default branch" handoff-start.sh -

# feature branch with a commit and no handoff -> blocked
git checkout -q -b claude/94-foo
echo a >a.txt && git add a.txt && git commit -qm "feat: a"
th "handoff stop: commits, no handoff" handoff-stop.sh '{}' 2
th "handoff stop: re-entry" handoff-stop.sh '{"stop_hook_active":true}' 0
thout "handoff start: no handoff yet" handoff-start.sh -

# handoff written but uncommitted -> allowed
mkdir -p .claude/handoff && t_head 94-foo >.claude/handoff/94-foo.md
th "handoff stop: handoff uncommitted" handoff-stop.sh '{}' 0
thout "handoff start: prints handoff" handoff-start.sh "Next: do the thing"

# handoff committed with the work -> allowed
git add -A && git commit -qm "docs: handoff"
th "handoff stop: handoff in HEAD" handoff-stop.sh '{}' 0

# new commit after the handoff -> stale -> blocked
echo b >b.txt && git add b.txt && git commit -qm "feat: b"
th "handoff stop: handoff stale" handoff-stop.sh '{}' 2

# dirty tree with a current handoff, and dirty tree without a handoff
echo c >>b.txt && echo "- updated" >>.claude/handoff/94-foo.md
th "handoff stop: dirty + handoff updated" handoff-stop.sh '{}' 0
git add -A && git commit -qm "docs: handoff again"
echo d >>b.txt
th "handoff stop: dirty, handoff behind" handoff-stop.sh '{}' 2
git checkout -q -- b.txt

# branch without a type prefix maps to the whole name; detached HEAD is exempt
git checkout -q -b plain-slug
echo e >e.txt && git add e.txt && git commit -qm "feat: e"
th "handoff stop: unprefixed branch, no handoff" handoff-stop.sh '{}' 2
t_head plain-slug >.claude/handoff/plain-slug.md
th "handoff stop: unprefixed branch, handoff" handoff-stop.sh '{}' 0
git checkout -q --detach
th "handoff stop: detached HEAD" handoff-stop.sh '{}' 0

# outside a git repo both hooks are inert
mv .git .git.off
th "handoff stop: no git" handoff-stop.sh '{}' 0
thout "handoff start: no git" handoff-start.sh -
mv .git.off .git

echo "hooks: $pass passed, $failed failed"
[ "$failed" -eq 0 ]
