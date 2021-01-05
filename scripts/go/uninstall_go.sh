#!/bin/bash

set nounset
set errexit

# @param {string} - command
# @return {0|1}
function has_command() {
  type $1 > /dev/null 2>&1
  return $?
}

# @param {string} - command
# @return {0|1}
function uninstall_go() {
  if ! has_command "goenv"; then
    echo "goenv doesn't exist."
    return 0
  fi

  read -rp "Do you really want to uninstall goenv? (Y/n) " response
  if [[ ! ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0;
  fi

  local goenv_root=$(goenv root)
  rm -rf ${goenv_root}
  if has_command "goenv"; then
    echo "❌ goenv has been failed to uninstalled from '${goenv_root}'."
    return 1
  fi
  echo "✅ goenv has been uninstalled successfully from '${goenv_root}'!."
  return 0
}

uninstall_go
exit $?
