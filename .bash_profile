#!/usr/bin/env bash

# if running bash
if [[ -n $BASH_VERSION ]]; then
    # include .bashrc if it exists
    if [[ -f "$HOME/.bashrc" ]]; then
        # shellcheck source=~/.bashrc
        source "$HOME/.bashrc"
    fi
fi
