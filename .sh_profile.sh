#!/usr/bin/env bash

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx
# TODO: 実行に時間がかかるので、起動時に実行させるとその分起動も遅くなる
# fcitx-autostart &> /dev/null

export EDITOR=vim

# WSL ----------------------------------------------------------------------------------------------------

if [[ "$(uname -r)" == *microsoft* ]]; then
    # WSLg 非対応の WSL 内では X Server 経由で GUI を表示
    if [[ ! -e /mnt/c/Windows/system32/wslg.exe ]]; then
        if [[ -f "$HOME/dotfiles/scripts/start-vcxsrv.sh" ]]; then
            # WSL に割り当てられる IP アドレスを取得して設定
            DISPLAY="$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0.0"
            export DISPLAY
            "$HOME/dotfiles/scripts/start-vcxsrv.sh"
        else
            echo "⚠ file 'start-vcxsrv.sh' doesn't exist at ${START_VCXSRV_PATH}" >&2
        fi
    fi
fi
