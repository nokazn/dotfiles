#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat 2>/dev/null || true)

RESET=$'\033[0m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
DIM=$'\033[2m'

color_for_percent() {
  local pct=${1:-0}
  if (( pct >= 80 )); then
    printf '%s' "$RED"
  elif (( pct >= 50 )); then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

five_hour=""
seven_day=""
ctx_pct=""

if [[ -n "$INPUT" ]]; then
  five_hour=$(printf '%s' "$INPUT" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null || true)
  seven_day=$(printf '%s' "$INPUT" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null || true)

  ctx_used=$(printf '%s' "$INPUT" | jq -r '.context_window.used // empty' 2>/dev/null || true)
  ctx_total=$(printf '%s' "$INPUT" | jq -r '.context_window.total // empty' 2>/dev/null || true)

  if [[ -n "$ctx_used" && -n "$ctx_total" && "$ctx_total" -gt 0 ]]; then
    ctx_pct=$(( ctx_used * 100 / ctx_total ))
  fi
fi

output=""

if [[ -n "$five_hour" ]]; then
  color=$(color_for_percent "$five_hour")
  output+="${DIM}5h:${RESET}${color}${five_hour}%${RESET}"
fi

if [[ -n "$seven_day" ]]; then
  [[ -n "$output" ]] && output+=" ${DIM}|${RESET} "
  color=$(color_for_percent "$seven_day")
  output+="${DIM}7d:${RESET}${color}${seven_day}%${RESET}"
fi

if [[ -n "$ctx_pct" ]]; then
  [[ -n "$output" ]] && output+=" ${DIM}|${RESET} "
  color=$(color_for_percent "$ctx_pct")
  output+="${DIM}ctx:${RESET}${color}${ctx_pct}%${RESET}"
fi

STATUS_FILE="/tmp/claude-status-line-${CLAUDE_SESSION_ID:-}"
if [[ -n "${CLAUDE_SESSION_ID:-}" && -f "$STATUS_FILE" ]]; then
  branch_dir=$(cat "$STATUS_FILE")
else
  branch=$(git branch --show-current 2>/dev/null || echo "-")
  branch_dir="${branch} | $(basename "$PWD")"
fi

[[ -n "$output" ]] && output+=" ${DIM}|${RESET} "
output+="$branch_dir"

printf '%s' "$output"
