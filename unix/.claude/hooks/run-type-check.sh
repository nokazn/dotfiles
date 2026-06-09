#!/usr/bin/env bash
# Stop hook: まとまった作業完了時に tsc --noEmit で型チェックを実行する

set -euo pipefail

input="$(cat)"
stop_hook_active="$(echo "$input" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")"

# Stop hook 自身が再帰的に呼ばれた場合はスキップ
if [ "$stop_hook_active" = "true" ]; then
	exit 0
fi

# $PWD から上方に node_modules を探す
project_root=""
dir="$PWD"
while [ "$dir" != "/" ]; do
	if [ -x "$dir/node_modules/.bin/tsc" ]; then
		project_root="$dir"
		break
	fi
	dir="$(dirname "$dir")"
done

# 見つからない場合は PostToolUse hook がキャッシュしたルートを使う
if [ -z "$project_root" ] && [ -f /tmp/.claude_ts_project_root ]; then
	cached="$(cat /tmp/.claude_ts_project_root)"
	if [ -x "$cached/node_modules/.bin/tsc" ]; then
		project_root="$cached"
	fi
fi

[ -n "$project_root" ] || exit 0

# tsconfig.json がない場合はスキップ
[ -f "$project_root/tsconfig.json" ] || exit 0

tsc_out="$(cd "$project_root" && node_modules/.bin/tsc --noEmit 2>&1)" || true

[ -n "$tsc_out" ] || exit 0

errors="$(echo "$tsc_out" | grep -E '\.tsx?\([0-9]+,[0-9]+\): error TS')" || true

[ -n "$errors" ] || exit 0

changed_files="$(git diff --name-only HEAD 2>/dev/null || true)"

if [ -n "$changed_files" ]; then
	pattern="$(echo "$changed_files" | sed 's/[.[\*^$()+?{}|]/\\&/g' | paste -sd'|' -)"
	mine="$(echo "$errors" | grep -E "^($pattern)" | head -50)" || true
	others="$(echo "$errors" | grep -vE "^($pattern)" | head -10)" || true
else
	mine=""
	others="$(echo "$errors" | head -10)"
fi

if [ -n "$others" ]; then
	echo "[tsc] 変更外ファイルの型エラー (修正不要):" >&2
	echo "$others" | head -10 >&2
fi

if [ -n "$mine" ]; then
	jq -Rn --arg msg "$mine" '{
    decision: "block",
    reason: ("tsc --noEmit で、変更したファイルに型エラーが検出されました。このセッションの変更によるものであれば、修正してください:\n\n" + $msg)
  }'
	exit 0
fi
