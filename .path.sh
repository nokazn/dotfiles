# shellcheck disable=2148

# ----------------------------------------------------------------------------------------------------
# PATH environment variables
# ----------------------------------------------------------------------------------------------------

# @param {string}
# @return {string}
function _is_unregistered_path() {
	! (echo "$PATH" | grep -q "$1")
}

function _register_forward_if_not() {
	if _is_unregistered_path "$1"; then
		PATH="$1:${PATH}"
	fi
	return 0
}

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

# Go
if command -v go >/dev/null; then
	_goBinDir="$(go env GOBIN)"
	[[ -z ${_goBinDir} ]] && _goBinDir="$(go env GOPATH)/bin"
	[[ -z ${_goBinDir} ]] && _goBinDir="${HOME}/go/bin"
	_register_forward_if_not "${_goBinDir}"
fi

# Ruby
if command -v ruby >/dev/null; then
	_register_forward_if_not "$(ruby -e 'print Gem.user_dir')/bin"
fi

# Rust
if [[ -f "$HOME/.cargo/env" ]]; then
	# shellcheck source=~/.cargo/env
	source "$HOME/.cargo/env"
fi

# Nim (choosenim)
if [[ -d "$HOME/.nimble/bin" ]]; then
	_register_forward_if_not "$HOME/.nimble/bin"
fi

# Deno
if [[ -d "$HOME/.deno/bin" ]]; then
	_register_forward_if_not "$HOME/.deno/bin"
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
	if _is_unregistered_path "$HOME/.nix-profile"; then
		# shellcheck source=~/.nix-profile/etc/profile.d/nix.sh
		source "$HOME/.nix-profile/etc/profile.d/nix.sh"
	fi
	# asdf-vm installed by Nix
	# See https://github.com/NixOS/nixpkgs/blob/bacbfd713b4781a4a82c1f390f8fe21ae3b8b95b/pkgs/tools/misc/asdf-vm/default.nix#L60-L76
	if [[ -f "$HOME/.nix-profile/share/asdf-vm/asdf.sh" ]]; then
		# shellcheck source=~/.nix-profile/share/asdf-vm/asdf.sh
		source "$HOME/.nix-profile/share/asdf-vm/asdf.sh"
		fpath=("${ASDF_DIR}/completions" "${fpath[@]}")
	fi
fi
# darwinでの初期インストールのために必要
if [[ -d "/nix/var/nix/profiles/default/bin" ]]; then
	_register_forward_if_not "/nix/var/nix/profiles/default/bin"
fi
if [[ -f "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]]; then
	if _is_unregistered_path "/etc/profiles/per-user/$USER/bin"; then
		source "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
		PATH="/etc/profiles/per-user/$USER/bin:$PATH"
	fi
fi

# if command -v salias >/dev/null; then
#     source <(salias --init)
# fi

export PATH=$PATH
