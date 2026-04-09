---
name: claude-commit
description: Claude Haiku でステージ済みの差分から Conventional Commits 形式のコミットメッセージを自動生成してコミットする。`git cm-claude` / `git cmb-claude` 相当の操作をしたいとき、またはユーザーが「Claude でコミットメッセージを生成して」「AI でコミットして」と言ったときに使う。ブランチ prefix を2行目に追加する cmb モードにも対応。
---

# Claude Commit

Claude Haiku を使ってステージ済み差分から Conventional Commits 形式のコミットメッセージを生成し、コミットを実行するスキル。

## ワークフロー

### 1. ステージ済み差分を取得

```bash
git diff --cached
```

差分が空の場合はユーザーに `git add` するよう伝えて終了する。

### 2. コミットメッセージを生成

以下のプロンプトで Claude Haiku に生成させる（コマンドライン経由ではなく、自分自身が直接生成する）:

**プロンプト指示:**
- Conventional Commits のプレフィックス（`feat:`, `fix:`, `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`）で始まる1行の英語メッセージを生成する
- バグ修正が含まれる場合は `fix:`、新機能・既存機能の変更には `feat:` を優先する
- 説明・マークダウン・余分なテキストは含めない（1行のみ出力）

### 3. コミットを実行

**cm モード**（ブランチ prefix なし）:
```bash
git commit -m "<生成したメッセージ>"
```

**cmb モード**（ブランチ prefix を2行目に付与）:
```bash
git commit -m "<生成したメッセージ>" -m "$(git symbolic-ref --short HEAD | sed 's|/.*||')"
```

## モードの選択

- ユーザーが「ブランチ名を入れて」「cmb で」と言った場合 → cmb モード
- それ以外 → cm モード（デフォルト）

## 注意事項

- GPG 署名が有効な環境では署名もそのまま行われる
