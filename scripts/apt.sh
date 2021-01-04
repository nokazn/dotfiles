#!/bin/bash

set nounset
set errexit

# @param none
# @return {void}
function run_apt() {
  if type apt >/dev/null 2>&1; then
    echo "❌ apt doesn't exist."
    exit 1
  fi

  echo "installing apt packages ..."
  sudo apt install -y heroku \
    vim-gtk \
    xsel \
    postgres-12
  sudo apt update -y && sudo apt upgrade -y

  echo "✅ apt packages have been installed successfully!"
  return 0
}

run_apt
exit 0
