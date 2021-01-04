#!/bin/bash

set nounset
set errexit

# @param {string} - command
# @return {0|1}
function has_command() {
  type $1 >/dev/null 2>&1
  return $?
}

# @param None
# @return {void}
function install_go() {
  local goenv_path=~/.goenv
  # goenv をインストール
  if [[ -d ${goenv_path} ]] && has_command goenv; then
    echo "✅ goenv is already installed at '${goenv_path}'."
  elif [[ -e ${goenv_path} ]]; then
    echo "❌ The Other package exists at '${goenv_path}', but the path to goenv doesn't exist."
    exit 1
  else
    echo "installing goenv ..."
    git clone https://github.com/syndbg/goenv.git ~/.goenv
    ~/.goenv/bin/goenv init
    if ! has_command goenv; then
      echo "❌ goenv has been failed to install."
      exit 1
    fi
    echo "✅ goenv has been installed successfully!"
  fi

  # Go の最新版をインストール
  if has_command go; then
    local go_version=$(go version  | sed -e "s/go version go//")
    echo "✅ Go ${go_version} is already installed at '$(which go)'."
  else
    # 1.x.x の最新バージョンをインストールする
    local latest_version=$(goenv install -l | grep -E "^\s+1(\.[0-9]{1,2}){2}" | tail -n 1 | awk '{print $1}')
    echo "installing Go ${latest_version} (latest version of 1.x) ..."
    goenv install ${latest_version}
    goenv global ${latest_version}
    if ! has_command go; then
      echo "❌ Go ${latest_version} has been failed to install."
      exit 1
    fi
    echo "✅ Go ${latest_version} has been installed successfully at '$(which go)!'"
  fi
  return 0
}

# @param None
# @return {void}
function run_go_get() {
  if ! has_command goenv; then
    echo "❌ goenv isn't installed correctly."
    exit 1
  elif ! has_command go; then
    echo "❌ Go isn't installed correctly."
    exit 1
  fi
  echo "installing go packages ..."

  go get -u github.com/motemen/ghq
  go get -u golang.org/x/tools/gopls

  goenv rehash
  echo "✅ go packages have been installed successfully!"
  return 0
}

install_go
run_go_get
exit 0
