# if running bash
if [[ -n $BASH_VERSION ]]; then
    # include .bashrc if it exists
    if [[ -f "$HOME/.bashrc" ]]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/bin" ]]; then
    export PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if (type wsl.exe > /dev/null 2>&1) && (uname -r | grep "microsoft" > /dev/null); then
    # WSL 環境下では時刻がずれる場合があるのでハードウェアと合わせておく
    # https://github.com/microsoft/WSL/issues/5324
    sudo hwclock -s
fi

# パスが設定されてなければ設定する
if [[ ! ${PATH_SET_CORRECTLY} == true ]]; then
    if [[ -f "$HOME/.path.sh" ]]; then
        source "$HOME/.path.sh"
        export PATH_SET_CORRECTLY=true
    else
        echo "⚠ .path.sh doesn't exist"
    fi
fi

if [[ -f "$HOME/dotfiles/scripts/cdhist.sh" ]]; then
    . "$HOME/dotfiles/scripts/cdhist.sh"
fi
