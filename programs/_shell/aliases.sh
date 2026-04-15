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

# Remove all untagged images.
function docker-rmi-untagged-images() {
	docker rmi "$(docker images -f "dangling=true" -q --no-trunc)"
}

#
# fzf
#

function fgsw() {
	# Not using {1} directly: worktree-checked-out branches prefix the line with "+", pushing the branch name to {2}
	local -r branch="$(git branch -vv | grep -v '^\s*\*' | fzf -q "$1" --preview 'b={1}; [[ "$b" == "+" ]] && b={2}; git lg --color=always "$b"')"
	if [[ -n "${branch}" ]]; then
		git switch "$(awk '{print $1}' <<<"${branch}")"
	fi
}

function fgswa() {
	# Not using {1} directly: worktree-checked-out branches prefix the line with "+", pushing the branch name to {2}
	local -r branch="$(git branch -vva | grep -v '^\s*\*' | grep -E -v '/HEAD$' | fzf -q "$1" --preview 'b={1}; [[ "$b" == "+" ]] && b={2}; git lg --color=always "$b"')"
	if [[ -n "${branch}" ]]; then
		local -r name="$(awk '{print $1}' <<<"${branch}" | sed -E 's/^remotes\/(origin|upstream)\///')"
		git switch "${name}"
	fi
}

function fgswr() {
	git fetch
	local -r branch="$(git branch -vva --remotes --color=always --color=always | grep -E -v '/HEAD$' | fzf -q "$1" --ansi --preview 'git lg --color=always {1}')"
	if [[ -n "${branch}" ]]; then
		git switch "$(awk '{print $1}' <<<"${branch}" | sed -E 's/^[^\/]+\/(.+)$/\1/')"
	fi
}

function fgshow() {
	git lg |
		fzf -q "$1" \
			--ansi \
			--no-sort \
			--reverse \
			--tiebreak=index \
			--bind=ctrl-s:toggle-sort \
			--preview 'git show --color=always $(grep -o "[a-f0-9]\{7,\}" <<< {} | head -1)' \
			--bind "ctrl-m:execute:
				(grep -o '[a-f0-9]\{7\}' \
					| head -1 \
					| xargs -I % sh -c 'git show --color=always % \
					| less -R'
				) << EOF
					{}
				EOF"
}

function fglog() {
	local -r target="${1:-.}"
	git log --oneline --follow --color=always -- "${target}" |
		fzf --ansi \
			--no-sort \
			--reverse \
			--tiebreak=index \
			--preview 'git show --color=always {1} -- "'"${target}"'"' \
			--bind "ctrl-m:execute:
				git show --color=always {1} -- '${target}' | less -R"
}

function frg() {
	local -r query="${1:-}"
	local -ra selected=($(
		: | fzf --multi \
			--disabled \
			--query "${query}" \
			--delimiter '\t' \
			--bind "change:reload:rg --line-number --no-heading --color=never {q} | awk -F: '{printf \"%-40s\t%s\n\", \$1\":\" \$2, substr(\$0, index(\$0,\$3))}' || true" \
			--preview 'f=$(echo {1} | sed "s/:[0-9]*$//"); n=$(echo {1} | grep -o "[0-9]*$"); n=${n:-1}; bat --color=always --highlight-line "$n" --line-range "$(( n > 5 ? n - 5 : 1 )):$(( n + 5 ))" "$f"' |
			awk -F'\t' '{print $1}'
	))
	if [[ ${#selected[@]} -gt 0 ]]; then
		printf '%s\n' "${selected[@]}"
	fi
}

function falias() {
	aliases | fzf -q "$1"
}

function _fd() {
	fd \
		--maxdepth 5 \
		--exclude 'Library' \
		--exclude 'Applications' \
		--exclude 'Google Drive' \
		"$@"
}

function ffd() {
	_fd "" | fzf -q "$1" --preview 'if [ -d {} ]; then tree -L 3 -C {} | head -100; else bat --color=always {}; fi'
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
		_fd "" ~ -t d | fzf -q "$1" --preview 'if [ -d {} ]; then tree -L 3 -C {} | head -100; else bat --color=always {}; fi'
	)"
	if [[ -n "${dir}" ]] && [[ -d "${dir}" ]]; then
		cd "${dir}" || return 1
	fi
}

function ffcode() {
	local keyword
	if [[ -n "$1" ]] && [[ ! "$1" =~ ^- ]]; then
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
			fzf -q "$keyword" --preview 'if [ -d {} ]; then tree -L 3 -C {} | head -100; else bat --color=always {}; fi'
	)"
	if [[ -n "${dir}" ]] && [[ -d "${dir}" ]]; then
		code "${dir}" "$@"
	fi
}

function fvim() {
	local keyword
	if [[ -n "$1" ]] && [[ ! "$1" =~ ^- ]]; then
		keyword="$1"
		shift
	fi
	local -r file="$(_fd --hidden | fzf -q "$keyword" --preview 'if [ -d {} ]; then tree -L 3 -C {} | head -100; else bat --color=always {}; fi')"
	if [[ -e "${file}" ]]; then
		vim "${file}" "$@"
	fi
}

function fbroot() {
	local keyword
	if [[ -n "$1" ]] && [[ ! "$1" =~ ^- ]]; then
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
	if [[ -n "$1" ]] && [[ ! "$1" =~ ^- ]]; then
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
