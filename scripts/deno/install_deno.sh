#!/usr/bin/env bash

set -eu -o pipefail

readonly PATH_SCRIPT=~/.path.sh

# @param {string} - command
# @return {0|1}
function has_command() {
  type "$1" >/dev/null 2>&1
  return $?
}

# @param {string} - command
# @return {void}
function check_command() {
  if ! has_command "$1"; then
    echo "❌ command '$1' doesn't exist. Probably the command isn't installed correctly."
    exit 1
  fi
  return 0
}

# @param None
# @return {void}
function install_deno() {
  if has_command "deno"; then
    echo "✅ Deno is already installed at $(which deno)"
    return 0
  fi

  echo "installing Deno ..."
  if ! (curl -fsSL https://deno.land/x/install/install.sh | sh); then
    echo "❌ Deno has failed to be installed."
    return 1
  fi

  source ${PATH_SCRIPT}
  check_command "deno"

  local -r deno_path=$(which deno | sed -e "s/\/bin\/deno//")
  echo "✅ Deno has been installed successfully at '${deno_path}'!"
  return 0
}

install_deno
