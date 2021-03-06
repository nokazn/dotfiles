#!/bin/bash

set -eu -o pipefail

# @param {string} - command
# @return {0|1}
function has_command() {
  type "$1" >/dev/null 2>&1
  return $?
}

# @param {string} - path to directory
# @return {void}
function rm_dir() {
  if [[ -d "$1" ]]; then
    rm -rI "$1"
  else
    echo "⚠ '$1' doesn't exist."
  fi
  return 0
}

# @param None
# @return {void}
function uninstall_nim() {
  if ! has_command "choosenim"; then
    echo "❌ Nim ('choosenim' command) doesn't exist."
    return 0
  fi

  echo "uninstalling Nim ..."
  local nimble_path choosenim_path
  nimble_path=$(which choosenim | sed -e "s/\/bin\/choosenim//")
  choosenim_path=~/.choosenim
  rm_dir "${nimble_path}"
  rm_dir ${choosenim_path}
  echo "✅ Nim has been uninstalled successfully from '${nimble_path}' and '${choosenim_path}'."
  return 0
}

uninstall_nim
