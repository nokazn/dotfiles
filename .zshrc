#!/usr/bin/env zsh

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'

# 色を使用
autoload -Uz colors ; colors
# 補完を有効化
autoload -Uz compinit && compinit
# End of lines added by compinstall

# ---------------------------------------- common settings  ----------------------------------------

if [ -f ~/.shrc.sh ]; then
    source ~/.shrc.sh
else
    echo "⚠ ~/.shrc.sh doesn't exist"
fi

# ------------------------------ Prezto ------------------------------

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
    # コマンドの補完が激遅になる
    unsetopt PATH_DIRS
    unsetopt AUTO_PARAM_SLASH
fi
