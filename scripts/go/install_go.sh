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
function install_go() {
  # anyenv install を使えるようにする
  source ${PATH_SCRIPT}
  GOENV_PATH=~/.anyenv/envs/goenv/bin/goenv
  check_command ${GOENV_PATH}

  if has_command "go"; then
    local -r go_version=$(go version | sed -e "s/go version go//")
    echo "Go ${go_version} is already installed at '$(which go)'."
    return 0
  fi

  # 1.x.x の最新バージョンをインストールする
  local -r latest_version=$(${GOENV_PATH} install -l | grep -E "^\s*1(\.[0-9]{1,2}){2}" | tail -n 1 | awk '{print $1}')
  echo "installing Go ${latest_version} (latest version of the major release) ..."
  ${GOENV_PATH} install "${latest_version}"
  ${GOENV_PATH} global "${latest_version}"
  source ${PATH_SCRIPT}
  
  if ! has_command "go" ; then
    echo "❌ Go ${latest_version} has failed to be installed."
  fi
  echo "✅ Go ${latest_version} has been installed successfully at '$(which go)'!"
  return 0
}

install_go
