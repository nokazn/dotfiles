#!/usr/bin/env bash

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if type colordiff >/dev/null 2>&1; then
    alias diff='colordiff'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias la='ls -A'
alias ll='ls -alF'
alias l='ls -F'
alias exa='exa --icons --git'
alias exat='exa --tree'

# git aliases
alias g='git'
alias hg='git config --get-regexp alias.* | sed -E -n -e "/\[alias\]/,/^$$/p" ~/.gitconfig | sed -E -e "/alias/d" -e "/#/d" -e "s/^(.+)\s=\s/\1 | /" | column -s "|" -t | more'
alias branch='git symbolic-ref --short HEAD'

# Add an "alert" alias for long running commands.  Use like so:
# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# custom aliases
alias dotfiles='cd ~/dotfiles'
alias relogin='exec $SHELL -l'
alias repath='source ~/.path.sh'
alias realias='source ~/.bash_aliases'
alias relaod-tmux='tmux source-file ~/.tmux.conf'
alias path='echo $PATH | sed -E -e "s/:/\n/g" | sed -e "s/^/  /"'
alias aliases='alias | sed -E -e "s/^alias\s//" | column -s "=" -t'
alias ssh-keygen-rsa="ssh-keygen -t rsa -b 4096 -C"
alias zsh-colors='seq -w 255 | xargs -I "{}" echo -n -e "\e[38;5;{}m {}"; echo "\e[0m"'
alias apt-install='apt install --no-install-recommends'
alias apt-purge='apt --purge remove'
alias dc='docker'
alias dcc='docker-compose'
alias lg='lazygit'
alias python='python3'
alias tf='terraform'
alias chrome='google-chrome-stable'
alias hm='home-manager'

function chshs() {
    chsh -s "$(which "$1")"
}
