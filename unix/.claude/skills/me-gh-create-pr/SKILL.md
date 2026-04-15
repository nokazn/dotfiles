---
name: me-gh-create-pr
description: Use when the user wants to open a GitHub pull request with `gh pr create`. Inspects the repository for a PR template under `.github/` and follows it when present; otherwise falls back to a Japanese default template (やったこと / やらないこと / Why・背景 / Before/After / 確認URL / 確認方法 / 観点 / 補足). Keeps each section concise instead of explanatory.
disable-model-invocation: true
---

# gh-create-pr

`gh pr create` で GitHub PR を作成するワークフロー。

## ワークフロー

### 1. 状態確認

以下を並列で実行する:

```bash
git status
git rev-parse --abbrev-ref HEAD                                # 現在ブランチ
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null # upstream の有無
gh pr view --json number,url 2>/dev/null                        # 既存PRの有無
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name # base 候補
```

base ブランチを特定したら、差分とコミット履歴を確認する:

```bash
git fetch origin <base>
git diff origin/<base>...HEAD
git log origin/<base>..HEAD --oneline
```

### 2. テンプレートを探す

優先度順に探索する:

```bash
ls .github/pull_request_template.md \
   .github/PULL_REQUEST_TEMPLATE.md \
   .github/PULL_REQUEST_TEMPLATE/ \
   docs/pull_request_template.md \
   pull_request_template.md 2>/dev/null
```

`.github/PULL_REQUEST_TEMPLATE/` のように複数テンプレートが存在する場合は中身を確認し、変更内容に最も近いものを選ぶ。選定に迷う場合はユーザーに確認する。

### 3. 本文を生成

#### テンプレートがある場合

テンプレートの構造を**そのまま維持**し、各セクションを差分・コミット履歴をもとに簡潔に埋める。テンプレートに以下の必須項目で**欠けているもの**だけを末尾に追加する:

- やったこと
- やらないこと
- Why・背景
- Before/After（画面変更時のみ記載し、スクリーンショットを載せる。`/screenshot` skillを使用して storybook や実際の画面のスクリーンショットを取得する。）
- 確認URL
- 確認方法
- 観点
- 補足

#### テンプレートがない場合

以下のフォーマットで本文を生成する:

```markdown
## やったこと
- ...

## やらないこと
- ...

## Why・背景
...

## Before/After
<!-- 画面が変更された場合のみスクリーンショットを貼る -->

## 確認URL
- ...

## 確認方法
1. ...

## 観点
- [ ] ...
- [ ] ...

## 補足
...
```

### 4. リモートへ push

upstream が未設定の場合のみ実行する:

```bash
git push -u origin HEAD
```

### 5. PR を作成

タイトルは Conventional Commits 形式・70文字以下にする。ブランチ名の `/` より前が英数混在の場合は ID として扱い、本文末尾の参照行に追加する（例: `PJ-123/add-feature` → `PJ-123`）:

```bash
git symbolic-ref --short HEAD | sed 's|/.*||'
```

PR 作成は heredoc で本文を渡す:

```bash
gh pr create --base <base> --title "<title>" --body "$(cat <<'EOF'
<本文>
EOF
)"
```

作成後、PR の URL を返す。

## 記述スタイル

- **簡潔さを最優先**にする。1項目あたり 1〜数行。
- 「コードを読めばわかる」内容を本文で繰り返さない。**Why** と **確認方法** に文字数を割く。
- 該当のないセクション（例: やらないこと / 補足）は削除せず「なし」と記載する。テンプレートとの整合性のため。
- 「観点」は `- [ ] ` のチェックボックスで列挙し、レビュー時にチェック可能にする。
- スクリーンショットが必要だが用意できない場合は `<!-- TODO: スクリーンショット -->` を残してユーザーに依頼する。

## 注意事項

- `--no-verify` などフックをスキップするフラグは使わない。
- 既に同じブランチに PR が存在する場合、新規作成せず `gh pr edit` での更新を提案する。
- `main` / `master` を base 以外で扱うことはしない。base が不明な場合はユーザーに確認する。
- ドラフト指定が必要かはユーザーに確認する（指示がなければ通常 PR で作成）。
