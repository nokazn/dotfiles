#!/usr/bin/env bash

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx
fcitx-autostart &> /dev/null

# aliases ----------------------------------------------------------------------------------------------------
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# path ----------------------------------------------------------------------------------------------------

if [[ -f "$HOME/.path.sh" ]]; then
    source "$HOME/.path.sh"
    export PATH_SET_CORRECTLY=true
else
    echo "⚠ .path.sh doesn't exist"
fi
