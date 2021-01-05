#!/bin/bash

set nounset
set errexit

# @param None
# @return {void}
function install_rust() {
  echo "installing Rust ..."
  # TODO: expect コマンドで自動化
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh "1"
  if [[ $? -gt 0 ]]; then
    echo "❌ Rust has been failed to install."
    return 1
  fi
  # cargo のパスから /bin/cargo を除く
  local cargo_path=$(which cargo | sed -e "s/\/bin\/cargo//")
  local rustup_path=$(rustup show home)
  echo "✅ Rust has been installed successfully at '${cargo_path}' and '${rustup_path}'!"
  return 0
}

install_rust
exit $?
