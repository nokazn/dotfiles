#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

readonly PATH_SCRIPT=~/.path.sh

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

# @param {string} - package name
# @param {string?} - package location path
# @return {void}
function echo_success_message() {
  if [[ $2 ]]; then
    echo "✅ $1 has been installed successfully at '$2'!"
  else
    echo "✅ $1 has been installed successfully!"
  fi
  return 0
}

# @param {string} - package name
# @param {string?} - package location path
# @return {void}
function echo_fail_message() {
  if [[ $1 ]]; then
    echo "❌ $1 has been failed to install at '$2'."
  else
    echo "❌ $1 has been failed to install."
  fi
  exit 1
}

# @param {string} - package name
# @param {string} - package location path
# @return {void}
function echo_already_installed_message() {
  echo "✅ $1 is already installed at '$2'."
  return 0
}

# @param {string} - package name
# @return {void}
function install_nodenv_plugin() {
  local nodenv_root=$(nodenv root)
  local plugin_path="${nodenv_root}/plugins/$1"
  if [[ -d ${plugin_path} ]]; then
    echo_already_installed_message $1 ${plugin_path}
    return 0
  elif [[ -e ${plugin_path} ]]; then
    echo "❌ The other package exists at '${plugin_path}'."
    exit 1
  fi

  echo "installing $1 plugin ..."
  git clone "https://github.com/nodenv/$1.git" ${plugin_path}
  if [[ $? -gt 0 ]]; then
    echo_fail_message $1 ${plugin_path}
  fi
  echo_success_message $1 ${plugin_path}
  return 0
}

# main -------------------------------------------------------------------------------

# @param None
# @return {void}
function install_nodenv() {
  local nodenv_path=~/.nodenv
  if [[ -d ${nodenv_path} ]] && has_command nodenv; then
    echo_already_installed_message "nodenv" ${nodenv_path}
    return 0
  elif [[ -e ${nodenv_path} ]]; then
    echo "❌ The Other package exists at '${nodenv_path}', but the path to nodenv doesn't exist."
    exit 1
  fi

  echo "installing nodenv ..."
  git clone https://github.com/nodenv/nodenv.git ${nodenv_path}
  cd ${nodenv_path} && src/configure && make -C src
  ~/.nodenv/bin/nodenv init
  source ${PATH_SCRIPT}
  if ! has_command nodenv; then
    echo_fail_message "nodenv" ${nodenv_path}
  fi
  echo_success_message "nodenv" ${nodenv_path}
  return 0
}

# @param None
# @return {void}
function install_nodenv_plugins() {
  check_command "nodenv"

  install_nodenv_plugin "node-build"
  install_nodenv_plugin "nodenv-update"
  return 0
}

# @param None
# @return {void}
function install_node() {
  check_command "nodenv"

  if has_command node; then
    local node_version=$(node --version)
    echo_already_installed_message "Node.js ${node_version}" "$(which node)"
  else
    local latest_version=$(nodenv install -l | grep -E "^\s*[0-9]{1,2}(\.[0-9]{1,2}){2}" | tail -n 1 | awk '{print $1}')
    echo "installing Node.js ${latest_version} (latest version of the major release) ..."
    nodenv install ${latest_version}
    nodenv global ${latest_version}
    if ! has_command "node" || ! has_command "npm" ; then
      echo_fail_message "❌ Node.js ${latest_version}"
    fi
    echo_success_message "Node.js ${latest_version}" "$(which node)"
  fi
  return 0
}

install_nodenv
install_nodenv_plugins
install_node
