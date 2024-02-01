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
	# `/`を`\/`にエスケープ
	local -r p=$(sed -E -e "s/\//\\\\\//g" <<<"$1")
	PATH=$(sed -E -e "s/:${p}//" <<<"$PATH" | sed -E -e "s/^/${p}:/")
	return 0
}

# パスが追加されていなければ、末尾に追加する
function _register_backward_if_not() {
	if _is_unregistered_path "$1"; then
		PATH="${PATH}:$1"
	fi
	return 0
}

# @return "bash" | "zsh" | "fish" ("bash" as fallback)
function _detect_shell() {
	local -r shell="$(basename "$SHELL")"
	case ${shell} in
	"bash" | "zsh" | "fish")
		echo "${shell}"
		;;
	*)
		echo "bash"
		;;
	esac
}

# 初期化スクリプトを読み込む
function _apply-nix-profiles() {
	local -r all_profiles=$(find "$1" -mindepth 1 -maxdepth 1 -type f)
	local pattern
	case $(_detect_shell) in
	"bash")
		pattern=".+\.(ba)?sh$"
		;;
	"zsh")
		pattern=".+\.(ba|z)?sh$"
		;;
	*)
		pattern=".+\.sh$"
		;;
	esac
	grep -E -e "${pattern}" <<<"${all_profiles}" | while read -r dir; do
		source "${dir}"
	done
}

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/bin" ]]; then
	_register_forward_if_not "$HOME/bin"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/.local/bin" ]]; then
	_register_forward_if_not "$HOME/.local/bin"
fi

# anyenv
if [[ -d "$HOME/.anyenv" ]]; then
	if _is_unregistered_path "$HOME/.anyenv/bin"; then
		PATH="$HOME/.anyenv/bin:$PATH"
		# anyenv コマンドが存在する場合
		if type "anyenv" >/dev/null 2>&1; then
			eval "$(anyenv init -)"
		fi
	fi
	# `~/.anyenv/envs` 配下の `bin` と `shims` ディレクトリをパスとして登録
	find ~/.anyenv/envs -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
		_register_forward_if_not "${dir}/bin"
		_register_forward_if_not "${dir}/shims"
	done
fi

# # Go
if command -v go >/dev/null; then
	_goBinDir="$(go env GOBIN)"
	[[ -z ${_goBinDir} ]] && _goBinDir="$(go env GOPATH)/bin"
	[[ -z ${_goBinDir} ]] && _goBinDir="${HOME}/go/bin"
	_register_forward "${_goBinDir}"
fi

# Ruby
if command -v ruby >/dev/null; then
	_register_forward "$(ruby -e 'print Gem.user_dir')/bin"
fi

# Rust
if [[ -f "$HOME/.cargo/env" ]]; then
	# shellcheck source=~/.cargo/env
	source "$HOME/.cargo/env"
fi

# Nim (choosenim)
if [[ -d "$HOME/.nimble/bin" ]]; then
	_register_forward "$HOME/.nimble/bin"
fi

# Deno
if [[ -d "$HOME/.deno/bin" ]]; then
	_register_forward "$HOME/.deno/bin"
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

# Nix (single user)
if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
	if _is_unregistered_path "$HOME/.nix-profile"; then
		# shellcheck source=~/.nix-profile/etc/profile.d/nix.sh
		source "$HOME/.nix-profile/etc/profile.d/nix.sh"
	fi
	_apply-nix-profiles "$HOME/.nix-profile/etc/profile.d/"
fi

# Nix (multi user)
if [[ -d "/nix/var/nix/profiles/default/bin" ]]; then
	# darwinでの初期インストールのために必要
	_register_forward "/nix/var/nix/profiles/default/bin"
fi
if [[ -d "/etc/profiles/per-user/$USER/bin" ]]; then
	_register_forward "/etc/profiles/per-user/$USER/bin"

	_apply-nix-profiles "/etc/profiles/per-user/$USER/etc/profile.d/"
fi

# if command -v salias >/dev/null; then
#     source <(salias --init)
# fi

export PATH=$PATH
