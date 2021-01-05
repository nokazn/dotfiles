# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash

# MacOS では動作しない
default_shell=$(grep $USER /etc/passwd | cut --delimiter ":" -f 7)

# 正規表現はクォートしたら動かない
if [[ ! ${default_shell} =~ bash ]] && [[ -n $BASH_VERSION ]]; then
    # include .bash_profile if it exists and isn't the default shell.
    if [[ -f "$HOME/.bash_profile" ]]; then
        source "$HOME/.bash_profile"
    fi
fi
