#!/usr/bin/env bash

set -eu -o pipefail

function add_mysql_server_repository() {
  cd /tmp
  wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb
  sudo dpkg -i mysql-apt-config_0.8.13-1_all.deb
}

function add_mysql_server_repository() {
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
}

function install_apt_packages() {
  if type "apt" >/dev/null 2>&1; then
    add_mysql_server_repository
    add_mysql_server_repository
		sudo apt update -y
    sudo apt upgrade -y
		sudo apt install -y \
			xsel \
			zsh \
			tshark \
      mysql-server \
      postgresql-12
	fi
}

install_apt_packages
