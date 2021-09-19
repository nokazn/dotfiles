#!/usr/bin/env bash

set -eu -o pipefail

# @param ユーザーディレクトリからの相対パス
function backup_non_symlink_file() {
  if [[ ! -e ~/"$1" ]]; then
    return 0
  fi
  local -r file_path=$(find ~/"$1" -maxdepth 0)
  # シンボリックリンクでないファイルが存在している場合はバックアップ
  if [[ ! -L "${file_path}" ]]; then
    if [[ ! -e ${file_path}.bk ]]; then
      mv --verbose "${file_path}" "${file_path}.bk" | sed "s/^/✅ /"
    else
      echo "❌ ${file_path}.bk already exists."
      return 1
    fi
  fi
  return 0
}

# @param ユーザーディレクトリからの相対パスの一覧
function backup_files() {
  xargs -n 1 < "$1" \
    | xargs -I {} bash -c "backup_non_symlink_file {}"
}

# xargs 内で使用できるように export する
export -f backup_non_symlink_file
backup_files "$*"
