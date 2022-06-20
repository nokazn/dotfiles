#!/usr/bin/env zsh

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'
# End of lines added by compinstall

# TODO: https://github.com/NixOS/nix/issues/5445
# 補完を有効化
autoload -Uz compinit && compinit

# .zshrc が変更されたとき、自動でコンパイルする
if [ $DOTFILES/.zshrc -nt ~/.zshrc.zwc ]; then
    zcompile ~/.zshrc
fi

# デバッグ用
# if (command -v zprof > /dev/null 2>&1); then
#     zprof
# fi
