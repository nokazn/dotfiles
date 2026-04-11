---
name: shell-script
description: Use when writing or editing shell scripts (.sh files). Provides conventions for shebang, safety options, variable declarations, and Bash idioms used in this repository.
---

# Shell Script Guidelines

## 必須ヘッダー

すべての .sh ファイルに以下を先頭に記述する:

```bash
#!/usr/bin/env bash

set -euo pipefail
```

## 変数宣言

```bash
# グローバル定数
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ローカル変数（関数内）
local -r name="value"   # 読み取り専用
local name="value"      # 変更可能
```

## Bash イディオム

```bash
# 条件分岐: [ ] ではなく [[ ]] を使う
[[ -n "$var" ]] && echo "not empty"
[[ "$path" == *.sh ]] && shellcheck "$path"

# コマンド置換: バッククォートではなく "$()" を使う
result="$(command arg)"

# スクリプトのディレクトリ取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# stdin からの読み取り（pipe 対応）
while IFS= read -r line; do
  echo "$line"
done
```

## 関数

```bash
# @param {string} - 引数の説明
# @return {void}
function my_function() {
  local -r input="$1"
  # ...
  return 0
}
```

- 関数名はスネークケース
- 変数は必ずクォート: `"$var"` (グロブ展開・単語分割を防ぐ)

## エラー処理

```bash
# コマンドの存在チェック
if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

# ファイルの存在チェック
[[ -f "$file" ]] || { echo "File not found: $file" >&2; exit 1; }
```

## Lint

ファイル保存時に shellcheck が自動実行される（`~/.claude/hooks/shellcheck-on-save.sh`）。
手動実行: `shellcheck <file>.sh`
