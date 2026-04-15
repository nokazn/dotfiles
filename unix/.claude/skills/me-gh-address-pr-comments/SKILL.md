---
name: me-gh-address-pr-comments
description: Use when the user wants to fetch GitHub PR review comments and address them. Fetches inline code review comments and general PR comments using gh CLI, evaluates each comment, fixes definitive issues, and handles opinion-based suggestions (imo/nit/consider) by judging validity before acting.
disable-model-invocation: true
---

# gh-address-pr-comments

PR レビューコメントを取得し、指摘を評価・修正するワークフロー。

## コメントの取得

```bash
# インラインレビューコメント（コード行への指摘）
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments

# 一般PRコメント（会話スレッド）
gh api repos/{owner}/{repo}/issues/{pr_number}/comments

# レビュー一覧（CHANGES_REQUESTED / APPROVED など）
gh pr view {pr_number} --json reviews,comments,url,title
```

`{owner}`, `{repo}` はカレントリポジトリから自動補完される。PR番号未指定の場合は現在のブランチから取得:

```bash
gh pr view --json number,reviews,comments
```

## コメントの分類

取得したコメントを以下の基準で分類する:

| 種別 | シグナル | 対応 |
|------|---------|------|
| **必須修正** | bug / error / wrong / must / should / broken / security | 必ず修正 |
| **意見系 (imo)** | imo / nit / optional / consider / maybe / perhaps / could / might / I think / in my opinion / personal preference / 〜じゃないかな / 個人的に | 妥当性を評価してから判断 |
| **質問** | ? / why / what / how | 実装意図を説明するか修正 |

## 処理フロー

```
FOR each comment:
  IF 意見系キーワードを含む (imo/nit/consider 等):
    → [意見系コメントの処理] へ
  ELSE IF CHANGES_REQUESTED レビューの指摘:
    → 修正する
  ELSE:
    → 技術的に正当か確認後、修正する
```

### 意見系コメントの処理

```
1. コードベースの文脈で技術的妥当性を評価する
  - 既存パターンと一致しているか？
  - パフォーマンス / 可読性 / 保守性に明確なメリットがあるか？
  - プロジェクトの規約 / スタイルガイドに沿っているか？

2. 妥当と判断できる場合:
  → 修正する

3. 判断が難しい場合 (主観的 / トレードオフがある / コンテキスト不足):
  → 修正を保留し、ユーザーに判断を委ねる
  → 以下を報告:
      - コメント内容
      - 修正した場合・しない場合それぞれのトレードオフ
      - 推奨案（あれば）
```

## 修正の進め方

1. **1コメントずつ対応する** — バッチ処理しない
2. **修正前にファイルを読む** — 変更箇所の文脈を確認する
3. **テストを実行する** — 修正が既存の動作を壊さないか確認する
4. **完了後に報告する** — 何を修正したか・何を保留したかを明示し、ユーザーに問題ないか確認する
5. **リモートブランチにpushする** — `git ps`でプッシュする
6. **GitHub 上のコメントで対応内容を reviewer に知らせる** — どのコミットで対応したかをコメントに残す

## 報告のフォーマット

作業完了後、以下の形式でユーザーに報告する:

```
## 対応済み
- [ファイル:行] コメント概要 → 対応内容

## ユーザー判断が必要なコメント
- [ファイル:行] コメント内容
  - 修正する場合: ...
  - 修正しない場合: ...
  - 推奨: （あれば）
```

## コメントのフォーマット

報告内容が問題ないとユーザーに判断され push した後、と指摘のインラインコメントに返信する。

```sh
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies -f body="📝 `<commit hash>` で対応"
```

## 注意事項

- resolved済みのコメントは `in_reply_to_id` や `position: null` で判別できる場合がある。すでに対応済みのコメントはスキップする
