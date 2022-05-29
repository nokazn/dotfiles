# `exa` aliases
alias exa = exa --icons --git
alias exat = exa --tree
alias exal = exa -l

# Git aliases
alias g = git
alias branch = git symbolic-ref --short HEAD

# custom aliases
alias dotfiles = cd ~/dotfiles
alias relogin = exec $SHELL -l
alias repath = source ~/.path.sh
alias realias = source ~/.bash_aliases
alias relaod-tmux = tmux source-file ~/.config/tmux/tmux.conf
alias ssh-keygen-rsa = ssh-keygen -t rsa -b 4096 -C
alias apt-install = apt install --no-install-recommends
alias apt-purge = apt --purge remove
alias dc = docker
alias dcc = docker-compose
alias lg = lazygit
alias tf = terraform
alias chrome = google-chrome-stable
alias nix-shell = nix-shell --run $SHELL
alias hm = home-manager
alias hmsw = home-manager switch -f ~/dotfiles/.config/nixpkgs/home.nix
alias sampler = sampler -c ~/.config/sampler/config.yml
