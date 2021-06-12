#!/usr/bin/env bash

# @deprecated

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

# @param {string} - package name
# @return {void}
function install_nodenv_plugin() {
  local nodenv_root
  nodenv_root=$(nodenv root)
  local plugin_path="${nodenv_root}/plugins/$1"
  if [[ -d ${plugin_path} ]]; then
    echo "✅ $1 is already installed at '${plugin_path}'."
    return 0
  elif [[ -e ${plugin_path} ]]; then
    echo "❌ The other package exists at '${plugin_path}'."
    exit 1
  fi

  echo "installing $1 plugin ..."
  if ! (git clone "https://github.com/nodenv/$1.git" "${plugin_path}"); then
    echo "❌ $1 has failed to be installed at '${plugin_path}'."
    exit 1
  fi
  echo "✅ $1 has been installed successfully at '${plugin_path}'."
  return 0
}

# main -------------------------------------------------------------------------------

# @param None
# @return {void}
function install_nodenv() {
  local nodenv_path=~/.nodenv
  if [[ -d ${nodenv_path} ]] && has_command nodenv; then
    echo "✅ noednv is already installed at '${nodenv_path}'."
    return 0
  elif [[ -e ${nodenv_path} ]]; then
    echo "❌ The Other package exists at '${nodenv_path}', but the path to nodenv doesn't exist."
    exit 1
  fi

  echo "installing nodenv ..."
  git clone https://github.com/nodenv/nodenv.git ${nodenv_path}
  # Optionally, try to compile dynamic bash extension to speed up nodenv. Don't worry if it fails; nodenv will still work normally
  # https://github.com/nodenv/nodenv#basic-github-checkout
  # if ! bash -c "cd ${nodenv_path} && src/configure && make -C src" || true; then
  #   echo "⚠ Failed to execute make or configure scripts."
  # fi
  # shellcheck disable=SC1090
  source ${PATH_SCRIPT}
  if ! has_command "nodenv"; then
    echo "❌ nodenv has failed to be installed at '${nodenv_path}'."
    exit 1
  fi
  echo "✅ nodenv has been installed successfully at '${nodenv_path}'!"
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

install_nodenv
install_nodenv_plugins
