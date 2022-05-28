#!/usr/bin/env bash

set -eu -o pipefail

ROOT_DIR=$(cd "$(dirname "${0}")/../../"; pwd)
readonly ROOT_DIR

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
  local -r BACKUP_DIR_NAME='dotfiles.bk'
  "${ROOT_DIR}/scripts/_deploy/main.sh" \
    "${ROOT_DIR}"/windows "${destination_base_dir}" \
    "${destination_base_dir}/${BACKUP_DIR_NAME}"

  sudo cp --verbose "${ROOT_DIR}/wsl/etc/wsl.conf" /etc/wsl.conf
}

main
