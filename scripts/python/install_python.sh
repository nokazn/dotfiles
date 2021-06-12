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
function install_python() {
  check_command "pyenv"

  if has_command "python"; then
    local python_version
    python_version=$(python --version | cut --delimiter " " -f 2)
    echo "Python ${python_version} is already installed at '$(which python)'."
    return 0
  fi

  local latest_version
  latest_version=$(pyenv install -l | grep -E "^\s*[0-9]{1,2}(\.[0-9]{1,2}){2}$" | tail -n 1 | awk '{print $1}')
  echo "installing Python the ${latest_version} (latest version of the major release) ..."
  pyenv install "${latest_version}"
  pyenv global "${latest_version}"
  # shellcheck disable=SC1090
  source ${PATH_SCRIPT}
  if ! has_command "python" || ! has_command "pip"; then
    echo "❌ Python ${latest_version} has failed to be installed."
    exit 1
  fi
  echo "✅ Python ${latest_version} has been installed successfully at '$(which python)'!"
  return 0
}

install_python
