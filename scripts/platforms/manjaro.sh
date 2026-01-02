#!/usr/bin/env bash

function main() {
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
		fcitx5-configtool
	pamac build \
		visual-studio-code-bin
}

main
