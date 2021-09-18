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
    . ~/.shrc.sh
else
    echo "⚠ ~/.shrc.sh doesn't exist"
fi

# ------------------------------ Prezto ------------------------------

# TODO: 華僑変数 $NIX_PROFILES から読みたい
if [[ -s ~/.nix-profile/share/zsh-prezto/init.zsh ]]; then
    source ~/.nix-profile/share/zsh-prezto/init.zsh
    # コマンドの補完が激遅になる
    unsetopt PATH_DIRS
    unsetopt AUTO_PARAM_SLASH
elif [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
    # コマンドの補完が激遅になる
    unsetopt PATH_DIRS
    unsetopt AUTO_PARAM_SLASH
fi

# ------------------------------ prompt ------------------------------

if type starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# ------------------------------ history ------------------------------

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
