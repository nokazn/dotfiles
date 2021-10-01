#!/usr/bin/env bash

set -eu -o pipefail

ROOT_DIR=$(cd "$(dirname "${0}")/../../"; pwd)
readonly ROOT_DIR

function main() {
  # 一度 Windows 内のディレクトリに移動して %USERPROFILE% を出力する
  local -r DESTINATION_BASE_DIR="$(cd /mnt/c; wslpath -u "$(/mnt/c/Windows/system32/cmd.exe /c "echo %USERPROFILE%" | tr -d "\r")")"
  local -r BACKUP_DIR_NAME='backup_dotfiles'

  "${ROOT_DIR}/scripts/_deploy/main.sh" "${ROOT_DIR}"/windows "${DESTINATION_BASE_DIR}" "${DESTINATION_BASE_DIR}/${BACKUP_DIR_NAME}" --debug
}

main
