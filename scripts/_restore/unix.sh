#!/usr/bin/env bash

set -eu -o pipefail

RESTORE_BASE_DIR=$(cd "$(dirname "${0}")"; pwd)
readonly RESTORE_BASE_DIR

function main() {
  local -r DESTINATION_BASE_DIR=~
  local -r BACKUP_DIR_NAME='backup_dotfiles'

  "${RESTORE_BASE_DIR}/main.sh" "${DESTINATION_BASE_DIR}/${BACKUP_DIR_NAME}" "${DESTINATION_BASE_DIR}" --debug
}

main
