#!/usr/bin/env bash

set -eu -o pipefail

# @param {string} - command
# @return {0|1}
function has_command() {
  type "$1" >/dev/null 2>&1
  return $?
}

# @param {string} - command
# @return {0|1}
function uninstall_anyenv() {
  if ! has_command "anyenv"; then
    echo "anyenv doesn't exist."
    return 0
  fi

  read -rp "Do you really want to uninstall anyenv? (Y/n) " response
  if [[ ! ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0;
  fi

  local -r anynv_root=$(anyenv root)
  rm -rf "${anynv_root}"
  rm -rf ~/.config/anyenv
  echo "✅ anyenv has been uninstalled successfully from '${anynv_root}'."
  return 0
}

uninstall_anyenv
exit $?
