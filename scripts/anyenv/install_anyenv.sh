#!/usr/bin/env bash

set -eu -o pipefail

# @param {string} - command
# @return {0|1}
function has_command() {
  type "$1" >/dev/null 2>&1
  return $?
}

function install_anyenv() {
  local anyenv_path=~/.anyenv
  if [[ -d ${anyenv_path} ]] && has_command "anyenv"; then
    echo "anyenv is already installed at $(which anyenv)"
    return 0
  elif [[ -e ${anyenv_path} ]]; then
    echo "❌ The Other package exists at '${anyenv_path}', but the path to anyenv doesn't exist."
    exit 1
  fi

  echo "installing anyenv ..."
  git clone  https://github.com/anyenv/anyenv.git ${anyenv_path} 2>/dev/null
  eval "$(~/.anyenv/bin/anyenv init -)"
  if [[ ! -d ~/.config/anyenv/anyenv-install ]]; then
    ~/.anyenv/bin/anyenv install --init
  fi
  if ! has_command "anyenv"; then
    echo "❌ anyenv has failed to be installed at '${anyenv_path}'."
    exit 1
  fi
  echo "✅ anyenv has been installed successfully at '${anyenv_path}'!"
  return 0
}

install_anyenv
