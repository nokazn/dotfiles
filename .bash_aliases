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
alias exal='exa -l'

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
alias ssh-keygen-rsa="ssh-keygen -t rsa -b 4096 -C"
alias apt-install='apt install --no-install-recommends'
alias apt-purge='apt --purge remove'
alias dc='docker'
alias dcc='docker-compose'
alias lg='lazygit'
alias python='python3'
alias tf='terraform'
alias chrome='google-chrome-stable'
alias nix-shell='nix-shell --run $SHELL'
alias hm='home-manager'
alias hmsw='home-manager switch -f ~/dotfiles/.config/nixpkgs/home.nix'
alias sampler='sampler -c ~/.config/sampler/config.yml'

# docker ----------------------------------------------------------------------------------------------------

# Run nginx in Docker.
function docker-nginx() {
    docker run -d --name nginx -p 8080:80 ngin
	echo "✅ Running nginx at port 8080 in 'nginx' container."
}

# Run PostgreSQL in Docker.
function docker-postgresql() {
    docker run --rm -d \
		--name postgres \
		-e POSTGRES_PASSWORD=password \
		-p 5432:5432 \
		-v postgres-tmp:/var/lib/postgresql/data \
		postgres:12-alpine
	echo "✅ Running PostgreSQL at port 5432 in 'postgresql' container. You can connect by executing 'psql -h localhost -p 5432 -U postgres'."
}

# Run MySQL in Docker/
function docker-mysql() {
    docker network create mysql-network
	docker run -d --rm \
        --name mysql \
        --network mysql-network \
        -e MYSQL_ROOT_PASSWORD=password \
        -p 3306:3306 \
        -v mysql-tmp-data:/var/lib/mysql \
        -v mysql-tmp-log:/var/log/mysql \
        mysql:5.7
	echo "✅ Running MySQL at port 3306 in 'mysql' container."
}

# Remove MySql container.
function docker-mysql-rm() {
    docker stop mysql
	docker network rm mysql-network
    echo "✅ Removed 'mysql' container."
}

# Run Redis in Docker.
function docker-redis() {
    docker network create redis-network
	docker run -d --rm \
		--name redis \
		--network redis-network \
		-p 6379:6379 \
		-v redis-tmp:/data \
		redis:6.0.10-alpine \
		redis-server --appendonly yes
	echo "✅ Running Redis at port 6379 in 'redis' container."
}

# Remove Redis container.
function docker-redis-rm() {
    docker stop redis
	docker network rm redis-network
	echo "✅ Removed 'redis' container."
}

# Run Memcached in Docker.
function docker-memcached() {
    docker network create memcached-network
	docker run -d --rm \
		--name memcached \
		--network memcached-network \
		-p 11211:11211 \
		memcached:1.6-alpine
	echo "✅ Running Memcached at port 11211 in 'memcached' container."
}

# Remove Memcached container.
function docker-memcached-rm() {
    docker stop memcached
	docker network rm memcached-network
	echo "✅ Removed 'memcached' container."
}

# Run Wordpress & MySQL in Docker.
function docker-wordpress() {
    docker run -d --rm --name wordpress \
		--network mysql-network \
		-e WORDPRESS_DB_PASSWORD=password \
		-p 8080:80 \
		wordpress
	echo "✅ Running Wordpress at port 8080 in 'wordpress' container."
}

# Remove all untagged images.
function docker-rmi-untagged-images() {
    docker rmi "$(docker images -f "dangling=true" -q --no-trunc)"
}

# utilities ----------------------------------------------------------------------------------------------------

# Show a list of installed apt packages.
function apt-list() {
    apt list --installed | more
}

# Show apt packages installed/uninstalled history.
function apt-history() {
    # tee でプロセス置換して、+ (緑) の場合と - (赤) の場合で色を分け、標準出力を捨てる
    grep -e "install" -e "remove" < /var/log/apt/history.log \
		| sed -E -e "s/^.*apt(-get)?(\s--?\S+)*\s(install|remove)(\s--?\S+)*\s/\3:/" \
		| sed -E -e "s/(^|\s)--?\S+//g" -e "s/install:/+ /" -e "s/remove:/- /" \
        | xargs -I "{}" bash -c "if [[ \"{}\" =~ ^\+ ]]; then printf \"\033[32m{}\033[0m\n\"; elif [[ \"{}\" =~ ^- ]]; then printf \"\033[31m{}\033[0m\n\"; fi"
}

# Show a list of apt packages a user manually installed.
function apt-history-installed() {
    echo "List of apt packages you have ever installed. (from '/var/log/apt/history.log')"
    # ...apt|apt-get [options] install [options] を削除 -> 行中の options を削除 -> パッケージごとに改行
	local -r apt_list=$(apt list --installed)
    grep "install" < /var/log/apt/history.log \
		| sed -E -e "s/^.*apt(-get)?(\s--?\S+)*\sinstall(\s--?\S+)*\s//" \
		| sed -E -e "s/(^|\s)--?\S+//g" -e "s/(\S)\s+(\S)/\1\n\2/g" \
		| sort \
		| uniq \
		| xargs -I {} sh -c "echo \"${apt_list}\" | grep -e '{}/'" \
		| column -t -s " " \
		| sed -E -e "s/^/  /g"
}

# List of installed nix packages.
function nix-list() {
    nix-env -qa --installed
    if type home-manager >/dev/null 2>&1; then
        home-manager packages
    fi
}

# List of installed npm packages.
function npm-list() {
    npm list --depth=0 -g
}

function path() {
	echo "${PATH}" \
		| sed -E -e "s/:/\n/g" \
		| sed -e "s/^/  /"
}

function aliases() {
		alias \
			| sed -E -e "s/^alias\s//" \
			| sed -E -e "s/([a-zA-Z]+)=/\1Γ/" \
			| sed -E -e "s/Γ'/Γ/" \
			| sed -E -e "s/'$//" \
			| column -s "Γ" -t
}

# Change default shell for a current user
function chshs() {
    chsh -s "$(which  "$1")"
}

function zsh-colors() {
		seq -w 255 \
			| xargs -I "{}" echo -n -e "\e[38;5;{}m {}"; echo "\e[0m"
}
