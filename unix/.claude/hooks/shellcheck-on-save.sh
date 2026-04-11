#!/usr/bin/env bash
set -euo pipefail

fp=$(jq -r '.tool_input.file_path // empty')
if [[ -n "$fp" ]] && [[ "$fp" == *.sh ]]; then
  shellcheck "$fp"
fi
