# Git aliases
alias g = git
alias branch = git symbolic-ref --short HEAD

# custom aliases
alias dotfiles = cd ~\dotfiles
alias realias = source ~\AppData\Roaming\nushell\aliases.nu
alias ssh-keygen-rsa = ssh-keygen -t rsa -b 4096 -C
alias dc = docker
alias dcc = docker-compose
alias tf = terraform
