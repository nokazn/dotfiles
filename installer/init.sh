#!/bin/bash

set nounset

BASE_DIR="$(dirname $0)/.."
DESTINATION=~/
counter=0

# TODO 同名のファイルが既に存在すればバックアップする
# function backup() {}

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
      gitconfig="${DESTINATION}/.gitconfig"
      cp $current $gitconfig
      # .gitconfig の email の箇所を置換
      sed --in-place -e "2 s/email.*/email = $email/" $gitconfig
      increment_file_counter;;
    *)
      # シンボリックリンクを作成
      ln -snfv $current $DESTINATION
      increment_file_counter;;
  esac
done

echo "Successfully ${counter} dotfiles are initialized!"
