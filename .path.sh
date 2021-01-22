#!/bin/bash

# suppress errors in .bashrc
# set -o nounset
# set -o errexit
set -o pipefail

# nodenv
if [[ -d "$HOME/.nodenv" ]]; then
    export NODENV_ROOT="$HOME/.nodenv"
    export PATH="${NODENV_ROOT}/bin:$PATH"
    # nodenv コマンドが存在する場合
    if type "nodenv" > /dev/null 2>&1; then
        eval "$(nodenv init -)"
    fi
fi

# goenv
if [ -d "$HOME/.goenv" ]; then
    export GOENV_ROOT="$HOME/.goenv"
    export PATH="${GOENV_ROOT}/bin:$PATH"
    # goenv コマンドが存在する場合
    if type "goenv" > /dev/null 2>&1; then
        eval "$(goenv init -)"
        # GOROOT はよしなに設定してくれる
        export GOPATH="$HOME/go"
        export PATH="$PATH:${GOPATH}/bin"
        # Go Modules を有効にする
        export 'GO111MODULE=on'
    fi
fi

# pyenv
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="${PYENV_ROOT}/bin:$PATH"
    # pyenv コマンドが存在する場合
    if type "pyenv" > /dev/null 2>&1; then
        eval "$(pyenv init -)"
    fi
fi
# ユーザーインストールした pipenv
if [[ -e "$HOME/.local/bin/pipenv" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# deno
DENO_INSTALL="$HOME/.deno"
if [[ -d "${DENO_INSTALL}" ]]; then
    export DENO_INSTALL=$DENO_INSTALL
    export PATH="/${DENO_INSTALL}/bin:$PATH:"
fi

# Rust
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# TODO
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
SDKMAN_DIR="$HOME/.sdkman"
if [[ -d ${SDKMAN_DIR} ]]; then
    export SDKMAN_DIR="${SDKMAN_DIR}"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

# added by Nix installer
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# exit 0 とするとプロセスが終了し、source コマンドが反映されない
