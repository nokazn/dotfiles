#!/bin/bash

current_dir=$(cd $(dirname ${0}); pwd)

function init_vcxsrv {
  # WSL 内では X Server 経由で GUI を表示
  if type wsl.exe > /dev/null 2>&1; then
      config_path="${current_dir}/windows/config.xlaunch"
      # 実行中のプロセス一覧から vcxsrv を抽出した結果が空文字列で、config_path が存在する場合
      if [ -z "$(tasklist.exe | grep vcxsrv)" ] && [ -f "${config_path}" ]; then
          # wsl 内のパスを windows で有効なパスに変換してコマンドプロンプトから xlaunch を実行
          # TODO: unc path are not supported と出力される
          cmd.exe /c $(wslpath -w ${config_path})
      fi
  fi
}

init_vcxsrv
