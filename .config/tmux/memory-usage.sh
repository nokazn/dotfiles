#!/usr/bin/env bash

set -eu -o pipefail

function main() {
  local -r memory_usage=$(free -m | grep "Mem:")
  local -r total=$(echo ${memory_usage} | awk '{print $2}')
  local -r used=$(echo ${memory_usage} | awk '{print $3}')
  local -r used_percent=$(python -c "print(${used} / ${total} * 100)")
  echo "$(echo ${used_percent} | cut -b 1-4)"%
}

main
