#!/usr/bin/env bash

set -e -o pipefail

readonly PATH_SCRIPT=~/.path.sh
readonly TOOL_VERSIONS=~/.tool-versions
ADD_PLUGIN_SCRIPT="$(
	cd "$(dirname "${0}")"
	pwd
)/plugin-add.sh"

function get-version() {
	local -r version="$(cat ${TOOL_VERSIONS} | grep "$1" | awk '{ print $2 }')"
	if [[ -z "${version}" ]]; then
		echo "latest"
	fi
	echo "${version}"
}

# @param {string} - asdfでのパッケージ名
# @param {string?} - 実行コマンド名
# @return {0|1}
function install() {
	# asdf を使えるようにする
	source ${PATH_SCRIPT}

	local executable="$1"
	if [[ "$2" ]]; then
		executable="$2"
	fi

	${ADD_PLUGIN_SCRIPT} "$1"
	local -r version=$(get-version "$1")
	asdf install "$1" "${version}"
	asdf global "$1" "${version}"

	# asdfの初期化スクリプトを読み込み直し、インストールした言語のパスを通す
	source ${PATH_SCRIPT}

	if ! type "${executable}" >/dev/null 2>&1; then
		echo "❌ $1 has failed to be installed."
		return 1
	fi
	echo "✅ $1 has been installed successfully at '$(command -v "${executable}")'!"
	return 0
}

install "$1" "$2"
