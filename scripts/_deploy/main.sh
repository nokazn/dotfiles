#!/usr/bin/env bash

set -eu -o pipefail

DEBUG=$([[ $# -gt 0 ]] && test "$1" = --debug; echo $?)
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
  # dot で始まる2文字以上のファイル
  ls_all "$1" | grep --extended-regexp "^\.[[:alnum:]]{2,}"
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
    decho "🙈 ignored: $1"
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

# email のフィールドが所定の形式になっているかチェックする
# @param {string} - file path
# @param {string} - email
# @return {void}
function check_email_attribute() {
  # dotfiles 内の .gitconfig で該当行が email = ${email} の形式になっているかチェック
  local -r email_line=$(
    grep < "$1" --line-number "email\s*=\s*" | grep "$2"
  )
  if [[ -z ${email_line} ]]; then
    local -r error_line_number=$(cut -f 1 -d ":" <<< "${email_line}")
    # 1行目にエラーの行番号が取得できればを表示し、2行目にエラーのあった行を表示
    echo -n "❌ An error occured when inserting email to $1"
    if [[ ${error_line_number} ]]; then
      echo -n "at line ${error_line_number}"
    fi
    echo -e ": \n  ${email_line}"
    return 1
  fi
  return 0
}

# シンボリックリンクを貼る前に実行させる
# @param {stirng} - source file path
# @return {void}
function insert_email_to_gitconfig() {
  # .gitconfig 用の email の入力を tty から受け付ける
  read -rp "Please enter your email for .gitconfig file: " email </dev/tty

  if [[ ${DEBUG} -eq 0 ]]; then
    echo "[debug] 📧 '${email}' has been inserted to email attribute in '$1'."
    return 0;
  fi

  # .gitconfig の email の箇所を置換
  sed --in-place -e "2 s/email.*/email = ${email}/" "$1"

  # dotfiles 内の .gitconfig で該当行が email = ${email} の形式になっているかチェック
  check_email_attribute "$1" "${email}"

  echo "📧 '${email}' has been inserted to email attribute in '$1'."
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
    # TODO: ショートカット作成事態はできるが、.lnk ファイルとして扱われ別物になる
    # local -r source_win="$(wslpath -w $1)"
    # local -r destination_win="$(wslpath -w $2).lnk"
    # powershell.exe -c "\$wsh = New-Object -ComObject WScript.Shell; \$sc = \$wsh.CreateShortCut(\"${destination_win}\"); \$sc.TargetPath = \"${source_win}\"; \$sc.Save();"
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
    exit 1
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
# @return {void}
function deploy() {
  if [[ ! -d $1 ]]; then
    echo "⚠ source directory '$1' doesn't exist."
    return 0;
  fi

  for file in $(ls_dotfiles "$1"); do
    case ${file} in
      ".git" | ".gitignore" | ".github")
        continue
        ;;

      ".gitconfig" )
        [[ ! -L "$2/${file}" ]] && insert_email_to_gitconfig "$1/${file}"
        make_symbolic_link "$1/${file}" "$2/${file}" "$3"
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
  if [[ ! ${DEBUG} -eq 0 ]]; then
    read -rp "Do you really want to deploy dotfiles? (Y/n) " response
    if [[ ! ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
      return 0;
    fi
  fi

  deploy "$1" "$2" "$3"
  if [[ $file_counter -gt 0 ]]; then
    echo "Successfully ${file_counter} dotfiles are initialized!"
  fi
}

main "$1" "$2" "$3"
exit 0
