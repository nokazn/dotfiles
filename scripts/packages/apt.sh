#!/usr/bin/env bash

set -eu -o pipefail

function add_mysql_server_repository() {
  cd /tmp
  wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb
  sudo dpkg -i mysql-apt-config_0.8.13-1_all.deb
}

function add_postgresql_server_repository() {
  sudo apt install gnupg -y
  echo "deb http://apt.postgresql.org/pub/repos/apt \"$(lib_release)-pgdg\" main" | sudo tee /etc/apt/sources.list.d/pgdg.list
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
}

function install_apt_packages() {
  if type "apt" >/dev/null 2>&1; then
    sudo apt update -y
    sudo apt install -y \
			xsel \
			zsh \
			tshark \
      lsb-release
    # TODO: Debian 11 だと失敗する (2021/8/21現在)
    # add_mysql_server_repository
    add_postgresql_server_repository
		sudo apt update -y
		sudo apt install -y \
      postgresql-12
      # mysql-server \
	fi
}

install_apt_packages
