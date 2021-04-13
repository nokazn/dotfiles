#!/usr/bin/env bash

# ------------------------------ aliases ------------------------------
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ---------------------------------------- path  ----------------------------------------

# パスが設定されてなければ設定する
if [[ ! ${PATH_SET_CORRECTLY} == true ]]; then
    if [[ -f "$HOME/.path.sh" ]]; then
        source "$HOME/.path.sh"
        export PATH_SET_CORRECTLY=true
    else
        echo "⚠ .path.sh doesn't exist"
    fi
fi


# ---------------------------------------- WSL  ----------------------------------------

if type wsl.exe >/dev/null 2>&1; then
    # VcXsrv
    # WSL 内では X Server 経由で GUI を表示
    if [[ -f "$HOME/dotfiles/scripts/start_vcxsrv.sh" ]]; then
        # WSL に割り当てられる IP アドレスを取得して設定
        DISPLAY="$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0"
        export DISPLAY
        $HOME/dotfiles/scripts/start_vcxsrv.sh
    else
        echo "⚠ file 'start_vcxsrv.sh' doesn't exist at ${START_VCXSRV_PATH}" >&2
    fi

    # ブラウザのランチャー
    if type "wslview" >/dev/null 2>&1; then
        BROWSER="wslview"
        export BROWSER
    else
        echo "⚠ wslview doesn't exist" >&2
    fi
fi
