#!/usr/bin/env bash

set -e -o pipefail

readonly TOOL_VERSIONS=~/.tool-versions

function uninstall-if-not() {
	if asdf plugin list | grep "$1" -q; then
		asdf uninstall "$1"
		asdf plugin remove "$1"
		echo "✅ $1 has been uninstalled successfully!"
	fi
	return 0
}

# @param {string} - asdfでのパッケージ名
# @return {0}
function uninstall() {
	local plugins="$1"
	if [[ -z "$plugins" ]]; then
		plugins="$(
			cat ${TOOL_VERSIONS} | awk '{ print $1 }'
		)"
	fi

	xargs -I {} sh -c "uninstall-if-not {}" <<<"$plugins"

	return 0
}

export -f uninstall-if-not
uninstall "$1"
