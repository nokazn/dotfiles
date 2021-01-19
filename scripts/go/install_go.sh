#!/bin/bash

set nounset
set errexit

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

# main -------------------------------------------------------------------------------

# @param None
# @return {void}
function install_goenv() {
  local goenv_path=~/.goenv
  if [[ -d ${goenv_path} ]] && has_command "goenv"; then
    echo_already_installed_message "goenv" ${goenv_path}
    return 0
  elif [[ -e ${goenv_path} ]]; then
    echo "❌ The other package exists at '${goenv_path}', but the path to goenv doesn't exist."
    exit 1
  fi

  echo "installing goenv ..."
  git clone https://github.com/syndbg/goenv.git ~/.goenv
  ~/.goenv/bin/goenv init
  source ${PATH_SCRIPT}
  if ! has_command "goenv"; then
    echo_fail_message "goenv"  ${nodenv_path}
  fi
  echo_success_message "goenv" ${goenv_path}
  return 0
}

# @param None
# @return {void}
function install_go() {
  check_command "goenv"

  # Go の最新版をインストール
  if has_command "go"; then
    local go_version=$(go version | sed -e "s/go version go//")
    echo_already_installed_message "Go ${go_version}" "$(which go)"
    return 0
  fi

  # 1.x.x の最新バージョンをインストールする
  local latest_version=$(goenv install -l | grep -E "^\s*1(\.[0-9]{1,2}){2}" | tail -n 1 | awk '{print $1}')
  echo "installing Go ${latest_version} (latest version of the major release) ..."
  goenv install ${latest_version}
  goenv global ${latest_version}
  if ! has_command "go"; then
    echo_fail_message "Go ${latest_version}"
  fi
  echo_success_message "Go ${latest_version}" "$(which go)"
  return 0
}

install_goenv
install_go
