#!/usr/bin/env bash

set -eu -o pipefail

readonly PATH_SCRIPT=~/.path.sh

# @param {string} - command
# @return {void}
function check_command() {
  if ! type "$1" >/dev/null 2>&1; then
    echo "❌ command '$1' doesn't exist. Probably the command isn't installed correctly."
    exit 1
  fi
  return 0
}

# @param None
# @return {void}
function install_nim() {
  echo "installing Nim ..."
  if ! (curl https://nim-lang.org/choosenim/init.sh -sSf | sh); then
    echo "❌ Nim has failed to be installed."
    return 1
  fi
  # shellcheck disable=SC1090
  source ${PATH_SCRIPT}
  check_command "choosenim"
  echo "✅ Nim has been installed successfully!"
  return 0
}

install_nim
