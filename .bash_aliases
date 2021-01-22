alias dotfiles='cd ~/dotfiles'
alias relogin='exec $SHELL -l'
alias alias-bash='alias | sed -E -e "s/^alias\s//" | column -s "=" -t'

### git aliases
###

alias g='git'
alias alias-git='git config --get-regexp alias.* | sed -E -e "s/^alias\.(\S+)\s/  git \1 | /" -e "s/\s\|\s([a-z])/ | git \1/" -e "s/\!git/git/" | column -s "|" -t | more'
# alias git-alias='git config --get-regexp alias.* | sed -E -n -e "/\[alias\]/,/^$$/p" ~/.gitconfig | sed -E -e "/alias/d" -e "/#/d" -e "s/^(.+)\s=\s/\1 | /" | column -s "|" -t | more'
alias br='git symbolic-ref --short HEAD'
