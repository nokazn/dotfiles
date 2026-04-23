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
	if ((pct >= 80)); then
		printf '%s' "$RED"
	elif ((pct >= 50)); then
		printf '%s' "$YELLOW"
	else
		printf '%s' "$GREEN"
	fi
}

five_hour=""
seven_day=""
ctx_pct=""
model=""
cwd=""

if [[ -n "$INPUT" ]]; then
	five_hour=$(printf '%s' "$INPUT" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null || true)
	seven_day=$(printf '%s' "$INPUT" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null || true)

	ctx_pct=$(printf '%s' "$INPUT" | jq -r '.context_window.used_percentage // empty' 2>/dev/null || true)
	if [[ -n "$ctx_pct" ]]; then
		ctx_pct=$(printf '%.0f' "$ctx_pct")
	fi

	model=$(printf '%s' "$INPUT" | jq -r '.model.display_name // .model.id // .model // empty' 2>/dev/null || true)
	cwd=$(printf '%s' "$INPUT" | jq -r '.cwd // .workspace.current_dir // empty' 2>/dev/null || true)
fi

output=""

if [[ -n "$model" ]]; then
	output+="${DIM}${model}${RESET}"
fi

if [[ -n "$five_hour" ]]; then
	[[ -n "$output" ]] && output+=" ${DIM}|${RESET} "
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

target_dir="${cwd:-$PWD}"
branch=$(git -C "$target_dir" branch --show-current 2>/dev/null || echo "-")
branch_dir="${branch} | $(basename "$target_dir")"

[[ -n "$output" ]] && output+=" ${DIM}|${RESET} "
output+="$branch_dir"

printf '%s' "$output"
