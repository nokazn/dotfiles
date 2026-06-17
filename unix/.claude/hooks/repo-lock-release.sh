#!/usr/bin/env bash
set -uo pipefail

cat > /dev/null

LOCK_BASE="/tmp/claude-repo-locks"

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

[[ -d "$LOCK_BASE" ]] || exit 0

# Release all locks held by this session
for lock_info in "$LOCK_BASE"/*/pid; do
  [[ -f "$lock_info" ]] || continue
  lock_pid="$(cat "$lock_info" 2>/dev/null)" || continue
  if [[ "$lock_pid" == "$SESSION_PID" ]]; then
    rm -rf "$(dirname "$lock_info")"
  fi
done
