#!/usr/bin/env bash

# @param {string}
# @return {string}
function is_unregistered_path() {
    ! (echo "$PATH" | grep -q "$1")
}

function regester_forward_if_not() {
    is_unregistered_path "$1" && PATH="$1:${PATH}"
}

function regester_backward_if_not() {
    is_unregistered_path "$1" && PATH="${PATH}:$1"
}

# ----------------------------------------------------------------------------------------------------

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/bin" ]] && is_unregistered_path "$HOME/bin"; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/.local/bin" ]] && is_unregistered_path "$HOME/.local/bin"; then
    PATH="$HOME/.local/bin:$PATH"
fi

# anyenv
if [[ -d "$HOME/.anyenv" ]]; then
    if is_unregistered_path "$HOME/.anyenv/bin"; then
        PATH="$HOME/.anyenv/bin:$PATH"
        # anyenv コマンドが存在する場合
        if type "anyenv" >/dev/null 2>&1; then
            eval "$(anyenv init -)"
        fi
    fi
    for file in  ~/.anyenv/envs/*; do
        regester_forward_if_not "$HOME/.anyenv/envs/$(basename "${file}")/bin"
        regester_forward_if_not "$HOME/.anyenv/envs/$(basename "${file}")/shims"
    done
fi

# Deno
if [[ -d "$HOME/.deno" ]]; then
    if is_unregistered_path "$HOME/.deno/bin"; then
        export DENO_INSTALL="$HOME/.deno"
        PATH="$HOME/.deno/bin:$PATH:"
    fi
fi

# Rust
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# Nim (choosenim)
if [[ -d "$HOME/.nimble/bin" ]]; then
    regester_forward_if_not "$HOME/.nimble/bin:$PATH"
fi

# TODO
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if [[ -d "$HOME/.sdkman" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Nix installer
if [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    if is_unregistered_path "$HOME/.nix-profile"; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
fi

export PATH=$PATH

# exit 0 とするとプロセスが終了し、source コマンドが反映されない
