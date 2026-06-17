#!/usr/bin/env bash
set -euo pipefail

cat > /dev/null

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || true

LOCK_BASE="/tmp/claude-repo-locks"

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

# Walk cwd upward to find the nearest directory containing a .git entry.
# Returns the directory path, or empty string if none found.
find_git_entry() {
  local dir
  dir="$(pwd)"
  while [[ "$dir" != "/" ]]; do
    if [[ -e "$dir/.git" ]]; then
      echo "$dir"
      return
    fi
    dir="$(dirname "$dir")"
  done
  echo ""
}

# Valid git repository: rev-parse succeeded and .git exists at that root
if [[ -n "$REPO_ROOT" && -e "$REPO_ROOT/.git" ]]; then
  REPO_HASH="$(echo -n "$REPO_ROOT" | shasum | cut -d' ' -f1)"
  LOCK_DIR="${LOCK_BASE}/${REPO_HASH}"
  LOCK_INFO="${LOCK_DIR}/pid"

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

  # Locked by another live session — deny
  REPO_NAME="$(basename "$REPO_ROOT")"
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Repository is locked by another Claude session (PID: ${lock_pid}). Create a worktree to work in parallel:\n  git worktree add ../${REPO_NAME}-wt-<branch> -b <branch>\n  cd ../${REPO_NAME}-wt-<branch>"}}
EOF
  exit 0
fi

# Not a valid git repo — check for phantom .git (broken/incomplete .git that git itself rejected)
PHANTOM_DIR="$(find_git_entry)"
if [[ -n "$PHANTOM_DIR" ]]; then
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"A .git entry exists at ${PHANTOM_DIR}/.git but git does not recognise it as a valid repository. The repo lock was skipped. Proceed with editing?"}}
EOF
fi

# No .git anywhere — allow silently
