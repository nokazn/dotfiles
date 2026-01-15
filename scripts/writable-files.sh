#!/usr/bin/env bash

set -eu -o pipefail

function _chmod() {
	if [[ $(uname) == "Darwin" ]]; then
		sudo /bin/chmod -vh "$@"
	else
		sudo chmod --verbose "$@"
	fi
}

# @param ユーザーディレクトリからの絶対/相対パス
function _add_writable_permission() {
	if [[ -z "$1" ]]; then
		return 0
	fi

	local message
	if [[ "$1" == /* ]] && [[ -L "$1" ]]; then
		message=$(_chmod +w "$1")
	elif [[ -L ~/"$1" ]]; then
		if [[ "$1" =~ \.ssh/ ]]; then
			message=$(_chmod 644 ~/"$1")
			message+=$(_chmod 644 "$(readlink -f ~/"$1")")
		else
			message=$(_chmod +w ~/"$1")
			message+=$(_chmod a+w "$(readlink -f ~/"$1")")
		fi
	fi

	if [[ -n ${message} ]] && [[ ! ${message} =~ "retained as" ]]; then
		sed -E -e 's/^/✅ /' <<<"${message}"
	fi

	return 0
}

# @param ユーザーディレクトリからの絶対/相対パスの一覧
function main() {
	# `# `で始まるファイルも`# `を削除した上で引数として渡し、書き込み権限を追加する
	sed -E -e 's/^#[[:space:]]+//' <"$1" |
		xargs -I {} bash -c "_add_writable_permission '{}'"
}

# サブコマンド内で使用できるように export する
export -f _chmod
# xargs内で使用できるように export する
export -f _add_writable_permission
main "$@"
