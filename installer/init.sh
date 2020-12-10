#!/bin/bash

set nounset

BASE_DIR="$(dirname ${0})/.."
DESTINATION_DIR=~/
BACKUP_DIR=~/dotfiles_backup/
# バックアップ用のディレクトリが存在するか
has_backup=$(test -e $BACKUP_DIR; echo $?)
file_counter=0

# 同名のファイルが既に存在し、バックアップ用のディレクトリがなければバックアップする
function backup() {
  if [[ -e $1 ]]; then
    if [[ $has_backup -gt 0 ]]; then
      [[ $file_counter -eq 0 ]] && mkdir -p $BACKUP_DIR
      cp "$1" "${BACKUP_DIR}$(basename ${1})"
    fi
  fi
}

function increment_file_counter() {
  file_counter=$((file_counter+1))
}

# .gitconfig 用の email の入力を受け付ける
echo -n "Please enter your email for .gitconfig file: "
read email
cd $BASE_DIR

# dot で始まる2文字以上のファイル
for f in .??*; do
  current="${PWD}/${f}"
  case $f in
    ".git" | ".gitignore" )
      continue;;

    ".gitconfig.template" )
      gitconfig="${DESTINATION_DIR}.gitconfig"
      backup $gitconfig
      cp --verbose $current $gitconfig | sed -r -e "s/(^.*$)/✔ copied: \1/"
      # .gitconfig の email の箇所を置換
      sed --in-place -e "2 s/email.*/email = ${email}/" $gitconfig
      increment_file_counter;;

    *)
      backup "${DESTINATION_DIR}/${f}"
      # シンボリックリンクを作成
      ln -snfv $current $DESTINATION_DIR | sed -r -e "s/(^.*$)/✔ linked: \1/"
      increment_file_counter;;
  esac
done

if [[ $? -eq 0 ]]; then
  echo "Successfully ${file_counter} dotfiles are initialized!"
fi
