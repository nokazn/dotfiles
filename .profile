# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi

    # include .bash_profile if it exists
    if [ -f "$HOME/.bash_profile" ]; then
    source "$HOME/.bash_profile"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# nodenv
if [ -d "${HOME}/.nodenv" ]; then
    export NODENV_ROOT="${HOME}/.nodenv"
    export PATH="${NODENV_ROOT}/bin:${PATH}"
    # nodenv コマンドが存在する場合
    if type "nodenv" >/dev/null 2>&1; then
        eval "$(nodenv init -)"
    fi
fi

# goenv
if [ -d "${HOME}/.goenv" ]; then
    export GOENV_ROOT="${HOME}/.goenv"
    export PATH="${GOENV_ROOT}/bin:${PATH}"
    # goenv コマンドが存在する場合
    if type "goenv" >/dev/null 2>&1; then
        eval "$(goenv init -)"
        # GOROOT はよしなに設定してくれる
        export GOPATH="${HOME}/go"
        export PATH="${GOROOT}/bin:${PATH}"
        export PATH="${PATH}:${GOPATH}/bin"
        # Go Modules を有効にする
        export 'GO111MODULE=on'
    fi
fi

# pyenv
if [ -d "${HOME}/.pyenv" ]; then
    export PYENV_ROOT="${HOME}/.pyenv"
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    # pyenv コマンドが存在する場合
    if type "pyenv" >/dev/null 2>&1; then
        eval "$(pyenv init -)"
    fi
fi
# ユーザーインストールした pipenv
if [ -d "${HOME}/.local/bin/pipenv" ]; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi

# Deno
DENO_INSTALL="${HOME}/.deno"
if [ -d "${DENO_INSTALL}" ]; then
    export DENO_INSTALL=$DENO_INSTALL
    export PATH="/${DENO_INSTALL}/bin:${PATH}:"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
SDKMAN_DIR="${HOME}/.sdkman"
if [ -d SDKMAN_DIR ]; then
    export SDKMAN_DIR="${SDKMAN_DIR}"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi
