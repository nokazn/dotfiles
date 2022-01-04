#!/usr/bin/env bash

set -eu -o pipefail

RESTORE_BASE_DIR=$(cd "$(dirname "${0}")"; pwd)
readonly RESTORE_BASE_DIR

function main() {
  # プロセス置換して、一度 Windows 内のディレクトリに移動して %USERPROFILE% を出力する
  local -r DESTINATION_BASE_DIR="$(
    tr -d "\r" < <(
      cd /mnt/c; wslpath -u "$(
        /mnt/c/Windows/system32/cmd.exe /c "echo %USERPROFILE%"
      )"
    )
  )"
  local -r BACKUP_DIR_NAME='backup_dotfiles'

  "${RESTORE_BASE_DIR}/main.sh" "${DESTINATION_BASE_DIR}/${BACKUP_DIR_NAME}" "${DESTINATION_BASE_DIR}" --debug
}

main
