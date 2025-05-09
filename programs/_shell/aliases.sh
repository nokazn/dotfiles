# shellcheck disable=2148

# ----------------------------------------------------------------------------------------------------
# Shell aliases
# ----------------------------------------------------------------------------------------------------

#
# WSL aliases
#

# @param None
# @param {0|1}
function _is-wsl() {
	[[ "$(uname -r)" == *microsoft* ]]
}

# cmd.exe で実行する
# @param {string}
function run-cmd() {
	if [[ ! -e /mnt/c ]]; then
		return 0
	fi
	cd /mnt/c || return 1
	/mnt/c/Windows/system32/cmd.exe /c "$1 ${*:2}" | tr -d "\r"
	cd "${OLDPWD}" || return 1
}

# VSCode を開く
function code() {
	if ! _is-wsl; then
		unfunction "$0"
		$0 "$@"
		return 0
	fi

	local codePath=${CODE_PATH}
	if [[ -z ${codePath} ]]; then
		codePath="$(wslpath -u "$(run-cmd where code | head -1)")"
	fi

	if [[ -x ${codePath} ]]; then
		${codePath} "$@"
		export CODE_PATH=${codePath}
	else
		unfunction "$0"
		$0 "$@"
	fi
}

#
# Docker
#

# Nginx
NGINX_CONTAINER="nginx"
unset NGINX_CONTAINER
NGINX_PORT=8080
unset NGINX_PORT

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

# PostgresQL
POSTGRESQL_CONTAINER="postgresql"
unset POSTGRESQL_CONTAINER
POSTGRESQL_PORT=5432
unset POSTGRESQL_PORT

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

# MySQL
MYSQL_CONTAINER="mysql"
unset MYSQL_CONTAINER
MYSQL_NETWORK="mysql-network"
unset MYSQL_NETWORK
MYSQL_PORT=3306
unset MYSQL_PORT

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

# Redis
REDIS_CONTAINER="redis"
unset REDIS_CONTAINER
REDIS_NETWORK=redis-"network"
unset REDIS_NETWORK
REDIS_PORT=6379
unset REDIS_PORT

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

# Memcached
MEMCACHED_CONTAINER="memcached"
unset MEMCACHED_CONTAINER
MEMCACHED_NETWORK="memcached-network"
unset MEMCACHED_NETWORK
MEMCACHED_PORT=11121
unset MEMCACHED_PORT

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

# Wordpress
WORKDPRESS_CONTAINER="wordpress"
unset WORKDPRESS_CONTAINER
WORKDPRESS_PORT=8080
unset WORKDPRESS_PORT

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

#
# fzf
#

function fgsw() {
	local -r branch="$(git branch -vv | grep -v '^\s*\*' | fzf -q "$1")"
	git switch "$(awk '{print $1}' <<<"${branch}")"
}

function fgswa() {
	local -r branch="$(git branch -vva | grep -v '^\s*\*' | fzf -q "$1")"
	git switch "$(awk '{print $1}' <<<"${branch}")"
}

function fgbrr() {
	git fetch
	local -r branch="$(git branch -vva --remotes --color=always --color=always | grep -v HEAD | fzf -q "$1" --ansi)"
	if [[ -n "${branch}" ]]; then
		local -r remote_branch="$(awk '{print $1}' <<<"${branch}")"
		git branch "$(sed -E 's/^[^\/]+\/(.+)$/\1/' <<<"${remote_branch}")" "${remote_branch}"
	fi
}

function fgswr() {
	git fetch
	local -r branch="$(git branch -vva --remotes --color=always --color=always | grep -v HEAD | fzf -q "$1" --ansi)"
	if [[ -n "${branch}" ]]; then
		git switch "$(awk '{print $1}' <<<"${branch}" | sed -E 's/^[^\/]+\/(.+)$/\1/')"
	fi
}

function fgshow() {
	git log --graph --branches --pretty=default --color=always |
		fzf -q "$1" \
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

function _fd() {
	fd \
		--maxdepth 5 \
		--exclude 'Library/' \
		--exclude 'Applications/' \
		--exclude 'Google Drive/' \
		"$@"
}

function fcd() {
	local -r dir="$(
		_fd "" "${1:-.}" -t d | fzf -q "$2"
	)"
	if [[ -n "${dir}" ]] && [[ -d "${dir}" ]]; then
		cd "${dir}" || return 1
	fi
}

function ffcd() {
	local -r dir="$(
		_fd "" ~ -t d | fzf -q "$1"
	)"
	if [[ -n "${dir}" ]] && [[ -d "${dir}" ]]; then
		cd "${dir}" || return 1
	fi
}

function ffcode() {
	local keyword
	if [[ ! "$1" =~ ^- ]]; then
		keyword="$1"
		shift
	fi
	local -r dir="$(
		_fd "" ~ \
			--exclude '[dD]ownloads/' \
			--exclude '[dD]ocuments/' \
			--exclude '[mM]usic/' \
			--exclude '[pP]ictures/' \
			--exclude '[mM]ovies/' |
			fzf -q "$keyword"
	)"
	if [[ -n "${dir}" ]] && [[ -d "${dir}" ]]; then
		code "${dir}" "$@"
	fi
}

function fvim() {
	local keyword
	if [[ ! "$1" =~ ^- ]]; then
		keyword="$1"
		shift
	fi
	local -r file="$(_fd --hidden | fzf -q "$keyword")"
	if [[ -e "${file}" ]]; then
		vim "${file}" "$@"
	fi
}

function fbroot() {
	local keyword
	if [[ ! "$1" =~ ^- ]]; then
		keyword="$1"
		shift
	fi
	local -r dir="$(
		_fd -t d "" "${1:-.}" | fzf -q "$2"
	)"
	if [[ -n "${dir}" ]] && [[ -d "${dir}" ]]; then
		broot "${dir}" "$@"
	fi
}

function ffbroot() {
	local keyword
	if [[ ! "$1" =~ ^- ]]; then
		keyword="$1"
		shift
	fi
	local -r dir="$(
		_fd "" ~ -t d | fzf -q "$keyword"
	)"
	if [[ -n "${dir}" ]] && [[ -d "${dir}" ]]; then
		broot "${dir}" "$@"
	fi
}

#
# utilities
#

# Show a list of installed apt packages.
function apt-list() {
	apt list --installed | more
}

# Show apt packages installed/uninstalled history.
function apt-history() {
	# tee でプロセス置換して、+ (緑) の場合と - (赤) の場合で色を分け、標準出力を捨������������る
	grep -e "install" -e "remove" </var/log/apt/history.log |
		sed -E -e "s/^.*apt(-get)?(\s--?\S+)*\s(install|remove)(\s--?\S+)*\s/\3:/" |
		sed -E -e "s/(^|\s)--?\S+//g" -e "s/install:/+ /" -e "s/remove:/- /" |
		xargs -I "{}" bash -c "if [[ \"{}\" =~ ^\+ ]]; then printf \"\033[32m{}\033[0m\n\"; elif [[ \"{}\" =~ ^- ]]; then printf \"\033[31m{}\033[0m\n\"; fi"
}

# Show a list of apt packages a user manually installed.
function apt-history-installed() {
	echo "List of apt packages you have ever installed. (from '/var/log/apt/history.log')"
	# ...apt|apt-get [options] install [options] を削除 -> 行中の options を削除 -> パッケージごとに改行
	local -r apt_list=$(apt list --installed)
	grep "install" </var/log/apt/history.log |
		sed -E -e "s/^.*apt(-get)?(\s--?\S+)*\sinstall(\s--?\S+)*\s//" |
		sed -E -e "s/(^|\s)--?\S+//g" -e "s/(\S)\s+(\S)/\1\n\2/g" |
		sort |
		uniq |
		xargs -I {} sh -c "echo \"${apt_list}\" | grep -e '{}/'" |
		column -t -s " " |
		sed -E -e "s/^/  /g"
}

function apt-upgrade() {
	sudo apt update -y
	if [[ $(apt list --upgradable 2>/dev/null | grep -c upgradable) -gt 0 ]]; then
		sudo apt upgrade -y
	fi
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
	sed -E -e "s/:/\n/g" <<<"${PATH}" |
		sed -e "s/^/  /"
}

function aliases() {
	alias |
		sed -E -e "s/^alias\s//" |
		sed -E -e "s/([a-zA-Z]+)=/\1Γ/" |
		sed -E -e "s/Γ'/Γ/" |
		sed -E -e "s/'$//" |
		column -s "Γ" -t
}

# Show Git aliases
function hg() {
	git config --get-regexp "alias.*" |
		sed -E -e "s/alias\.//" -e "s/\s/#/" |
		column -s "#" -t |
		more
}

# Change default shell for a current user
function chshs() {
	local -r shell_path="$(command -v "$1")"
	if ! grep "${shell_path}" /etc/shells --quiet; then
		echo "${shell_path}" | sudo tee -a /etc/shells >/dev/null
	fi
	chsh -s "${shell_path}"
}

function zsh-colors() {
	seq -w 255 |
		xargs -I "{}" echo -n -e "\e[38;5;{}m {}"
	printf "\e[0m\n"
}

function cpu-usage() {
	cut -b 1-4 <<<$((100 - $(mpstat | tail -n 1 | awk '{print $NF}')))
}

function bk-files() {
	find ./ -name "*$(date +"%Y-%m-%d")*.bk" -exec rm -r {} +
}

function re-session-vars() {
	export __HM_SESS_VARS_SOURCED=""
	if [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
		# shellcheck source=~/.nix-profile/etc/profile.d/hm-session-vars.sh
		source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
	elif [[ -f "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]]; then
		# shellcheck disable=SC1091
		source "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
	fi
}

function clip() {
	if _is-wsl; then
		clip.exe "$@"
	elif type xsel >/dev/null 2>&1; then
		xsel --input --clipboard "$@"
	else
		pbcopy "$@"
	fi
}

function touchp() {
	local -r dir=$(dirname "$1")
	if [[ ! -e ${dir} ]]; then
		mkdir -p "${dir}"
	fi
	touch "$1"
}

function deprecate() {
	local -r source="$1"
	local -r destination="${destination_base_dir%/}/${source}"
	if [[ -f "${source}" ]]; then
		mkdir -p "$(dirname "${destination}")"
	elif [[ -d "${source}" ]]; then
		mkdir -p "${destination}"
	else
		echo "❌ source ${source} is not a file or directory."
		return 1
	fi

	local -r destination_base_dir="${2:-deprecated}"
	if [[ ! -d ${destination_base_dir} ]]; then
		mkdir -p "${destination_base_dir}"
	fi

	cp -r -v "${source}" "${destination}"
}
