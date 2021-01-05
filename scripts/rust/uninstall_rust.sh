#!/bin/bash

set nounset
set errexit

# @param None
# @return {void}
function uninstall_rust() {
  if ! type "rustup" > /dev/null 2>&1; then
    echo "❌ Rust ('rustup' command) doesn't exist."
    return 0
  elif ! type "cargo" > /dev/null 2>&1; then
    echo "❌ Rust ('cargo' command) doesn't exist."
    return 0
  fi

  # cargo のパスから /bin/cargo を除く
  local cargo_path=$(which cargo | sed -e "s/\/bin\/cargo//")
  local rustup_path=$(rustup show home)

  echo "uninstalling Rust ..."
  rustup self uninstall
  echo "✅ Rust has been uninstalled successfully from '${cargo_path}' and '${rustup_path}'!"
  return 0
}

uninstall_rust
exit 0
