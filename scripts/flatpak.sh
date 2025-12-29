#!/usr/bin/env bash

set -eu -o pipefail

function main() {
	flatpak install -y --noninteractive \
		flathub \
		com.discordapp.Discord \
		com.getpostman.Postman \
		com.slack.Slack \
		com.spotify.Client \
		com.todoist.Todoist \
		org.chromium.Chromium \
		org.keepassxc.KeePassXC \
		org.mozilla.firefox \
		org.wezfurlong.wezterm \
		us.zoom.Zoom
}

main
