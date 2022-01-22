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
function install_node() {
  # anyenv install を使えるようにする
  source ${PATH_SCRIPT}
  NODENV_PATH=~/.anyenv/envs/nodenv/bin/nodenv
  check_command "${NODENV_PATH}"

  if has_command "node"; then
    local -r node_version=$(node --version)
    echo "Node.js ${node_version} is already installed at '$(which node)'"
    return
  fi

  local -r latest_version=$(${NODENV_PATH} install -l | grep -E "^\s*[0-9]{1,2}(\.[0-9]{1,2}){2}" | tail -n 1 | awk '{print $1}')
  echo "installing Node.js ${latest_version} (latest version of the major release) ..."
  ${NODENV_PATH} install "${latest_version}"
  ${NODENV_PATH} global "${latest_version}"
  source ${PATH_SCRIPT}

  if ! has_command "node" || ! has_command "npm" ; then
    echo "❌ Node.js ${latest_version} has failed to be installed."
  fi
  echo "✅ Node.js ${latest_version} has been installed successfully at '$(which node)'!"
  return 0
}

install_node
