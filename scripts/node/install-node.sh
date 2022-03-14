#!/usr/bin/env bash

set -eu -o pipefail

readonly PATH_SCRIPT=~/.path.sh

# @param None
# @return {void}
function install_node() {
  # anyenv install を使えるようにする
  source ${PATH_SCRIPT}

  if node --version >/dev/null 2>&1; then
    echo "Node.js is already installed at '$(command -v node)'"
    return 0
  fi

  if ! asdf plugin list | grep nodejs -q; then
    asdf plugin add nodejs
  fi
  asdf install nodejs latest
  asdf global nodejs latest

  if ! type "node" >/dev/null 2>&1 ; then
    echo "❌ Node.js has failed to be installed."
    return 1
  fi
  echo "✅ Node.js has been installed successfully at '$(command -v node)'!"
  return 0
}

install_node
