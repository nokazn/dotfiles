#!/usr/bin/env bash

# if running bash
if [[ -n $BASH_VERSION ]]; then
    # include .bashrc if it exists
    if [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc"
    fi
fi

# ------------------------------------------------------------------------------------

if [ -f ~/.sh_profile.sh ]; then
    source ~/.sh_profile.sh
else
    echo "⚠ ~/.sh_profile.sh doesn't exist"
fi
