#!/usr/bin/env bash

set -eu -o pipefail

function main() {
	flatpak install -y --noninteractive \
		com.discordapp.Discord \
		com.getpostman.Postman \
		com.slack.Slack \
		com.spotify.Client \
		com.todoist.Todoist \
		com.visualstudio.code \
		io.typora.Typora \
		org.chromium.Chromium \
		org.gimp.GIMP \
		org.keepassxc.KeePassXC \
		otg.mozilla.firefox \
		otg.mozilla.Thunderbird \
		otg.videolan.VLC \
		us.zoom.Zoom
}

main
