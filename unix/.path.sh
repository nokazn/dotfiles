#!/usr/bin/env bash

# ----------------------------------------------------------------------------------------------------
# PATH environment variables
# ----------------------------------------------------------------------------------------------------

# @param {string}
# @return {string}
function _is_unregistered_path() {
	! (echo "$PATH" | grep -q "$1")
}

# パスが追加されていなければ、先頭に追加する
function _register_forward_if_not() {
	if _is_unregistered_path "$1"; then
		PATH="$1:${PATH}"
	fi
	return 0
}

# パスが追加されていても、先頭に移動する
function _register_forward() {
	[[ -d $1 ]] || return 0
	local path=":${PATH}:"
	path="${path//:$1:/:}"
	path="${path#:}"
	PATH="$1:${path%:}"
	return 0
}

# パスが追加されていなければ、末尾に追加する
function _register_backward_if_not() {
	if _is_unregistered_path "$1"; then
		PATH="${PATH}:$1"
	fi
	return 0
}

# Go
# proto の shim 経由で go を実行すると auto-install 等の出力が混入して PATH が壊れるため、go env を使わずに解決する
_goBinDir="${GOBIN:-${GOPATH:-$HOME/go}/bin}"
_register_forward "${_goBinDir}"

# Ruby
if command -v ruby >/dev/null; then
	_register_forward "$(ruby -e 'print Gem.user_dir')/bin"
fi

# Rust
if [[ -f "$HOME/.cargo/env" ]]; then
	# shellcheck source=~/.cargo/env
	source "$HOME/.cargo/env"
fi

if [[ -d "$HOME/.cargo/bin" ]]; then
	_register_forward "$HOME/.cargo/bin"
fi

# Nim (choosenim)
if [[ -d "$HOME/.nimble/bin" ]]; then
	_register_forward "$HOME/.nimble/bin"
fi

# Deno
if [[ -d "$HOME/.deno/bin" ]]; then
	_register_forward "$HOME/.deno/bin"
fi

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if [[ -d "$HOME/.sdkman" ]]; then
	export SDKMAN_DIR="$HOME/.sdkman"
	if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
		# shellcheck source=~/.sdkman/bin/sdkman-init.sh
		source "$HOME/.sdkman/bin/sdkman-init.sh"
	fi
fi

# Nix (single user)
if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
	if _is_unregistered_path "$HOME/.nix-profile/bin"; then
		# shellcheck source=~/.nix-profile/etc/profile.d/nix.sh
		source "$HOME/.nix-profile/etc/profile.d/nix.sh"
	fi
fi

# Nix (multi user)
if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
	source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
if [[ -d "/nix/var/nix/profiles/default/bin" ]]; then
	# darwinでの初期インストールのために必要
	_register_forward "/nix/var/nix/profiles/default/bin"
fi
if [[ -d "/etc/profiles/per-user/$USER/bin" ]]; then
	_register_forward "/etc/profiles/per-user/$USER/bin"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/bin" ]]; then
	_register_forward_if_not "$HOME/bin"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/.local/bin" ]]; then
	_register_forward_if_not "$HOME/.local/bin"
fi

# proto
if [[ -d "$HOME/.proto" ]]; then
	export PROTO_HOME="$HOME/.proto"
	_register_forward "${PROTO_HOME}/bin"
	_register_forward "${PROTO_HOME}/shims"
	# パス追加時に https://github.com/moonrepo/proto/blob/7b9e3b7785e49e7a8d323b307151a842af6084e8/crates/cli/src/systems.rs#L81-L148 の出力でsedコマンドでエラーになってしまうのを防ぐため
	export PROTO_VERSION_CHECK=0
fi

# fnm
if command -v fnm >/dev/null; then
	eval "$(fnm env --use-on-cd)"
fi

# if command -v salias >/dev/null; then
#     source <(salias --init)
# fi

export PATH=$PATH
