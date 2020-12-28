#!/bin/bash

set nounset

BASE_DIR="$(dirname ${0})/.."
DESTINATION_BASE_DIR=~
BACKUP_BASE_DIR=~/backup_dotfiles
file_counter=0

# @param {string} - destination path
# @return {string}
function show_overprompt_for_overwrite() {
  # TODO
  read -rp "warning: ${1} already exists. Do you really want to overwrite? (Y/n) " response  </dev/tty
  echo ${response}
}

# @param {stirng} - destination file path
function backup() {
  backup_file="${BACKUP_BASE_DIR}${1##${DESTINATION_BASE_DIR}}"
  backup_dir="$(dirname ${backup_file})"

# 同名のファイルが存在し、バックアップがなければ実行
  if [[ -f ${1} ]] && [[ !(-e ${backup_file}) ]]; then
    # バックアップ用のディレクトリがなければ作成
    [[ !(-d ${backup_dir}) ]] && mkdir -p "${backup_dir}"
    cp --verbose "${1}" "${backup_file}" | sed --regexp-extended --expression "s/(^.*$)/✔ backuped: \1/"
  fi
}

# @param {stirng} - source  file path
# @param {stirng} - destination file path
function copy_file() {
  if [[ -f ${2} ]]; then
    # read -rp "warning: ${2} already exists. Do you really want to overwrite? (Y/n) " response
    response=$(show_overprompt_for_overwrite $1)
    if [[ !(${response} =~ ^([yY][eE][sS]|[yY])$) ]]; then
      return
    fi
    backup "${2}"
  fi
  cp --verbose "${1}" "${2}" | sed --regexp-extended --expression "s/(^.*$)/✅ newly copied: \1/"
  increment_file_counter
}

# @param {string} - source file path
# @param {string} - destination file path
function symbolic_link() {
  # すでにシンボリックリンクが存在する場合は無視
  if [[ -L ${2} ]]; then
    echo "📌 already linked: ${2}"
    return
  fi

  # destination にファイルが存在しないか、バックアップがある場合
  if [[ !(-e ${2}) ]]; then
    ln --symbolic --verbose --force "${1}" "${2}" | sed --regexp-extended --expression "s/(^.*$)/✅ newly linked: \1/"
    increment_file_counter
  # ファイルが存在する場合
  elif [[ -f ${2} ]] && [[ -f ${1} ]]; then
    response=$(show_overprompt_for_overwrite ${2})
    if [[ ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
      backup "${2}"
      ln --symbolic --verbose --force "${1}" "${2}" | sed --regexp-extended --expression "s/(^.*$)/✅ newly linked: \1/"
      increment_file_counter
    fi
  # ディレクトリが存在する場合再帰的に呼び出す
  elif [[ -d ${1} ]] && [[ -d ${2} ]]; then
    while read -d ":" f; do
      symbolic_link ${f} ${2}/$(basename ${f})
    # Process Substitution (標準出力を仮のファイルに出力させる感じ)
    done < <(find ${1}/ -mindepth 1 -maxdepth 1 -printf "%p:")
    return
  fi
}

function increment_file_counter() {
  if [[ $? -eq 0 ]]; then
    file_counter=$((file_counter+1))
  fi
}

function main() {
  # .gitconfig 用の email の入力を受け付ける
  read -rp "Please enter your email for .gitconfig file: " email
  cd $BASE_DIR

  # dot で始まる2文字以上のファイル
  for f in .??*; do
    # フルパスで表示させないと ln できない
    current="${PWD}/${f}"
    case $f in
      ".git" | ".gitignore" )
        continue;;

      ".gitconfig.template" )
        gitconfig="${DESTINATION_BASE_DIR}/.gitconfig"
        copy_file "${current}" "${gitconfig}"
        # .gitconfig の email の箇所を置換
        sed --in-place --expression "2 s/email.*/email = ${email}/" "${gitconfig}";;

      *)
        destination=${DESTINATION_BASE_DIR}/${f}
        symbolic_link ${current} ${destination};;
    esac
  done

  if [[ $? -eq 0 ]] && [[ $file_counter -gt 0 ]]; then
    echo "Successfully ${file_counter} dotfiles are initialized!"
  fi
}

main
