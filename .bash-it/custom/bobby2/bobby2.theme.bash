#!/usr/bin/env bash

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" ${green}|"
SCM_THEME_PROMPT_SUFFIX="${green}|"

function git_hash() {
  # TODO: コミットが存在するにもかかわらず hash が取得できないことがある
  local hash=$(git log --pretty=format:'%h' -n 1 2>/dev/null)
  if [[ -n ${hash} ]]; then
    echo "(${hash})"
  else
    echo ""
  fi
}

GIT_THEME_PROMPT_DIRTY=" ${cyan}$(git_hash)${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${cyan}$(git_hash)${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${cyan}["
GIT_THEME_PROMPT_SUFFIX="${cyan}]"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

__bobby_clock() {
  printf "$(clock_prompt) "

  if [ "${THEME_SHOW_CLOCK_CHAR}" == "true" ]; then
    printf "$(clock_char) "
  fi
}

function prompt_command() {
  PS1="\n$(battery_char) $(__bobby_clock)"
  PS1+="${orange}$(ruby_version_prompt) "
  PS1+="${purple}\u@\h"
  PS1+="${reset_color}: "
  PS1+="${bold_white}${background_blue}\w${normal}\n"
  PS1+="${cyan}$(scm_prompt_char_info) "
  PS1+="${reset_color}\$ "
}

THEME_SHOW_CLOCK_CHAR=${THEME_SHOW_CLOCK_CHAR:-"true"}
THEME_CLOCK_CHAR_COLOR=${THEME_CLOCK_CHAR_COLOR:-"$red"}
THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"${yellow}"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%Y-%m-%d %H:%M:%S (%a)"}

safe_append_prompt_command prompt_command
