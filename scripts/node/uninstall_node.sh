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
# @return {0|1}
function uninstall_node() {
  if ! has_command "nodenv"; then
    echo "nodenv doesn't exist."
    return 0
  fi

  read -rp "Do you really want to uninstall nodenv? (Y/n) " response
  if [[ ! ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0;
  fi

  local nodenv_root=$(nodenv root)
  rm -rf ${nodenv_root}
  if has_command "nodenv"; then
    echo "❌ nodenv has been failed to uninstalled from '${nodenv_root}'."
    return 1
  fi
  echo "✅ nodenv has been uninstalled successfully from '${nodenv_root}'!"
  return 0
}

uninstall_node
exit $?
