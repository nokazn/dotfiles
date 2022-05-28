#!/usr/bin/env bash

set -eu -o pipefail

RESTORE_BASE_DIR=$(cd "$(dirname "${0}")"; pwd)
readonly RESTORE_BASE_DIR

# cmd.exe 内でコマンドを実行してパスを取得し、UNIX のパスの形式に変換する
function get-path-in-cmd() {
  cd /mnt/c; wslpath -u "$(
    /mnt/c/Windows/system32/cmd.exe /c "$@"
  )"
}

function main() {
  # プロセス置換して、一度 Windows 内のディレクトリに移動して %USERPROFILE% を出力する
  local -r destination_base_dir="$(
    tr -d "\r" < <(get-path-in-cmd "echo %USERPROFILE%")
  )"
  local -r BACKUP_DIR_NAME='backup_dotfiles'

  "${RESTORE_BASE_DIR}/main.sh" \
    "${destination_base_dir}/${BACKUP_DIR_NAME}" \
    "${destination_base_dir}"
}

main
