#!/usr/bin/env bash

set -eu -o pipefail

ROOT_DIR=$(cd "$(dirname "${0}")/../../"; pwd)
readonly ROOT_DIR

function main() {
  local -r DESTINATION_BASE_DIR=~
  local -r BACKUP_DIR_NAME='backup_dotfiles'

  "${ROOT_DIR}/scripts/_deploy/main.sh" \
    "${ROOT_DIR}" \
    "${DESTINATION_BASE_DIR}" \
    "${DESTINATION_BASE_DIR}/${BACKUP_DIR_NAME}"
}

main
