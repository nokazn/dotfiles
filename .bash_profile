#!/usr/bin/env bash

# if running bash
if [[ -n $BASH_VERSION ]]; then
    # include .bashrc if it exists
    if [[ -f "$HOME/.bashrc" ]]; then
        . "$HOME/.bashrc"
    fi
fi

# ------------------------------------------------------------------------------------

if [[ -f "$HOME/.path.sh" ]]; then
    source "$HOME/.path.sh"
else
    echo "⚠ ~/.path.sh doesn't exist"
fi

if [[ -f "$HOME/dotfiles/scripts/cdhist.sh" ]]; then
    . "$HOME/dotfiles/scripts/cdhist.sh"
else
    echo "⚠ cdhist doesn't exist at '$HOME/dotfiles/scripts/cdhist.sh'" >&2
fi
