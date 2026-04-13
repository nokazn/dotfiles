#!/usr/bin/env bash
set -uo pipefail

input=$(cat)
event="${CLAUDE_HOOK_EVENT:-}"

get_identifier() {
  local branch
  branch=$(git -C "$PWD" branch --show-current 2>/dev/null)
  if [[ -n "$branch" ]]; then
    echo "$branch"
    return
  fi
  basename "$PWD"
}

case "$event" in
  Stop)
    title="Claude Code"
    identifier=$(get_identifier)
    message="${identifier} が完了しました"
    ;;
  Notification)
    title="Claude Code"
    message=$(echo "$input" | jq -r '.message // "入力が必要です"')
    ;;
  *)
    exit 0
    ;;
esac

osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\""
