#!/usr/bin/env bash
# PostToolUse: .ts/.tsx 編集後に ESLint を実行してフィードバックを返す
# tsc は Stop hook で実行する（まとまった作業完了後）

set -euo pipefail

input="$(cat)"
file="$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || echo "")"

# .ts/.tsx ファイル以外はスキップ
case "$file" in
*.ts | *.tsx) ;;
*) exit 0 ;;
esac

# 編集ファイルのディレクトリから上方に node_modules を探す
project_root=""
dir="$(dirname "$file")"
while [ "$dir" != "/" ]; do
	if [ -x "$dir/node_modules/.bin/eslint" ]; then
		project_root="$dir"
		break
	fi
	dir="$(dirname "$dir")"
done

[ -n "$project_root" ] || exit 0

# ESLint 設定ファイルがない場合はスキップ
has_eslint_config=0
for config_name in .eslintrc .eslintrc.js .eslintrc.cjs .eslintrc.yaml .eslintrc.yml .eslintrc.json eslint.config.js eslint.config.mjs eslint.config.cjs eslint.config.ts; do
	[ -f "$project_root/$config_name" ] && has_eslint_config=1 && break
done
[ "$has_eslint_config" = "1" ] || exit 0

# Stop hook がプロジェクトルートを特定できるようキャッシュ
echo "$project_root" > /tmp/.claude_ts_project_root

diag=""

# --- ESLint: 自動修正 → 残りの違反を収集 ---
"$project_root/node_modules/.bin/eslint" --fix "$file" >/dev/null 2>&1 || true
eslint_out="$("$project_root/node_modules/.bin/eslint" "$file" 2>&1 | head -30)" || true

if [ -n "$eslint_out" ]; then
	diag="${diag}=== ESLint ===
${eslint_out}
"
fi

# エラーがある場合のみ additionalContext として Claude に返す
if [ -n "$diag" ]; then
	jq -Rn --arg msg "$diag" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: $msg
    }
  }'
fi
