#!/usr/bin/env bash

set -eu -o pipefail

function backup_non_symlink() {
  if [[ ! -e ~/"$1" ]]; then
    return 0
  fi
  local -r file_path=$(find ~/"$1" -maxdepth 0)
  # シンボリックリンクでないファイルが存在している場合はバックアップ
  if [[ ! -L "${file_path}" ]]; then
    mv --verbose "${file_path}" "${file_path}.bk" | sed "s/^/✅ /"
  fi
  return 0
}

function backup_files() {
  xargs -n 1 < "$1" \
    | xargs -I {} bash -c "backup_non_symlink {}"
}

# xargs 内で使用できるように export する
export -f backup_non_symlink
backup_files "$*"
