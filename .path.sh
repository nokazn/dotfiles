#!/usr/bin/env bash

# @param {string}
# @return {string}
function is_unregistered_path() {
    ! (echo "$PATH" | grep -q "$1")
}

function register_forward_if_not() {
    if is_unregistered_path "$1"; then
        PATH="$1:${PATH}"
    fi
    return 0
}

function register_backward_if_not() {
    if is_unregistered_path "$1"; then
        PATH="${PATH}:$1"
    fi
    return 0
}

# ----------------------------------------------------------------------------------------------------

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/bin" ]]; then
    register_forward_if_not "$HOME/bin"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/.local/bin" ]]; then
    register_forward_if_not "$HOME/.local/bin"
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
    # TODO: 直す
    for dir in $(find ~/.anyenv/envs -mindepth 1 -maxdepth 1 -type d); do
        register_forward_if_not "${dir}/bin"
        register_forward_if_not "${dir}/shims"
    done
fi

# asdf-vm
if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    # shellcheck source=~/.asdf/asdf.sh
    source "$HOME/.asdf/asdf.sh"
    fpath=("${ASDF_DIR}/completions" "${fpath}")
fi

# Ruby
if command -v ruby >/dev/null; then
    register_forward_if_not "$(ruby -e 'print Gem.user_dir')/bin"
fi

# Rust
if [[ -f "$HOME/.cargo/env" ]]; then
    # shellcheck source=~/.cargo/env
    source "$HOME/.cargo/env"
fi

# Nim (choosenim)
if [[ -d "$HOME/.nimble/bin" ]]; then
    register_forward_if_not "$HOME/.nimble/bin"
fi

# TODO
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if [[ -d "$HOME/.sdkman" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
        # shellcheck source=~/.sdkman/bin/sdkman-init.sh
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi
fi

# Nix installer
if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    if is_unregistered_path "$HOME/.nix-profile"; then
        # shellcheck source=~/.nix-profile/etc/profile.d/nix.sh
        source "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
    # asdf-vm installed by Nix
    # See https://github.com/NixOS/nixpkgs/blob/bacbfd713b4781a4a82c1f390f8fe21ae3b8b95b/pkgs/tools/misc/asdf-vm/default.nix#L60-L76
    if [[ -f "$HOME/.nix-profile/share/asdf-vm/asdf.sh" ]]; then
        # shellcheck source=~/.nix-profile/share/asdf-vm/asdf.sh
        source "$HOME/.nix-profile/share/asdf-vm/asdf.sh"
    fi
fi

export PATH=$PATH

# exit 0 とするとプロセスが終了し、source コマンドが反映されない
