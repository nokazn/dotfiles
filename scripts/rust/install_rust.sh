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
# @return {void}
function check_command() {
  if ! has_command "$1"; then
    echo "❌ command '$1' doesn't exist. Probably the command isn't installed correctly."
    exit 1
  fi
  return 0
}

# @param None
# @return {void}
function install_rust() {
  if has_command "cargo" && has_command "rustup"; then
    echo "✅ Rust is already installed at '$(which cargo)' and '$(which rustup)'"
    return 0
  fi

  echo "installing Rust ..."
  # TODO: expect コマンドで自動化
  if ! (curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh); then
    echo "❌ Rust has failed to be installed."
    return 1
  fi
  source ${PATH_SCRIPT}
  check_command "cargo"
  check_command "rustup"

  # cargo のパスから /bin/cargo を除く
  local -r cargo_path=$(which cargo | sed -e "s/\/bin\/cargo//")
  local -r rustup_path=$(rustup show home)
  echo "✅ Rust has been installed successfully at '${cargo_path}' and '${rustup_path}'!"
  return 0
}

install_rust
