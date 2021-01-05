#!/bin/bash

set nounset
set errexit

# @param {string} - command
# @return {0|1}
function has_command() {
  type $1 > /dev/null 2>&1
  return $?
}

# @param None
# @return {void}
function uninstall_python() {
  if ! has_command "pyenv"; then
    echo "pyenv doesn't exist."
    return 0
  fi

  read -rp "Do you really want to uninstall pyenv? (Y/n) " response
  if [[ ! ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0;
  fi

  local pyenv_root=$(pyenv root)
  rm -rf ${pyenv_root}
  if has_command "pyenv"; then
    echo "❌ pyenv has been failed to uninstalled from '${pyenv_root}'."
    return 1
  fi
  echo "✅ pyenv has been uninstalled successfully from '${pyenv_root}'!"
  return 0
}

uninstall_python
exit $?
