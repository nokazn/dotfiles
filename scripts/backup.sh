#!/usr/bin/env bash

set -eu -o pipefail

# @param ユーザーディレクトリからの絶対/相対パス
function _backup_non_symlink_file() {
	if [[ -z "$1" ]]; then
		return 0
	fi
	if [[ "$1" == /* ]]; then
		if [[ ! -e "$1" ]]; then
			return 0
		fi
		# シンボリックリンクでない絶対パスのファイルが存在している場合はバックアップ
		if [[ ! -L "$1" ]]; then
			sudo mv -v "$1" "$1-$(date +"%Y-%m-%d-%I-%M-%S").bk" | sed "s/^/✅ /"
		fi
	else
		if [[ ! -e ~/"$1" ]]; then
			return 0
		fi
		local -r file_path=$(find ~/"$1" -maxdepth 0)
		# シンボリックリンクでない相対パスのファイルが存在している場合はバックアップ
		if [[ ! -L "${file_path}" ]]; then
			mv -v "${file_path}" "${file_path}-$(date +"%Y-%m-%d-%I-%M-%S").bk" | sed "s/^/✅ /"
		fi
	fi
	return 0
}

# @param ユーザーディレクトリからの絶対/相対パスの一覧
function backup() {
	# `# `で始まるファイルも`# `を削除した上で引数として渡し、バックアップする
	sed -E -e 's/^#[[:space:]]+//' <"$1" |
		xargs -I {} bash -c "_backup_non_symlink_file '{}'"
}

# xargs 内で使用できるように export する
export -f _backup_non_symlink_file
backup "$*"
