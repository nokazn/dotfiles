#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

# @param {string} - command
# @return {0|1}
function has_command() {
  type $1 > /dev/null 2>&1
  return $?
}

# @param {string} - command
# @param {string} - command
# @return {void}
function check_command() {
  if ! has_command $1; then
    echo "❌ command '$1' doesn't exist. Probably the command isn't installed correctly."
    exit 1
  fi
  return 0
}

# main -------------------------------------------------------------------------------

# @param None
# @return {void}
function install_elm() {
  local elm_path=~/.local/bin/elm
  if [[ -d ${elm_path} ]] && has_command "elm"; then
    echo "✅ Elm is already installed at '${elm_path}'."
    return 0
  elif [[ -e ${elm_path} ]]; then
    echo "❌ The other package exists at '${elm_path}', but the path to Elm doesn't exist."
    exit 1
  fi

  echo "installing Elm ..."
  curl --location --output ~/downloads/elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
  gunzip ~/downloads/elm.gz
  chmod +x ~/downloads/elm
  mv ~/downloads/elm ~/.local/bin/
  if ! has_command "elm"; then
    "❌ Elm has failed to be installed at '${elm_path}'!"
  fi
  "✅ Elm has been installed successfully at '${elm_path}'!"
  return 0
}

install_elm
exit 0
