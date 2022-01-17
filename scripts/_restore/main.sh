#!/usr/bin/env bash

set -eu -o pipefail

DEBUG=$([[ $# -gt 3 ]] && test "$3" = --debug; echo $?)
readonly DEBUG

# @param {string} - directory path
# @return {void}
function ls_all() {
  ls "$1" --almost-all --ignore "*.swp"
  return 0
}

# @param - none
# @return {void}
function prepend_message() {
  sed --regexp-extended -e "s/^/$1 /"
  return 0
}

# core ----------------------------------------------------------------------------------------------------

# @param {string} - file path to remove
# @return {void}
function remove_with_confirmation() {
  if [[ -L $1 ]]; then
    rm "$1"
  else
    # 削除する前に確認
    rm "$1" --interactive
  fi
}

# @param {string} - backed-up file path
# @param {string} - destionation file path
# @return {void}
function restore_file() {
  if [[ ! -e $1 ]]; then
    echo "❌ invalid backed-up source file path."
    exit 1
  fi

  if [[ ! -e $2 ]]; then
    if [[ ${DEBUG} -eq 0 ]]; then
      echo "[debug]✅ restored: $1 -> $2"
      return 0;
    fi
    cp --verbose "$1" "$2" | prepend_message "✅ restored: "
  elif [[ -L $2 ]] || [[ $(basename "$2") == ".gitconfig" ]]; then
    if [[ ${DEBUG} -eq 0 ]]; then
      echo "[debug]✅ deleted & restored: $1 -> $2"
      return 0;
    fi
    # 事前に削除しないと、シンボリックリンクの中身を書き換えるだけでシンボリックリンク自体は消えない
    remove_with_confirmation "$2"
    [[ ! -e $2 ]] && cp --verbose --no-clobber "$1" "$2" |  prepend_message "✅ deleted & restored: "
  elif [[ -d $1 ]] && [[ -d $2 ]]; then
    # ディレクトリが存在する場合再帰的に呼び出す
    for file in $(ls_all "$1/"); do
      restore_file "$1/${file}" "$2/${file}"
    done
  else
    echo "✔ already exists: $2"
  fi

  return 0
}

# @param {string} - backed-up source directory path
# @param {string} - destination directory path
# @return {void}
function restore() {
  if [[ ! -d $1 ]]; then
    echo "⚠ backed-up directory '$1' doesn't exist."
    return 0;
  fi

  for file in $(ls_all "$1"/);do
    restore_file "$1/${file}" "$2/${file}"
  done
  return 0
}

# main ----------------------------------------------------------------------------------------------------

# @param {string} - backed-up source directory path
# @param {string} - destination directory path
# @return {void}
function main() {
  if [[ ! ${DEBUG} -eq 0 ]]; then
    read -rp "Do you really want to restore backups? (Y/n) " response
    if [[ ! ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
      return 0;
    fi
  fi

  restore "$1" "$2"
  return 0
}

main "$1" "$2"
exit 0
