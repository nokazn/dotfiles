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
function install_pyenv() {
  local pyenv_path=~/.pyenv
  if [[ -d ${pyenv_path} ]]; then
    echo "✅ pyenv is already installed at '${pyenv_path}'."
    return 0
  elif [[ -e ${pyenv_path} ]]; then
    echo "❌ The other package exists at '${pyenv_path}', but the path to pyenv doesn't exist."
    exit 1
  fi

  echo "installing pyenv ..."
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  # if ! (cd ~/.pyenv && src/configure && make -C src) >/dev/null 2>&1; then
  #   echo "⚠ Failed to execute make or configure scripts."
  # fi
  source ${PATH_SCRIPT}
  if ! has_command "pyenv" ${pyenv_path}; then
    echo "❌ pyenv has failed to be installed at '${pyenv_path}'."
    exit 1
  fi
  echo "✅ pyenv has been installed successfully at '${pyenv_path}'!"
  return 0
}
