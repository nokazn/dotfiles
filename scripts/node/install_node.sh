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
  check_command "nodenv"

  if has_command "node"; then
    local node_version
    node_version=$(node --version)
    echo "Node.js ${node_version} is already installed at '$(which node)'"
  else
    local latest_version
    latest_version=$(nodenv install -l | grep -E "^\s*[0-9]{1,2}(\.[0-9]{1,2}){2}" | tail -n 1 | awk '{print $1}')
    echo "installing Node.js ${latest_version} (latest version of the major release) ..."
    nodenv install "${latest_version}"
    nodenv global "${latest_version}"
    # shellcheck disable=SC1090
    source ${PATH_SCRIPT}
    if ! has_command "node" || ! has_command "npm" ; then
      "❌ Node.js ${latest_version} has failed to be installed."
    fi
    echo "✅ Node.js ${latest_version} has been installed successfully at '$(which node)'!"
  fi
  return 0
}

install_node
