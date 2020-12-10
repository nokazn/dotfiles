#!/bin/bash

set nounset

BASE_DIR="$(dirname ${0})/.."
DESTINATION_DIR=~/
BACKUP_DIR=~/dotfiles_backup
counter=0

# 同名のファイルが既に存在すればバックアップする
function backup() {
  if [[ -e $1 ]]; then
    cp "$1" "${BACKUP_DIR}/$(basename ${1})"
  fi
}

function increment_file_counter() {
  counter=$((counter+1))
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
      gitconfig="${DESTINATION_DIR}/.gitconfig"
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

echo "Successfully ${counter} dotfiles are initialized!"
