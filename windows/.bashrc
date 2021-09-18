export LANG=ja_JP.UTF-8

# ------------------------------ aliases ------------------------------
alias md='cd ~/Google\ ドライブ/md'
alias relogin='exec $SHELL -l'

# custom aliases
alias dotfiles='cd ~/dotfiles'
alias relogin='exec $SHELL -l'
alias repath='source ~/.path.sh'
alias tmux-relaod='tmux source-file ~/.tmux.conf'
alias path='echo $PATH | sed -E -e "s/:/\n/g" | sed -e "s/^/  /"'
alias aliases='alias | sed -E -e "s/^alias\s//" | column -s "=" -t'
alias zsh-colors='seq -w 255 | xargs -I "{}" echo -n -e "\e[38;5;{}m {}"; echo "\e[0m"'
alias apt-install='apt install --no-install-recommends'
alias apt-purge='apt --purge remove'

# git aliases
alias g='git'
alias alias-git='git config --get-regexp alias.* | sed -E -e "s/^alias\.(\S+)\s/  git \1 | /" -e "s/\s\|\s([a-z])/ | git \1/" -e "s/\!git/git/" | column -s "|" -t | more'
# alias git-alias='git config --get-regexp alias.* | sed -E -n -e "/\[alias\]/,/^$$/p" ~/.gitconfig | sed -E -e "/alias/d" -e "/#/d" -e "s/^(.+)\s=\s/\1 | /" | column -s "|" -t | more'
alias br='git symbolic-ref --short HEAD'
