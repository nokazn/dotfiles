#!/usr/bin/env bash
set -uo pipefail

input=$(cat)
event="${CLAUDE_HOOK_EVENT:-}"

# $TERM_PROGRAM から起動元アプリの bundle ID を解決する
get_bundle_id() {
  case "${TERM_PROGRAM:-}" in
    vscode)         echo "com.microsoft.VSCode" ;;
    WezTerm)        echo "com.github.wez.wezterm" ;;
    iTerm.app)      echo "com.googlecode.iterm2" ;;
    Apple_Terminal) echo "com.apple.Terminal" ;;
  esac
}

# --no-session-persistence で起動されていたら通知しない
# プロセスツリーを辿って claude プロセスの引数を確認する
has_session_persistence() {
  local pid=$PPID
  for _ in 1 2 3 4 5; do
    local args
    args=$(ps -p "$pid" -o args= 2>/dev/null || true)
    if echo "$args" | grep -qE '(claude|@anthropic-ai)'; then
      echo "$args" | grep -q -- '--no-session-persistence' && return 1
      return 0
    fi
    pid=$(ps -p "$pid" -o ppid= 2>/dev/null | tr -d ' ' || true)
    [[ -z "$pid" || "$pid" == "1" ]] && break
  done
  return 0
}

# ターミナルがフォアグラウンドにある場合は通知しない
is_terminal_foreground() {
  local bundle_id
  bundle_id=$(get_bundle_id)
  [[ -z "$bundle_id" ]] && return 1
  local frontmost
  frontmost=$(osascript -e "tell application \"System Events\" to get frontmost of first application process whose bundle identifier is \"$bundle_id\"" 2>/dev/null || true)
  [[ "$frontmost" == "true" ]]
}

get_identifier() {
  local branch
  branch=$(git -C "$PWD" branch --show-current 2>/dev/null)
  if [[ -n "$branch" ]]; then
    echo "$branch"
    return
  fi
  basename "$PWD"
}

send_notification() {
  local title="$1"
  local message="$2"
  osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\""
}

case "$event" in
  Stop)
    has_session_persistence || exit 0
    is_terminal_foreground && exit 0
    identifier=$(get_identifier)
    send_notification "Claude Code" "${identifier} が完了しました"
    ;;
  Notification)
    is_terminal_foreground && exit 0
    message=$(echo "$input" | jq -r '.message // "入力が必要です"')
    send_notification "Claude Code" "$message"
    ;;
  *)
    exit 0
    ;;
esac
