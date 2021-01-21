#!/bin/bash

set nounset
set errexit

readonly BASE_DIR=$(cd $(dirname $0)/..; pwd)
readonly DEBUG=$([[ $# -gt 0 ]] && test $1 = --debug; echo $?)
readonly _BACKUP_DIR_NAME="backup_dotfiles"
file_counter=0

readonly DESTINATION_BASE_DIR=~
readonly BACKUP_BASE_DIR=~/${_BACKUP_DIR_NAME}

# 一度 Windows 内のディレクトリに移動して %USERPROFILE% を出力してからもといたディレクトリに戻る
readonly DESTINATION_BASE_DIR_FOR_WINDOWS=$(cd /mnt/c; wslpath -u $(cmd.exe /c "echo %USERPROFILE%" | tr -d "\r"); cd $OLDPWD)
readonly BACKUP_BASE_DIR_FOR_WINDOWS="${DESTINATION_BASE_DIR_FOR_WINDOWS}/${_BACKUP_DIR_NAME}"

# ---------------------------------------- utils ----------------------------------------

# standard error output
# @param {string}
# @return {void}
function decho() {
  echo "$1" 1>&2
  return 0
}

# @param {string} - directory path
# @return {void}
function ls_all() {
  ls $1 --almost-all --ignore "*.swp"
  return 0
}

# @param {string} - directory path
# @return {void}
function ls_dotfiles() {
  # dot で始まる2文字以上のファイル
  ls_all $1 | grep --extended-regexp "^\.[[:alnum:]]{2,}"
  return 0
}

# @param - none
# @return {void}
function prepend_message() {
  sed --regexp-extended -e "s/^/$1 /"
  return 0
}

# @param {string} - destination file path
# @return {"y"|"n"}
function show_prompt_for_overwrite() {
  if [[ ! -f $2 ]]; then
    echo "y"
    return 0
  fi
  # TODO
  read -rp "warning: $1 already exists. Do you really want to backup and overwrite? (Y/n) " response  </dev/tty
  if [[ ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "y"
  else
    decho "🙈 ignored: $1"
    echo "n"
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

# ---------------------------------------- core ----------------------------------------

# @param {stirng} - destination file path
# @return {void}
function backup() {
  # $1 の先頭の "${DESTINATION_BASE_DIR}/" の部分を削除している
  local backup_file="${BACKUP_BASE_DIR}/${1##"${DESTINATION_BASE_DIR}/"}"
  local backup_dir="$(dirname ${backup_file})"

# 同名のファイルが存在し、バックアップがなければ実行
  if [[ -f $1 ]] && [[ ! -e ${backup_file} ]]; then
    # バックアップ用のディレクトリがなければ作成
    [[ ! -d ${backup_dir} ]] && mkdir -p "${backup_dir}"
    cp --verbose $1 "${backup_file}" | prepend_message "✔ backuped: "
  fi
  return 0
}

# @param {stirng} - source file path
# @param {stirng} - destination file path
# @return {void}
function copy_gitconfig() {
  if [[ -f $2 ]]; then
    local response=$(show_prompt_for_overwrite $2)
    [[ ${response} != "y" ]] && return 0
    backup $2
  fi

  # .gitconfig 用の email の入力を tty から受け付ける
  read -rp "Please enter your email for .gitconfig file: " email </dev/tty
  local success_message=$(cp --verbose $1 $2 | prepend_message "✅ newly copied: ")
  # .gitconfig の email の箇所を置換
  sed --in-place -e "2 s/email.*/email = ${email}/" $2

  local email_line=$(cat $2 | grep --extended-regexp --line-number "email\s?=\s?${email}$")
  # email = <user's email> の形式になっているかチェック
  if [[ -z ${email_line} ]]; then
    local error_line_number=$(echo ${email_line} | cut -f 1 -d ":")
    echo -n "❌ An error occured when inserting email to $2"
    if [[ error_line_number ]]; then
      echo -n "at line ${error_line_number}"
    fi
    echo -e ": \n  ${email_line}"
    return 1
  fi

  echo $success_message
  increment_file_counter
  return 0
}

# @param {string} - source file path
# @param {string} - destination file path
# @return {void}
function make_symbolic_link() {
  # すでにシンボリックリンクが存在する場合は無視
  if [[ -L $2 ]]; then
    echo "📌 already linked: $2"
    return 0
  elif [[ ! -e $1 ]]; then
    echo "❌ invalid source file path."
    exit 1
  fi

  # @param {string} - source file path (always exists)
  # @param {string} - destination file path
  # @return {void}
  function newly_link() {
    ln --symbolic --verbose --force $1 $2 | prepend_message "✅ newly linked: "
    increment_file_counter
  }

  if [[ ! -e $2 ]]; then
    newly_link $1 $2
  elif [[ -f $2 ]] && [[ -f $1 ]]; then
    # ファイルでバックアップがある場合
    local response=$(show_prompt_for_overwrite $2)
    if [[ ${response} == "y" ]]; then
      backup $2
      newly_link $1 $2
    fi
  elif [[ -d $1 ]] && [[ -d $2 ]]; then
    # ディレクトリが存在する場合再帰的に呼び出す
    for file in $(ls_all "$1/"); do
      make_symbolic_link "$1/${file}" "$2/${file}"
    done
  else
    echo "❌ An error occuered when linking $1 to $2"
    return 1
  fi

  return 0
}

# @param {string} - source directory path for dotfiles
# @param {string} - destination directory path
# @return {void}
function deploy() {
  if [[ ! -d $1 ]]; then
    echo "⚠ source directory '$1' doesn't exist."
    return 0;
  fi

  for file in $(ls_dotfiles $1); do
    case ${file} in
      ".git" | ".gitignore" )
        continue
        ;;

      ".gitconfig" )
        copy_gitconfig "$1/${file}" "$2/${file}"
        ;;

      *)
        make_symbolic_link "$1/${file}" "$2/${file}"
        ;;
    esac
  done

  return 0
}

# ---------------------------------------- main ----------------------------------------

# @param - none
# @return {void}
function main() {
  read -rp "Do you really want to deploy dotfiles? (Y/n) " response
  if [[ ! ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0;
  fi

  deploy . ${DESTINATION_BASE_DIR}
  deploy ./windows ${DESTINATION_BASE_DIR_FOR_WINDOWS}
}

main
exit 0
