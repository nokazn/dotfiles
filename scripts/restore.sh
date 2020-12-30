#!/bin/bash

set nounset
set errexit

readonly BASE_DIR="$(dirname $0)/.."
readonly DESTINATION_BASE_DIR=~
readonly BACKUP_BASE_DIR=~/backup_dotfiles
file_counter=0

# @param {string} - directory path
# @return {void}
function ls_all() {
  ls $1 -a --ignore "." --ignore ".." --ignore "*.swp"
  return 0
}

# @param {string} - full path of backed-up file
# @param {string} - full path of destionation
# @return {void}
function restore() {
  if [[ -d $1 ]] && [[ -d $2 ]]; then
    for file in $(ls_all "$1/"); do
      restore "$1/${file}" "$2/${file}"
    done
  elif [[ -L $2 ]] || [[ $(basename $2) == ".gitconfig" ]]; then
    # 事前に削除しないと、シンボリックリンクの中身を書き換えるだけでシンボリックリンク自体は消えない
    if [[ -L $2 ]]; then
      rm $2
    else
      # 削除する前に確認
      rm $2 --interactive
      [[ -e $2 ]] && return 0
    fi
    local cp_message=$(cp --verbose --no-clobber $1 $2)
    echo "✅ deleted & restored: " ${cp_message}
  elif [[ ! -e $2 ]]; then
    local cp_message=$(cp --verbose $1 $2)
    echo "✅ restored: " ${cp_message}
  else
    echo "✔ already exists: $2"
  fi
  return 0
}

# @param - none
# @return {void}
function main() {
  cd ${BASE_DIR}

  for file in $(ls_all ${BACKUP_BASE_DIR}/ | grep --extended-regexp "^\.\w{2,}");do
    restore "${BACKUP_BASE_DIR}/${file}" "${DESTINATION_BASE_DIR}/${file}"
  done
  return 0
}

main
exit 0
