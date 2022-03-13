#!/usr/bin/env bash

set -eu -o pipefail

readonly PATH_SCRIPT=~/.path.sh

# @param None
# @return {void}
function install_terraform() {
  # anyenv install を使えるようにする
  source ${PATH_SCRIPT}
  TFENV_PATH=~/.anyenv/envs/tfenv/bin/tfenv

  if terraform --version >/dev/null 2>&1; then
    echo "Terraform is already installed at '$(which terraform)'"
    return 0
  fi

  # Terraform 最新版をインストール
  ${TFENV_PATH} install
  # Terraform 最新版を使う
  ${TFENV_PATH} use
  source ${PATH_SCRIPT}

  if ! has_command "terraform" ; then
    echo "❌ Terraform has failed to be installed."
  fi
  echo "✅ Terraform has been installed successfully at '$(which terraform)'!"
  return 0
}

install_terraform
