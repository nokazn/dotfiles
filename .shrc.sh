#!/usr/bin/env bash

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
    # shellcheck source=~/.path.sh
    source "$HOME/.path.sh"
else
    echo "⚠ .path.sh doesn't exist"
fi
