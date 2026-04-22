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

tsc_out="$(cd "$project_root" && node_modules/.bin/tsc --noEmit 2>&1 | head -50)" || true

if [ -n "$tsc_out" ]; then
	jq -Rn --arg msg "$tsc_out" '{
    decision: "block",
    reason: ("tsc --noEmit で型チェックエラーが検出されました。以下のエラーを修正してください:\n\n" + $msg)
  }'
	# 再度修正させるために0を返す
	exit 0
fi
