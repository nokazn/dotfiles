#!/usr/bin/env bash

# @param {string}
# @return {string}
function is_unregistered_path() {
    ! (echo "$PATH" | grep -q "$1")
}

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/bin" ]]; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/.local/bin" ]]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Node.js (nodenv)
if [[ -d "$HOME/.nodenv" ]]; then
    if is_unregistered_path "$HOME/.nodenv"; then
        export NODENV_ROOT="$HOME/.nodenv"
        PATH="${NODENV_ROOT}/bin:$PATH"
        # nodenv コマンドが存在する場合
        if type "nodenv" >/dev/null 2>&1; then
            eval "$(nodenv init -)"
        fi
    fi
else
    echo "⚠ nodenv doesn't exist at '$HOME/.nodenv'."
fi

# Golang (goenv)
if [ -d "$HOME/.goenv" ]; then
    if is_unregistered_path "$HOME/.goenv"; then
        export GOENV_ROOT="$HOME/.goenv"
        export PATH="${GOENV_ROOT}/bin:$PATH"
        # goenv コマンドが存在する場合
        if type "goenv" >/dev/null 2>&1; then
            eval "$(goenv init -)"
            # GOROOT はよしなに設定してくれる
            export GOPATH="$HOME/go"
            PATH="$PATH:${GOPATH}/bin"
            # Go Modules を有効にする
            export 'GO111MODULE=on'
        fi
    fi
else
    echo "⚠ goenv doesn't exist at '$HOME/.goenv'."
fi

# Python (pyenv)
if [[ -d "$HOME/.pyenv" ]]; then
    if is_unregistered_path "$HOME/.pyenv"; then
        export PYENV_ROOT="$HOME/.pyenv"
        PATH="${PYENV_ROOT}/bin:$PATH"
        # pyenv コマンドが存在する場合
        if type "pyenv" >/dev/null 2>&1; then
            eval "$(pyenv init -)"
        fi
    fi
else
    echo "⚠ pyenv doesn't exist at '$HOME/.pyenv'"
fi
# ユーザーインストールした pipenv
if [[ ! -e "$HOME/.local/bin/pipenv" ]]; then
    echo "⚠ pipenv doesn't exist at '$HOME/.local/bin/pipenv'."
fi

# Deno
if [[ -d "$HOME/.deno" ]]; then
    if is_unregistered_path "$HOME/.deno"; then
        export DENO_INSTALL="$HOME/.deno"
        PATH="$HOME/.deno/bin:$PATH:"
    fi
else
    echo "⚠ Deno doesn't exist at '$HOME/.deno'"
fi

# Rust
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
else
    echo "⚠ cargo doesn't exist at '$HOME/.cargo'"
fi

# Nim (choosenim)
if [[ -d "$HOME/.nimble/bin" ]]; then
    if is_unregistered_path "$HOME/.nimble"; then
        PATH="$HOME/.nimble/bin:$PATH"
    fi
else
    echo "⚠ Nim doesn't exist at '$HOME/.nimble'"
fi

# TODO
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if [[ -d "$HOME/.sdkman" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# added by Nix installer
if [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    if is_unregistered_path "$HOME/.nix-profile"; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
fi

# mkcert
if [[ -d "$HOME/.mkcert" ]]; then
    if is_unregistered_path "$HOME/.mkcert"; then
        PATH="$HOME/.mkcert:$PATH"
    fi
fi

export PATH=$PATH

# exit 0 とするとプロセスが終了し、source コマンドが反映されない
