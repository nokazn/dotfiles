#!/usr/bin/env bash

SCRIPTS_BASE_DIR=$(
	cd "$(dirname "${0}")/.." || exit 1
	pwd
)

function main() {
	sudo pacman -Rs firefox
	sudo pacman -S \
		base \
		base-devel \
		vi \
		vim \
		git \
		make \
		wget \
		openssh \
		fcitx5 \
		fcitx5-mozc \
		fcitx5-gtk \
		fcitx5-qt \
		fcitx5-configtool \
		manjaro-asian-input-support-fcitx5 \
		noto-fonts-cjk \
		docker

	pamac build \
		visual-studio-code-bin

	"${SCRIPTS_BASE_DIR}/flatpak.sh"
}

main
