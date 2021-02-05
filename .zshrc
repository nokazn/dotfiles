#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'

# 色を使用
autoload -Uz colors ; colors
# 補完を有効化
autoload -Uz compinit && compinit
# End of lines added by compinstall

# ------------------------------ Prezto ------------------------------

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

    # コマンドの補完が激遅になる
    unsetopt PATH_DIRS
    unsetopt AUTO_PARAM_SLASH
fi

# ------------------------------ prompt ------------------------------

function left-prompt() {
    local transparent='000m'
    local name_t='136m'
    local dir_t='255m'
    local dir_b='027m'

    local arrow='087m'
    local ct='\e[38;5;'
    local cb='\e[30;48;5;'
    local reset='\e[0m'
    local sharp='\uE0B0'

    local user="${cb}${transparent}${ct}${name_t}"
    local dir="${cb}${dir_b}${ct}${dir_t}"
    echo "${user}%n@%m${cb}${dir_b}${ct}${transparent}${sharp} ${dir}%~${reset}${ct}${dir_b}${sharp}${reset}\n${ct}${arrow}▶${reset} "
}

PROMPT='
%F{133}%n%f @ %F{166}%m%f ✨ %F{118}%~%f ${vcs_info_msg_0_}
%F{087}→%f '
RPROMPT="🕙 %F{226}"'$(date +"%Y-%m-%d %-H:%M:%S (%a)")'"%f"

# ------------------------------ history ------------------------------

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# ------------------------------ aliases ------------------------------

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ---------------------------------------- path  ----------------------------------------

# パスが設定されてなければ設定する
if [[ ! ${PATH_SET_CORRECTLY} == true ]]; then
    if [[ -f "$HOME/.path.sh" ]]; then
        source "$HOME/.path.sh"
        export PATH_SET_CORRECTLY=true
    else
        echo "⚠ .path.sh doesn't exist"
    fi
fi

# ---------------------------------------- VcXsrv  ----------------------------------------

# WSL 内では X Server 経由で GUI を表示
if [[ -f "$HOME/dotfiles/scripts/start_vcxsrv.sh" ]]; then
    # WSL に割り当てられる IP アドレスを取得して設定
    export DISPLAY="$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0"
    $HOME/dotfiles/scripts/start_vcxsrv.sh
else
    echo "⚠ file 'start_vcxsrv' doesn't exist at ${START_VCXSRV_PATH}" >&2
fi
