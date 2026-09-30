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

echo "hooks: $pass passed, $failed failed"
[ "$failed" -eq 0 ]
