#!/bin/bash

set nounset
set errexit

readonly BASE_DIR="$(dirname $0)/.."
readonly DESTINATION_BASE_DIR=~
readonly BACKUP_BASE_DIR=~/backup_dotfiles
file_counter=0

# standard error output
# @param {string}
# @return {void}
function decho() {
  echo "$1" 1>&2
}

# @param {string} - full path of destination
# @return {"y" | "n"}
function show_overprompt_for_overwrite() {
  # TODO
  read -rp "warning: $1 already exists. Do you really want to overwrite? (Y/n) " response  </dev/tty
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "y"
  else
    decho "🙈 ignored: $1"
    echo "n"
  fi
  return 0
}

# @param {stirng} - full path of destination
# @return {void}
function backup() {
  local backup_file="${BACKUP_BASE_DIR}${1##${DESTINATION_BASE_DIR}}"
  local backup_dir="$(dirname ${backup_file})"

# 同名のファイルが存在し、バックアップがなければ実行
  if [[ -f $1 ]] && [[ !(-e ${backup_file}) ]]; then
    # バックアップ用のディレクトリがなければ作成
    [[ !(-d ${backup_dir}) ]] && mkdir -p "${backup_dir}"
    cp --verbose $1 "${backup_file}" | sed --regexp-extended --expression "s/(^.*$)/✔ backuped: \1/"
  fi
  return 0
}

# @param {stirng} - full path of source
# @param {stirng} - full path of destination
# @return {void}
function copy_file() {
  if [[ -f $2 ]]; then
    local response=$(show_overprompt_for_overwrite $2)
    [[ ${response} != "y" ]] && return 0
    backup $2
  fi
  cp --verbose $1 $2 | sed --regexp-extended --expression "s/(^.*$)/✅ newly copied: \1/"
  increment_file_counter
  return 0
}

# @param {string} - full path of source
# @param {string} - full path of destination
# @return {void}
function symbolic_link() {
  # すでにシンボリックリンクが存在する場合は無視
  if [[ -L $2 ]]; then
    echo "📌 already linked: $2"
    return 0
  fi

  # destination にファイルが存在しないか、バックアップがある場合
  if [[ !(-e $2) ]]; then
    ln --symbolic --verbose --force $1 $2 | sed --regexp-extended --expression "s/(^.*$)/✅ newly linked: \1/"
    increment_file_counter
  # ファイルが存在する場合
  elif [[ -f $2 ]] && [[ -f $1 ]]; then
    local response=$(show_overprompt_for_overwrite $2)
    if [[ ${response} == "y" ]]; then
      backup $2
      ln --symbolic --verbose --force $1 $2 | sed --regexp-extended --expression "s/(^.*$)/✅ newly linked: \1/"
      increment_file_counter
    fi
  # ディレクトリが存在する場合再帰的に呼び出す
  elif [[ -d $1 ]] && [[ -d $2 ]]; then
    # file は full path
    while read -d ":" file; do
      symbolic_link ${file} $2/$(basename ${file})
    # Process Substitution (標準出力を仮のファイルに出力させる感じ)
    done < <(find $1/ -mindepth 1 -maxdepth 1 -printf "%p:")
  else
    echo "❌ An error occuered when linking $1 to $2"
    return 1
  fi

  return 0
}

# @param - none
# @return {void}
function increment_file_counter() {
  if [[ $? -eq 0 ]]; then
    file_counter=$((file_counter+1))
  fi
  return 0
}

# @return {void}
function main() {
  # .gitconfig 用の email の入力を受け付ける
  read -rp "Please enter your email for .gitconfig file: " email
  cd $BASE_DIR

  # dot で始まる2文字以上のファイル
  for file in $(ls -a . | grep --extended-regexp "^\.\w{2,}"); do
    # フルパスで表示させないと ln できない
    local current="${PWD}/${file}"
    case ${file} in
      ".git" | ".gitignore" )
        continue
        ;;

      ".gitconfig.template" )
        gitconfig="${DESTINATION_BASE_DIR}/.gitconfig"
        copy_file "${current}" "${gitconfig}"
        # .gitconfig の email の箇所を置換
        sed --in-place --expression "2 s/email.*/email = ${email}/" "${gitconfig}"
        ;;

      *)
        destination="${DESTINATION_BASE_DIR}/${file}"
        symbolic_link "${current}" "${destination}"
        ;;
    esac
  done

  if [[ $? -eq 0 ]] && [[ $file_counter -gt 0 ]]; then
    echo "Successfully ${file_counter} dotfiles are initialized!"
  fi
  return 0
}

main
exit 0
