#!/usr/bin/env bash

set -eu -o pipefail

DEBUG=$([[ $# -gt 0 ]] && [[ "${*:4}" =~ --debug ]] && echo 0 || echo 1)
readonly DEBUG
file_counter=0

# utils ----------------------------------------------------------------------------------------------------

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
  ls "$1" --almost-all --ignore ".*\.swp"
  return 0
}

# @param {string} - directory path
# @return {void}
function ls_dotfiles() {
  # dot で始まる2文字以上のファイル or AppData 内のファイル
  ls_all "$1" | grep --extended-regexp -e "^\.[[:alnum:]]{2,}" -e "AppData"
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
  if [[ ! -e $1 ]]; then
    decho "❌ invalid destination file path: " "$1"
    echo "n"
    return 1
  fi

  # TODO
  read -rp "warning: $1 already exists. Do you really want to backup and overwrite? (Y/n) " response  </dev/tty
  if [[ ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "y"
  else
    decho "⏩ skipped: $1"
    echo "n"
  fi
  return 0
}

# @param - {string} - status code
# @return {void}
function increment_file_counter() {
  if [[ $1 -eq 0 ]]; then
    file_counter=$((file_counter+1))
  fi
  return 0
}

# @param {string} - path
# @return {void}
function check_absolute_path() {
  # "/" からはじまるか
  if [[ -z $(sed -E -n -e "/^\//p" <<< "$1") ]]; then
    echo "❌ invalid absolute path: $1"
    exit 1
  fi
}

# core ----------------------------------------------------------------------------------------------------

# @param {stirng} - source for back-up file path
# @param {stirng} - destination for back-up file path
# @return {void}
function make_backup() {
  # $2 + $1 から先頭のバックアップ用のディレクトリの親の部分を削除したもの
  local -r backup_file="$2/${1##"$(dirname "$2")/"}"
  local -r backup_dir="$(dirname "${backup_file}")"

# 同名のファイルが存在し、バックアップがなければ実行
  if [[ -f $1 ]] && [[ ! -e ${backup_file} ]]; then
    if [[ ${DEBUG} -eq 0 ]]; then
      echo "[debug] ✔ backed up: '$1' -> '${backup_file}'"
      return 0;
    fi
    # バックアップ用のディレクトリがなければ作成
    [[ ! -d ${backup_dir} ]] && mkdir -p "${backup_dir}"
    cp --verbose "$1" "${backup_file}" | prepend_message "✔ backed up: "
  fi
  return 0
}

# @param {string} - source file path (always exists)
# @param {string} - destination file path
# @return {void}
function newly_link() {
  check_absolute_path "$1"
  if [[ ${DEBUG} -eq 0 ]]; then
    echo "[debug] ✅ newly linked: '$2' -> '$1'"
    return 0;
  fi

  local -r WINDOWS_PATH="/mnt/c"
  if [[ $2 =~ ${WINDOWS_PATH} ]]; then
    cp --verbose -r "$1" "$2" | prepend_message "✅ newly copied:"
  else
    ln --symbolic --verbose --force "$1" "$2" | prepend_message "✅ newly linked:"
  fi

  increment_file_counter $?
  return 0
}

# @param {string} - source file path
# @param {string} - destination file path
# @param {stirng} - destination directory for back-up path
# @return {void}
function make_symbolic_link() {
  # すでにシンボリックリンクが存在する場合は無視
  if [[ -L $2 ]]; then
    echo "📌 already linked: $2"
    return 0
  elif [[ ! -e $1 ]]; then
    echo "❌ invalid source file path: " "$1"
    return 0
  fi

  if [[ ! -e $2 ]]; then
    newly_link "$1" "$2"
  elif [[ -f $2 ]] && [[ -f $1 ]]; then
    # ファイルでバックアップがある場合
    local -r response=$(show_prompt_for_overwrite "$2")
    if [[ ${response} == "y" ]]; then
      make_backup "$2" "$3"
      newly_link "$1" "$2"
    fi
  elif [[ -d $1 ]] && [[ -d $2 ]]; then
    # ディレクトリが存在する場合再帰的に呼び出す
    for file in $(ls_all "$1/"); do
      make_symbolic_link "$1/${file}" "$2/${file}" "$3"
    done
  else
    echo "❌ An error occuered when linking $1 to $2"
    return 1
  fi

  return 0
}

# @param {string} - source directory path for dotfiles
# @param {string} - destination directory path
# @param {stirng} - destination directory for back-up path
# @param {stirng[]} - target files to deploy
# @return {void}
function deploy() {
  if [[ ! -d $1 ]]; then
    echo "⚠ source directory '$1' doesn't exist."
    return 0;
  fi

  local -r rest_params="${*:4}"
  if [[ -n "${rest_params}" ]]; then
    # ファイル名が指定された場合は、それらをコピーする
    files="${rest_params}"
  else
    # ファイル名が指定されなかった場合は、該当ディレクトリ内のすべてのファイルをコピーする
    files=$(ls_dotfiles "$1")
  fi

  for file in ${files}; do
    case ${file} in
      ".git" | ".gitignore" | ".github")
        continue
        ;;

      *)
        make_symbolic_link "$1/${file}" "$2/${file}" "$3"
        ;;
    esac
  done

  return 0
}

# main ----------------------------------------------------------------------------------------------------

# @param {string} - source directory path for dotfiles
# @param {string} - destination directory path
# @param {stirng} - destination directory for back-up path
# @return {void}
function main() {
  if [[ ${DEBUG} -eq 0 ]]; then
    local -r rest_params="${*:4}"
    deploy "$1" "$2" "$3" "${rest_params/--debug/}"
  else
    read -rp "Do you really want to deploy dotfiles? (Y/n) " response
    if [[ ! ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
      return 0;
    fi
    deploy "$@"
  fi


  if [[ $file_counter -gt 0 ]]; then
    echo "Successfully ${file_counter} dotfiles are initialized!"
  fi
}

main "$@"
exit 0
