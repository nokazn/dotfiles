#!/usr/bin/env bash

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#
# Prompt
#

function ps1_date() {
	date +'%Y-%m-%d %-H:%M:%S'
}

function ps1_git() {
	# TODO: "[${COL}${LOC}]" とすると関数内で色を埋め込むときに \[\] が表示されてしまう
	local -r COL="\033[" # "\e[" と同義
	local -r LOC=""
	local -r RESET="${COL}m${LOC}" # "${COL}00m${LOC}" と同義
	# local -r RED="${COL}01;31m${LOC}"
	local -r GREEN="${COL}01;32m${LOC}"
	local -r YELLOW="${COL}00;33m${LOC}"
	local -r BLUE="${COL}01;34m${LOC}"
	# local -r MAGENTA="${COL}00;35m${LOC}"
	local -r CYAN="${COL}00;36m${LOC}"
	local -r WHITE="${COL}00;37m${LOC}"
	local -r BLUE_BG="${COL}01;44m${LOC}"

	local -r branch hash
	branch=$(git symbolic-ref --short HEAD 2>/dev/null)
	hash=$(git log --pretty=format:'%h' -n 1 2>/dev/null)
	if [[ -n ${branch} ]]; then
		if [[ -n ${hash} ]]; then
			echo -e -n "${CYAN}(${WHITE}${BLUE_BG}${branch}${CYAN}: ${hash})${RESET} "
		else
			echo -e -n "${CYAN}(${WHITE}${BLUE_BG}${branch}${CYAN})${RESET} "
		fi
	else
		echo -e -n
	fi
}

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	# PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
	# 実行ごとに評価させたい部分は ' で囲む
	PS1='${debian_chroot:+($debian_chroot)}'"${GREEN}\u@\h${RESET}: ${BLUE}\w "'$(ps1_git)'"${YELLOW}"'$(ps1_date)'"${RESET}\n\\$ "
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*) ;;
esac

#
# Completion
#

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		# shellcheck disable=SC1091
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		# shellcheck disable=SC1091
		. /etc/bash_completion
	fi
fi
