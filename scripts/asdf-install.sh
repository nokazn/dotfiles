#!/usr/bin/env bash

set -e -o pipefail

readonly PATH_SCRIPT=~/.path.sh

# @param {string} - asdf でのパッケージ名
# @param {string?} - 実行コマンド名
# @return {0|1}
function install() {
	# asdf を使えるようにする
	source ${PATH_SCRIPT}

	local executable="$1"
	if [[ "$2" ]]; then
		executable="$2"
	fi

	if ! asdf plugin list | grep "$1" -q; then
		asdf plugin add "$1"
	fi
	asdf install "$1" latest
	asdf global "$1" latest

	if ! type "${executable}" >/dev/null 2>&1; then
		echo "❌ $1 has failed to be installed."
		return 1
	fi
	echo "✅ $1 has been installed successfully at '$(command -v "${executable}")'!"
	return 0
}

install "$1" "$2"
