#!/usr/bin/env bash

set -eu -o pipefail

function has_command() {
  type "$1" >/dev/null 2>&1
  return $?
}

# @param None
# @return {void}
function uninstall_deno() {
  if ! has_command "deno"; then
    echo "❌ Deno doesn't exist."
    return 0
  fi

  echo "uninstalling Deno ..."
  local deno_path
  deno_path=$(which deno | sed -e "s/\/bin\/deno//")
  rm -rf ${deno_path}
  echo "✅ Deno has been uninstalled successfully from '${deno_path}'."
  return 0
}

uninstall_deno
