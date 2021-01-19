#!/bin/bash

readonly CURRENT_DIR=$(cd $(dirname ${0}); pwd)
readonly CONFIG_PATH="${CURRENT_DIR}/../windows/config.xlaunch"

# @param - none
# @return {void}
function start_vcxsrv() {
  # WSL 内では X Server 経由で GUI を表示
  if type wsl.exe > /dev/null 2>&1; then
    # 実行中のプロセス一覧から vcxsrv を抽出した結果が空文字列で、config_path が存在する場合
    if [[ -z "$(tasklist.exe | grep vcxsrv)" ]]; then
      if [[ -f "${CONFIG_PATH}" ]]; then
        # wsl 内のパスを windows で有効なパスに変換してコマンドプロンプトから xlaunch を実行
        # TODO: UNC path are not supported. と出力される
        cmd.exe /c $(wslpath -w ${CONFIG_PATH})
      else
        echo "⚠ file 'config.xlaunch' doesn't exist at ${CONFIG_PATH}" >&2
      fi
    fi
  fi
  return 0
}

start_vcxsrv
