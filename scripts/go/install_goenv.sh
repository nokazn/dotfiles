#!/usr/bin/env bash

# @deprecated

set -eu -o pipefail

readonly PATH_SCRIPT=~/.path.sh

# @param {string} - command
# @return {0|1}
function has_command() {
  type "$1" >/dev/null 2>&1
  return $?
}

# @param {string} - command
# @param {string} - command
# @return {void}
function check_command() {
  if ! has_command "$1"; then
    echo "❌ command '$1' doesn't exist. Probably the command isn't installed correctly."
    exit 1
  fi
  return 0
}

# main -------------------------------------------------------------------------------

# @param None
# @return {void}
function install_goenv() {
  local -r goenv_path=~/.goenv
  if [[ -d ${goenv_path} ]] && has_command "goenv"; then
    echo "✅ goenv is already installed at '${goenv_path}'."
    return 0
  elif [[ -e ${goenv_path} ]]; then
    echo "❌ The other package exists at '${goenv_path}', but the path to goenv doesn't exist."
    exit 1
  fi

  echo "installing goenv ..."
  git clone https://github.com/syndbg/goenv.git ~/.goenv
  source ${PATH_SCRIPT}
  if ! has_command "goenv"; then
    echo "❌ goenv has failed to be installed at '${goenv_path}'"
    exit 1
  fi
  echo "✅ goenv has been installed successfully at '${goenv_path}'!"
  return 0
}

install_goenv
