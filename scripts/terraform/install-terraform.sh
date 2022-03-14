#!/usr/bin/env bash

set -eu -o pipefail

readonly PATH_SCRIPT=~/.path.sh

# @param None
# @return {void}
function install_terraform() {
  # anyenv install を使えるようにする
  source ${PATH_SCRIPT}

  if terraform --version >/dev/null 2>&1; then
    echo "Terraform is already installed at '$(command -v terraform)'"
    return 0
  fi

  if ! asdf plugin list | grep terraform -q; then
    asdf plugin add terraform
  fi
  asdf install terraform latest
  asdf global terraform latest

  if ! type "terraform" >/dev/null 2>&1 ; then
    echo "❌ Terraform has failed to be installed."
    return 1
  fi
  echo "✅ Terraform has been installed successfully at '$(command -v terraform)'!"
  return 0
}

install_terraform
