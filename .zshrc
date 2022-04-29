#!/usr/bin/env zsh

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'

# End of lines added by compinstall

# common settings ----------------------------------------------------------------------------------------------------

if [ -f ~/.shrc.sh ]; then
    source ~/.shrc.sh
else
    echo "⚠ ~/.shrc.sh doesn't exist"
fi

# Prezto ----------------------------------------------------------------------------------------------------

if [[ -e ~/.nix-profile/share/zsh-prezto/init.zsh ]]; then
    # source ~/.nix-profile/share/zsh-prezto/init.zsh
    # コマンドの補完が激遅になる
    unsetopt PATH_DIRS
    unsetopt AUTO_PARAM_SLASH
fi

# デバッグ用
# if (command -v zprof > /dev/null 2>&1); then
#     zprof
# fi
