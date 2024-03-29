#!/usr/bin/env bash

set -e -o pipefail

ROOT_DIR=$(
	cd "$(dirname "$0")/../../"
	pwd
)
readonly ROOT_DIR

# @param {string} - sorce file path
function _diff() {
	if command -v delta >/dev/null; then
		delta "$@"
	elif command -v colordiff >/dev/null; then
		colordiff "$@"
	else
		diff "$@"
	fi
}

function usage() {
	cat <<EOF
$(basename "$0") is a tool to deploy files to Windows environment

Usage:
    $(basename "$0") [command] [<options>]

Options:
    <default>         deploy Windows & WSL files
    [files]           deploy Windows files
    wsl               deploy WSL files
    --help, -h        print this
EOF
}

# cmd.exe 内でコマンドを実行してパスを取得し、UNIX のパスの形式に変換する
function get-path-in-cmd() {
	cd /mnt/c
	wslpath -u "$(
		/mnt/c/Windows/system32/cmd.exe /c "$@"
	)"
}

# @param {string[]} - target files to deploy
function deploy_user_files() {
	# プロセス置換して、一度 Windows 内のディレクトリに移動して %USERPROFILE% を出力する
	local -r destination_base_dir="$(
		tr -d "\r" < <(get-path-in-cmd "echo %USERPROFILE%")
	)"
	local -r BACKUP_DIR_NAME='dotfiles.bk'
	"${ROOT_DIR}/scripts/apply/main.sh" \
		"${ROOT_DIR}/windows" \
		"${destination_base_dir}" \
		"${destination_base_dir}/${BACKUP_DIR_NAME}" \
		"$@"
}

function deploy_wsl_files() {
	local -r source="${ROOT_DIR}/wsl/etc/wsl.conf"
	local -r destination=/etc/wsl.conf
	if diff -q "$source" "$destination" >/dev/null; then
		return 0
	fi
	_diff "$destination" "$source" || true
	read -rp "Do you really want to deploy WSL conig files? (Y/n) " response
	if [[ ! ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
		return 0
	fi
	sudo cp --verbose "$source" "$destination" | sed -E -e "s/^/✅ /"
}

function main() {
	case $1 in
	--help | -h)
		usage
		;;

	--debug)
		# 実行するコマンドを出力
		set -x
		deploy_user_files "$@"
		;;

	--wsl)
		deploy_wsl_files
		;;

	"")
		deploy_user_files "$@"
		deploy_wsl_files
		;;

	*)
		deploy_user_files "$@"
		;;
	esac
}

main "$@"
