#!/usr/bin/env bash

if command -v fcitx >/dev/null; then
    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx
    export XMODIFIERS=@im=fcitx
    export DefaultIMModule=fcitx
    # TODO: 実行に時間がかかるので、起動時に実行させるとその分起動も遅くなる
    # fcitx-autostart &> /dev/null
fi

# WSL ----------------------------------------------------------------------------------------------------

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
fi
