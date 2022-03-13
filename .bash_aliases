#!/usr/bin/env bash

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	if [[ -r ~/.dircolors ]]; then
		eval "$(dircolors -b ~/.dircolors)"
	else
		eval "$(dircolors -b)"
	fi
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

# some more `ls` aliases
alias la='ls -A'
alias ll='ls -alF'
alias l='ls -F'
alias exa='exa --icons --git'
alias exat='exa --tree'
alias exal='exa -l'

# Git aliases
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
alias relaod-tmux='tmux source-file ~/.config/tmux/tmux.conf'
alias ssh-keygen-rsa="ssh-keygen -t rsa -b 4096 -C"
alias apt-install='apt install --no-install-recommends'
alias apt-purge='apt --purge remove'
alias dc='docker'
alias dcc='docker-compose'
alias lg='lazygit'
alias tf='terraform'
alias chrome='google-chrome-stable'
alias nix-shell='nix-shell --run $SHELL'
alias hm='home-manager'
alias hmsw='home-manager switch -f ~/dotfiles/.config/nixpkgs/home.nix'
alias sampler='sampler -c ~/.config/sampler/config.yml'

# WSL aliases
if [[ "$(uname -r)" == *microsoft* ]]; then
	alias explorer.exe='/mnt/c/Windows/explorer.exe'
	alias bash.exe='/mnt/c/Windows/system32/bash.exe'
	alias cmd.exe='/mnt/c/Windows/system32/cmd.exe'
	alias tasklist.exe='/mnt/c/Windows/system32/tasklist.exe'
	alias clip.exe='/mnt/c/Windows/system32/clip.exe'
	alias clip='/mnt/c/Windows/system32/clip.exe'
	alias wsl.exe='/mnt/c/Windows/system32/wsl.exe'
	alias wsl='/mnt/c/Windows/system32/wsl.exe'
	alias powershell.exe='/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe'
fi

# docker ----------------------------------------------------------------------------------------------------

#
# Nginx
#
NGINX_CONTAINER="nginx"
NGINX_PORT=8080

# Run nginx in Docker.
function docker-nginx() {
	docker run -d --name "${NGINX_CONTAINER}" -p "${NGINX_PORT}:80" nginx
	echo "✅ Running nginx at port ${NGINX_PORT} in '${NGINX_CONTAINER}' container."
}

# Remove nginx in Docker.
function docker-nginx-rm() {
	docker stop "${NGINX_CONTAINER}"
	echo "✅ Removed '${NGINX_CONTAINER}' container."
}

#
# PostgresQL
#
POSTGRESQL_CONTAINER="postgresql"
POSTGRESQL_PORT=5432

# Run PostgreSQL in Docker.
function docker-postgresql() {
	docker run --rm -d \
		--name "${POSTGRESQL_CONTAINER}" \
		-e POSTGRES_PASSWORD=password \
		-p "${POSTGRESQL_CONTAINER}:${POSTGRESQL_CONTAINER}" \
		-v postgres-tmp:/var/lib/postgresql/data \
		postgres:12-alpine
	echo "✅ Running PostgreSQL at port ${POSTGRESQL_PORT} in '${POSTGRESQL_CONTAINER}' container. You can connect by executing 'psql -h localhost -p 5432 -U postgres'."
}

# Run PostgreSQL in Docker.
function docker-postgresql-rm() {
	docker stop "${POSTGRESQL_CONTAINER}"
	echo "✅ Removed '${POSTGRESQL_CONTAINER}' container."
}

#
# MySQL
#
MYSQL_CONTAINER="mysql"
MYSQL_NETWORK="mysql-network"
MYSQL_PORT=3306

# Run MySQL in Docker/
function docker-mysql() {
	docker network create "${MYSQL_NETWORK}"
	docker run -d --rm \
		--name "${MYSQL_CONTAINER}" \
		--network "${MYSQL_NETWORK}" \
		-e MYSQL_ROOT_PASSWORD=password \
		-p "${MYSQL_PORT}:${MYSQL_PORT}" \
		-v mysql-tmp-data:/var/lib/mysql \
		-v mysql-tmp-log:/var/log/mysql \
		mysql:5.7
	echo "✅ Running MySQL at port ${MYSQL_PORT} in '${MYSQL_CONTAINER}' container."
}

# Remove MySql container.
function docker-mysql-rm() {
	docker stop "${MYSQL_CONTAINER}"
	docker network rm "${MYSQL_NETWORK}"
	echo "✅ Removed '${MYSQL_CONTAINER}' container."
}

#
# Redis
#
REDIS_CONTAINER="redis"
REDIS_NETWORK=redis-"network"
REDIS_PORT=6379

# Run Redis in Docker.
function docker-redis() {
	docker network create "${REDIS_NETWORK}"
	docker run -d --rm \
		--name "${REDIS_CONTAINER}" \
		--network "${REDIS_NETWORK}" \
		-p "${REDIS_PORT}:${REDIS_PORT}" \
		-v redis-tmp:/data \
		redis:6.0.10-alpine \
		redis-server --appendonly yes
	echo "✅ Running Redis at port ${REDIS_PORT} in '${REDIS_CONTAINER}' container."
}

# Remove Redis container.
function docker-redis-rm() {
	docker stop "${REDIS_CONTAINER}"
	docker network rm "${REDIS_NETWORK}"
	echo "✅ Removed '${REDIS_CONTAINER}' container."
}

#
# Memcached
#
MEMCACHED_CONTAINER="memcached"
MEMCACHED_NETWORK="memcached-network"
MEMCACHED_PORT=11121

# Run Memcached in Docker.
function docker-memcached() {
	docker network create "${MEMCACHED_NETWORK}"
	docker run -d --rm \
		--name "${MEMCACHED_CONTAINER}" \
		--network "${MEMCACHED_NETWORK}" \
		-p "${MEMCACHED_PORT}:${MEMCACHED_PORT}" \
		memcached:1.6-alpine
	echo "✅ Running Memcached at port ${MEMCACHED_PORT} in '${MEMCACHED_CONTAINER}' container."
}

# Remove Memcached container.
function docker-memcached-rm() {
	docker stop "${MEMCACHED_CONTAINER}"
	docker network rm "${MEMCACHED_NETWORK}"
	echo "✅ Removed '${MEMCACHED_CONTAINER}' container."
}

#
# Wordpress
#
WORKDPRESS_CONTAINER="wordpress"
WORKDPRESS_PORT=8080

# Run Wordpress & MySQL in Docker.
function docker-wordpress() {
	docker-mysql
	docker run -d --rm --name "${WORKDPRESS_CONTAINER}" \
		--network "${MYSQL_NETWORK}" \
		-e WORDPRESS_DB_PASSWORD=password \
		-e WORDPRESS_DB_HOST="localhost" \
		-p "${WORKDPRESS_PORT}:80" \
		wordpress
	echo "✅ Running Wordpress at port ${WORKDPRESS_PORT} in '${WORKDPRESS_CONTAINER}' container."
}

# Run Wordpress & MySQL in Docker.
function docker-wordpress-rm() {
	docker stop "${WORKDPRESS_CONTAINER}"
	echo "✅ Removed '${WORKDPRESS_CONTAINER}' container."
	docker-mysql-rm
}

# Remove all untagged images.
function docker-rmi-untagged-images() {
	docker rmi "$(docker images -f "dangling=true" -q --no-trunc)"
}

# fzf ----------------------------------------------------------------------------------------------------

function fgsw() {
	local -r branch="$(git branch -vv | grep -v '^\s*\*' | fzf -q "$1")"
	git switch "$(awk '{print $1}' <<< "${branch}")"
}

function fgswa() {
	local -r branch="$(git branch -vva | grep -v '^\s*\*' | fzf -q "$1")"
	git switch "$(awk '{print $1}' <<< "${branch}")"
}

function fgbrr() {
	git fetch
	local -r branch="$(git branch -vva --remotes  --color=always --color=always | grep -v HEAD | fzf -q "$1" --ansi)"
	if [[ -n "${branch}" ]]; then
		local -r remote_branch="$(awk '{print $1}' <<< "${branch}")"
		git branch "$(sed -E 's/^[^\/]+\/(.+)$/\1/' <<< "${remote_branch}")" "${remote_branch}"
	fi
}

function fgswr() {
	git fetch
	local -r branch="$(git branch -vva --remotes  --color=always --color=always | grep -v HEAD | fzf -q "$1" --ansi)"
	if [[ -n "${branch}" ]]; then
		git switch "$(awk '{print $1}' <<< "${branch}" | sed -E 's/^[^\/]+\/(.+)$/\1/')"
	fi
}

function fgshow() {
	git log --graph --branches --pretty=default --color=always \
		| fzf -q "$1" \
			--ansi \
			--no-sort \
			--reverse \
			--tiebreak=index \
			--bind=ctrl-s:toggle-sort \
			--bind "ctrl-m:execute:
				(grep -o '[a-f0-9]\{7\}' \
					| head -1 \
					| xargs -I % sh -c 'git show --color=always % \
					| less -R'
				) << EOF
					{}
				EOF"
}

function falias() {
	aliases | fzf -q "$1"
}

function fcd() {
	local -r dir="$(cd ~ || return 1; fd -t d --maxdepth 4 | xargs -I {} readlink -f {} | fzf -q "$1")"
	if [[ -n "${dir}" ]] && [[ -d "${dir}" ]]; then
		cd "${dir}" || return 1
	fi
}

function fcode() {
	local -r dir="$(cd ~ || return 1; fd -t d --maxdepth 4 | xargs -I {} readlink -f {} | fzf -q "$1")"
	if [[ -n "${dir}" ]] && [[ -d "${dir}" ]]; then
		code "${dir}"
	fi
}

function fvim() {
	local -r file="$(fd --hidden . | fzf -q "$1")"
	if [[ -e "${file}" ]]; then
		vim "${file}"
	fi
}

function fbroot() {
	local -r dir="$(cd ~ || return 1; fd -t d --maxdepth 4 | xargs -I {} readlink -f {} | fzf -q "$1")"
	if [[ -n "${dir}" ]] && [[ -d "${dir}" ]]; then
		broot "${dir}"
	fi
}

# utilities ----------------------------------------------------------------------------------------------------

# cmd.exe で echo する
# @param {string}
function echo-in-cmd() {
	cd /mnt/c || return 1;
	wslpath -u "$(/mnt/c/Windows/system32/cmd.exe /c "echo $1" | tr -d "\r")";
	cd "${OLDPWD}" || return 1;
}

# VSCode を開く
function code() {
	local -r codeForUser="$(echo-in-cmd %USERPROFILE%)/AppData/Local/Programs/Microsoft VS Code/bin/code"
	local -r codeForSystem="/mnt/c/Program Files/Microsoft VS Code/bin/code"
	if [[ -e ${codeForUser} ]]; then
		${codeForUser} "$@"
	elif [[ -e ${codeForSystem} ]]; then
		${codeForSystem} "$@"
	else
		code "$@"
	fi
}

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
	local -r shell_path="$(command -v "$1")"
	if ! grep "${shell_path}" /etc/shells --quiet; then
		echo "${shell_path}" | sudo tee -a /etc/shells >/dev/null
	fi
	sudo usermod -s "${shell_path}" "${USER}"
}

function zsh-colors() {
	seq -w 255 \
		| xargs -I "{}" echo -n -e "\e[38;5;{}m {}"; echo "\e[0m"
}

function cpu-usage() {
	cut -b 1-4 <<< $((100 - $(mpstat | tail -n 1 | awk '{print $NF}') ))
}

function bk-files() {
	find ./ -name "*$(date +"%Y-%m-%d")*.bk" -exec rm -r {} +
}
