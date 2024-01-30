# shellcheck disable=2148

# ----------------------------------------------------------------------------------------------------
# Profile
# ----------------------------------------------------------------------------------------------------

# WSL
if [[ "$(uname -r)" == *microsoft* ]]; then
	# WSLg 非対応の WSL 内では X Server 経由で GUI を表示
	if [[ ! -x /mnt/c/Windows/system32/wslg.exe ]]; then
		if [[ -f "$HOME/dotfiles/scripts/start-vcxsrv.sh" ]]; then
			# WSL に割り当てられる IP アドレスを取得して設定
			DISPLAY="$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0.0"
			export DISPLAY
			"$HOME/dotfiles/scripts/start-vcxsrv.sh"
		else
			echo "⚠ file '${HOME}/dotfiles/scripts/start-vcxsrv.sh' doesn't exist." >&2
		fi
	fi

	export BROWSER=wslview
fi
