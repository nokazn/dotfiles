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
if [[ -d "$HOME/bin" ]]; then
    regester_forward_if_not "$HOME/bin"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/.local/bin" ]]; then
    regester_forward_if_not "$HOME/.local/bin"
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
    for file in $(find ~/.anyenv/envs -mindepth 1 -type d); do
        regester_forward_if_not "$HOME/.anyenv/envs/$(basename "${file}")/bin"
        regester_forward_if_not "$HOME/.anyenv/envs/$(basename "${file}")/shims"
    done
fi

# Deno
if [[ -d "$HOME/.deno" ]]; then
    regester_forward_if_not "$HOME/.deno/bin"
    export DENO_INSTALL="$HOME/.deno"
fi

# Rust
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# Nim (choosenim)
if [[ -d "$HOME/.nimble/bin" ]]; then
    regester_forward_if_not "$HOME/.nimble/bin"
fi

# TODO
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if [[ -d "$HOME/.sdkman" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi
fi

# Nix installer
if [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    if is_unregistered_path "$HOME/.nix-profile"; then
        source "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
fi

export PATH=$PATH

# exit 0 とするとプロセスが終了し、source コマンドが反映されない
