#!/usr/bin/env bash

set -eu -o pipefail

# @param {string} - command
# @return {0|1}
function has_command() {
  type "$1" >/dev/null 2>&1
  return $?
}

# @param None
# @return {void}
function uninstall_rust() {
  if ! has_command "rustup"; then
    echo "❌ Rust ('rustup' command) doesn't exist."
    return 0
  elif ! has_command "cargo"; then
    echo "❌ Rust ('cargo' command) doesn't exist."
    return 0
  fi

  echo "uninstalling Rust ..."
  local cargo_path rustup_path
  # cargo のパスから /bin/cargo を除く
  cargo_path=$(which cargo | sed -e "s/\/bin\/cargo//")
  rustup_path=$(rustup show home)
  rustup self uninstall
  echo "✅ Rust has been uninstalled successfully from '${cargo_path}' and '${rustup_path}'."
  return 0
}

uninstall_rust
