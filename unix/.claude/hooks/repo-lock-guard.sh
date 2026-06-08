#!/usr/bin/env bash
set -euo pipefail

cat > /dev/null

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
[[ -e "$REPO_ROOT/.git" ]] || exit 0

LOCK_BASE="/tmp/claude-repo-locks"
REPO_HASH="$(echo -n "$REPO_ROOT" | shasum | cut -d' ' -f1)"
LOCK_DIR="${LOCK_BASE}/${REPO_HASH}"
LOCK_INFO="${LOCK_DIR}/pid"

# Walk process tree to find Claude CLI PID as stable session identifier
find_session_pid() {
  local pid=$PPID
  for _ in 1 2 3 4 5; do
    local args
    args=$(ps -p "$pid" -o args= 2>/dev/null || true)
    if echo "$args" | grep -qE '(claude|@anthropic-ai)'; then
      echo "$pid"
      return
    fi
    pid=$(ps -p "$pid" -o ppid= 2>/dev/null | tr -d ' ' || true)
    [[ -z "$pid" || "$pid" == "1" ]] && break
  done
  echo "$PPID"
}

SESSION_PID="$(find_session_pid)"

acquire_lock() {
  mkdir -p "$LOCK_BASE"
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "$SESSION_PID" > "$LOCK_INFO"
    return 0
  fi
  return 1
}

# No lock exists — acquire
if [[ ! -d "$LOCK_DIR" ]]; then
  acquire_lock || true
  exit 0
fi

# Lock exists — check ownership
lock_pid="$(cat "$LOCK_INFO" 2>/dev/null)" || {
  rm -rf "$LOCK_DIR"
  acquire_lock || true
  exit 0
}

# Our lock
if [[ "$lock_pid" == "$SESSION_PID" ]]; then
  exit 0
fi

# Stale lock (holder process died)
if ! kill -0 "$lock_pid" 2>/dev/null; then
  rm -rf "$LOCK_DIR"
  acquire_lock || true
  exit 0
fi

# Locked by another live session — block
REPO_NAME="$(basename "$REPO_ROOT")"
cat <<EOF
{"decision":"block","reason":"Repository is locked by another Claude session (PID: ${lock_pid}). Create a worktree to work in parallel:\n  git worktree add ../${REPO_NAME}-wt-<branch> -b <branch>\n  cd ../${REPO_NAME}-wt-<branch>"}
EOF
