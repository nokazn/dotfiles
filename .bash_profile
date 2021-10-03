#!/usr/bin/env bash

# if running bash
if [[ -n $BASH_VERSION ]]; then
    # include .bashrc if it exists
    if [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc"
    fi
fi

# ------------------------------------------------------------------------------------

if [[ -f "$HOME/.path.sh" ]]; then
    source "$HOME/.path.sh"
else
    echo "⚠ ~/.path.sh doesn't exist"
fi
