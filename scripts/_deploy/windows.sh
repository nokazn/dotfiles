#!/usr/bin/env bash

set -eu -o pipefail

ROOT_DIR=$(cd "$(dirname "${0}")/../../"; pwd)
readonly ROOT_DIR

function main() {
  # プロセス置換して、一度 Windows 内のディレクトリに移動して %USERPROFILE% を出力する
  local -r DESTINATION_BASE_DIR="$(
    tr -d "\r" < <(
      cd /mnt/c; wslpath -u "$(
        /mnt/c/Windows/system32/cmd.exe /c "echo %USERPROFILE%"
      )"
    )
  )"
  local -r BACKUP_DIR_NAME='dotfiles.bk'

  "${ROOT_DIR}/scripts/_deploy/main.sh" "${ROOT_DIR}"/windows "${DESTINATION_BASE_DIR}" "${DESTINATION_BASE_DIR}/${BACKUP_DIR_NAME}" --debug
  sudo cp "${ROOT_DIR}/wsl/etc/wsl.conf" /etc/wsl.conf
}

main
