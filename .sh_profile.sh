#!/usr/bin/env bash

# ---------------------------------------- WSL  ----------------------------------------

if type wslsys >/dev/null 2>&1; then
    # WSLg 非対応の WSL 内では X Server 経由で GUI を表示
    if [[ ! -e /mnt/c/Windows/system32/wslg.exe ]]; then
        if [[ -f "$HOME/dotfiles/scripts/start_vcxsrv.sh" ]]; then
            # WSL に割り当てられる IP アドレスを取得して設定
            DISPLAY="$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0.0"
            export DISPLAY
            "$HOME/dotfiles/scripts/start_vcxsrv.sh"
        else
            echo "⚠ file 'start_vcxsrv.sh' doesn't exist at ${START_VCXSRV_PATH}" >&2
        fi
    fi
fi
