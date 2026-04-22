#!/usr/bin/env bash
set -euo pipefail

STATUS_FILE="/tmp/claude-status-line-${CLAUDE_SESSION_ID:?}"
INPUT=$(cat 2>/dev/null || true)

DIR=""
if [[ -n "$INPUT" ]]; then
  DIR=$(echo "$INPUT" | jq -r '.new_cwd // .cwd // empty' 2>/dev/null || true)
fi
DIR="${DIR:-$PWD}"

BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null || echo "-")
printf '%s | %s' "$BRANCH" "$(basename "$DIR")" > "$STATUS_FILE"
