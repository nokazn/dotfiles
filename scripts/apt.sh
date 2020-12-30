#!/bin/bash

# @param none
# @return {void}
function run_apt() {
  echo "installing apt packages...\n"
  sudo apt install -y heroku \
    vim-gtk \
    xsel \
    postgres-12
  sudo apt update -y && sudo apt upgrade -y
  return 0
}

run_apt
exit 0
