#!/usr/bin/env bash

set -eu -o pipefail

readonly ELM_PATH=~/.local/bin.elm

# @param None
# @return {void}
function uninstall_elm() {
  if ! type "elm" >/dev/null 2>&1; then
    echo "❌ Elm doesn't exist at '${ELM_PATH}'."
    return 0
  fi

  echo "uninstalling Elm ..."
  sudo rm -f ~/.local/bin/elm
  rm -rf ~/.elm
  echo "✅ Elm has been uninstalled successfully from '${ELM_PATH}'."
  return 0
}

uninstall_elm
