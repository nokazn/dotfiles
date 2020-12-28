#!/bin/bash

set nounset

BASE_DIR="$(dirname ${0})/.."
DESTINATION_DIR=~
BACKUP_DIR=~/backup_dotfiles2020
file_counter=0

# @param {stirng} - destination file naem
function backup_file() {
  # シンボリックリンクの場合は上書きしてかまわないので無視
  if [[ -L ${1} ]]; then
    return
  fi

  file_name=$(basename ${1})
# 同名のファイルが存在し、バックアップがなければ実行
  if [[ -e ${1} ]]; then
    if [[ !(-e "${BACKUP_DIR}/${file_name}") ]]; then
      # バックアップ用のディレクトリがなければ作成
      [[ !(-d ${BACKUP_DIR}) ]] && mkdir -p "${BACKUP_DIR}"
      cp --verbose "${1}" "${BACKUP_DIR}/${file_name}"
    fi
  fi
}

# @param {stirng} - destination file naem
function copy_file() {
  # ログ出力の前にメッセージを表示
  read -rp "warning: ${2} already exists. Do you really want to overwrite? (Y/n) " overwrite
  if [[ $overwrite =~ ^([yY][eE][sS]|[yY])$ ]]; then
    cp --verbose "${1}" "${2}" | sed --regexp-extended --expression "s/(^.*$)/✅ newly copied: \1/"
    increment_file_counter
  fi
}

# @param {string} - source
# @param {string} - destination
function link_file() {
  # すでにシンボリックリンクが存在する場合は無視
  if [[ -L ${2} ]]; then
    echo "📌 already linked: ${2}"
    return
  fi

  # destination にファイルが存在しないか、バックアップがある場合
  if [[ !(-e ${2}) ]] || [[ -e "${BACKUP_DIR}/$(basename ${2})" ]]; then
    ln --symbolic --verbose --force "${1}" "${2}" | sed --regexp-extended --expression "s/(^.*$)/✅ newly linked: \1/"
    increment_file_counter
  # ファイルが存在する場合
  elif [[ -f ${2} ]] && [[ -f ${1} ]]; then
    # 上書きするか尋ねる
    read -rp "warning: ${2} already exists. Do you really want to overwrite? (Y/n) " overwrite
    if [[ $overwrite =~ ^([yY][eE][sS]|[yY])$ ]]; then
      ln --symbolic --verbose --force "${1}" "${2}" | sed --regexp-extended --expression "s/(^.*$)/✅ newly linked: \1/"
      increment_file_counter
    fi
  # ディレクトリが存在する場合再帰的に呼び出す
  elif [[ -d ${1} ]] && [[ -d ${2} ]]; then
    # TODO: cp: -r not specified; omitting directory '/home/nokazn/.vscode-server'
    while read -d ":" f; do
    echo $2 $f
      link_file ${f} ${2}/$(basename ${f})
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
        gitconfig="${DESTINATION_DIR}/.gitconfig"
        backup_file "${gitconfig}"
        copy_file "${current}" "${gitconfig}"
        # .gitconfig の email の箇所を置換
        sed --in-place --expression "2 s/email.*/email = ${email}/" "${gitconfig}";;

      *)
        destination=${DESTINATION_DIR}/${f}
        backup_file ${destination}
        link_file ${current} ${destination};;
    esac
  done

  if [[ $? -eq 0 ]]; then
    echo "Successfully ${file_counter} dotfiles are initialized!"
  fi
}

main
