#!/usr/bin/env bash

function install_wsl_sudo_hello() {
	if [[ ! -e /mnt/c ]]; then
		return 0
	fi

	mkdir -p ~/Downloads
	cd ~/Downloads || return 1
	if [[ ! -e ~/Downloads/wsl-hello-sudo.tar.gz ]]; then
		wget http://github.com/nullpo-head/WSL-Hello-sudo/releases/latest/download/release.tar.gz -O wsl-hello-sudo.tar.gz
	fi
	mkdir -p ~/Downloads/wsl-hello-sudo
	tar -xvf ~/Downloads/wsl-hello-sudo.tar.gz -C ~/Downloads/wsl-hello-sudo --strip-components 1
	cd ~/Downloads/wsl-hello-sudo || return 1
	./install.sh 2>/dev/null
	echo "✅ WSL-Hello-sudo has been installed successfully!"
	echo "👉 You need to add 'auth sufficient pam_wsl_hello.so' to the top line of your '/etc/pam.d/sudo'. See also https://github.com/nullpo-head/WSL-Hello-sudo/#configuration."
	return 0
}

install_wsl_sudo_hello
