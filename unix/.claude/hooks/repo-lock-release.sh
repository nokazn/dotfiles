#!/usr/bin/env bash
set -uo pipefail

cat > /dev/null

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

LOCK_BASE="/tmp/claude-repo-locks"
REPO_HASH="$(echo -n "$REPO_ROOT" | shasum | cut -d' ' -f1)"
LOCK_DIR="${LOCK_BASE}/${REPO_HASH}"
LOCK_INFO="${LOCK_DIR}/pid"

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

[[ -f "$LOCK_INFO" ]] || exit 0

lock_pid="$(cat "$LOCK_INFO" 2>/dev/null)" || exit 0

if [[ "$lock_pid" == "$SESSION_PID" ]]; then
  rm -rf "$LOCK_DIR"
fi
