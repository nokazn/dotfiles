#!/usr/bin/env bash

set -eu -o pipefail

BASE_DIR=$(cd "$(dirname "${0}")/.."; pwd)
readonly BASE_DIR

# @param - none
# @return {void}
function start_vcxsrv() {
  local -r CONFIG_PATH="${BASE_DIR}/windows/config.xlaunch"
  local -r WIN32_PATH=/mnt/c/Windows/system32/

  # WSL 内では X Server 経由で GUI を表示
  if type wslsys >/dev/null 2>&1; then
    # 実行中のプロセス一覧から vcxsrv を抽出した結果が0件で、config_path が存在する場合
    if (( $("${WIN32_PATH}/tasklist.exe" | grep -c "vcxsrv") == 0 )); then
      if [[ -f "${CONFIG_PATH}" ]]; then
        # wsl 内のパスを windows で有効なパスに変換してコマンドプロンプトから xlaunch を実行
        cd /mnt/c
        "${WIN32_PATH}/cmd.exe" /c "$(wslpath -w "${CONFIG_PATH}")"
        cd "$OLDPWD"
      else
        echo "⚠ file 'config.xlaunch' doesn't exist at ${CONFIG_PATH}" >&2
      fi
    fi
  fi
  return 0
}

start_vcxsrv
