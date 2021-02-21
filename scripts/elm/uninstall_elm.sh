#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

readonly ELM_PATH=~/.local/bin.elm

# @param {string} - command
# @return {0|1}
function has_command() {
  type "$1" > /dev/null 2>&1
  return $?
}

# @param None
# @return {void}
function uninstall_elm() {
  if ! has_command "elm"; then
    echo "❌ Elm doesn't exist at '${ELM_PATH}'."
    return 0
  fi

  echo "uninstalling Elm ..."
  sudo rm -f ~/.local/bin/elm
  rm -rf ~/.elm
  echo "✅ Elm has been uninstalled successfully from '${ELM_PATH}'."
  return 0
}

uninstall_elm
