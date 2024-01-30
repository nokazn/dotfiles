#!/usr/bin/env bash
#!/usr/bin/env bash

set -e -o pipefail

readonly PATH_SCRIPT=~/.path.sh
readonly TOOL_VERSIONS=~/.tool-versions

function plugin-add-if-not() {
  if ! asdf plugin list | grep "$1" -q; then
    asdf plugin add "$1"
    echo "✅ $1 plugin has been added successfully!"
  fi
  return 0
}

# @param {string} - asdfでのパッケージ名
# @return {0}
function plugin-add() {
  # asdf を使えるようにする
  source ${PATH_SCRIPT}
  local plugins="$1"
  if [[ -z "$plugins" ]]; then
    plugins="$(
      cat ${TOOL_VERSIONS} | awk '{ print $1 }'
    )"
  fi

  xargs -I {} sh -c "plugin-add-if-not {}" <<<"$plugins"

  return 0
}

export -f plugin-add-if-not
plugin-add "$1"
