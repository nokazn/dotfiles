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
function install_elm() {
  local ELM_PATH=~/.local/bin/elm
  if [[ -e ${ELM_PATH} ]] && has_command "elm"; then
    echo "✅ Elm is already installed at '${ELM_PATH}'."
    return 0
  elif [[ -e ${ELM_PATH} ]]; then
    echo "❌ The other package exists at '${ELM_PATH}', but the path to Elm doesn't exist."
    exit 1
  fi

  echo "installing Elm ..."
  mkdir -p ~/downloads
  mkdir -p ~/.local/bin
  curl --location --output ~/downloads/elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
  gunzip ~/downloads/elm.gz
  chmod +x ~/downloads/elm
  mv ~/downloads/elm ~/.local/bin/
  source ${PATH_SCRIPT}
  if ! has_command "elm"; then
    echo "❌ Elm has failed to be installed at '${ELM_PATH}'!"
  fi
  echo "✅ Elm has been installed successfully at '${ELM_PATH}'!"
  return 0
}

install_elm
