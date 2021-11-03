#!/usr/bin/env bash

# ---------------------------------------- WSL  ----------------------------------------

# WSLg 非対応の WSL 内では X Server 経由で GUI を表示
if type wslsys >/dev/null 2>&1 && [[ ! -e /mnt/c/Windows/system32/wslg.exe ]]; then
    if [[ -f "$HOME/dotfiles/scripts/start_vcxsrv.sh" ]]; then
        # WSL に割り当てられる IP アドレスを取得して設定
        DISPLAY="$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0.0"
        export DISPLAY
        "$HOME/dotfiles/scripts/start_vcxsrv.sh"
    else
        echo "⚠ file 'start_vcxsrv.sh' doesn't exist at ${START_VCXSRV_PATH}" >&2
    fi
fi

# TODO: WSL 起動時に実行されないため、ログイン時に実行しているが、 wsl.conf でやりたい
if [[ -e ~/.nix-profile/bin/daemonize ]] && command -v dockerd >/dev/null ; then
    sudo ~/.nix-profile/bin/daemonize "$(command -v dockerd)"
fi
