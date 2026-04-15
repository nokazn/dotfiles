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

どのディレクトリにいても問題ないよう、リポジトリのルートを基準にした絶対パスで探索する。

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
ls "$REPO_ROOT/.github/pull_request_template.md" \
   "$REPO_ROOT/.github/PULL_REQUEST_TEMPLATE.md" \
   "$REPO_ROOT/.github/PULL_REQUEST_TEMPLATE/" \
   "$REPO_ROOT/docs/pull_request_template.md" \
   "$REPO_ROOT/pull_request_template.md" 2>/dev/null
```

`.github/PULL_REQUEST_TEMPLATE/` のように複数テンプレートが存在する場合は中身を確認し、変更内容に最も近いものを選ぶ。選定に迷う場合はユーザーに確認する。

### 3. 本文を生成

#### テンプレートがある場合

テンプレートの構造・項目を**そのまま**維持し、各セクションを差分・コミット履歴をもとに簡潔に埋める。

テンプレートに以下の必須項目で欠けているものだけを末尾に追加する:

- やったこと
- やらないこと
- Why・背景
- Before/After
  - 画面変更時のみ記載し、スクリーンショットを載せる
  `/screenshot` skillを使用して storybook や実際の画面のスクリーンショットを取得する
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

upstream が未設定の場合のみ実行する。`--no-verify` などフックをスキップするフラグは使わない。

```bash
git push -u origin HEAD
```

### 5. PR を作成/更新

PR が未作成の場合、PRを作成する。
特に指定がない場合はDraftとして作成する。
ブランチ名の `/` より前が英数混在の場合は ID として扱い、簡潔に記載したタイトルの先頭に `[ID] ` のように記載する（例: `PJ-123/add-feature` → `[PJ-123]`）:

```bash
git symbolic-ref --short HEAD | sed 's|/.*||'
```

PR 作成は heredoc で本文を渡す。**シングルクォート付き heredoc (`<<'EOF'`) を使う**ので、本文中のバッククォートは**エスケープせずそのまま書く**。誤って `\` でエスケープすると、リテラルの `\` が出力に残り、GitHub 上で code 表示にならない:

```bash
gh pr create --base <base> --title "<title>" --body "$(cat <<'EOF'
<本文>
EOF
)"
```

良い例: `` `foo.ts` を編集 `` → GitHub 上で `foo.ts` が code 表示
悪い例: `` \`foo.ts\` を編集 `` → GitHub 上で `\foo.ts\` と表示される

PRが作成済みの場合は、`gh pr edit` で不足している内容を更新する。

作成/更新後、PR の URL を返す。

## 記述スタイル

- **簡潔さを最優先**にする。1 bullet = 1行で完結させ、複数行の説明文や段落を書かない。レビュー時の読み込み負荷を下げ、PR本文がコードレビューの邪魔にならないようにするため。
- 括弧での補足（`（〇〇のため）`、`（後続タスクで対応）` 等）を入れない。理由は Why 節に集約し、本文の bullet には入れない。括弧で補足したくなった時は、その情報が本当に必要かまず疑う。
- 「コードを読めばわかる」内容を本文で繰り返さない。**Why** と **確認方法** に文字数を割く。
- 該当のないセクションは見出しを残し、本文は「なし」と記載する。テンプレートとの整合性のため。テンプレートに書かれていた雛形（例: 空のテーブル、途中の箇条書きのような雛形）は **そのまま残さず削除** して「なし」に置き換える。
- 「観点」は `- [ ] ` のチェックボックスで列挙し、レビュー時にチェック可能にする。
- スクリーンショットが必要だが用意できない場合は `<!-- TODO: スクリーンショット -->` を残してユーザーに依頼する。

良い例:
```
### やったこと
- Form 型を salepoint モジュールに分離
- entity-components/store を salepoint にリネーム
```

悪い例（長文・括弧補足・小見出し追加）:
```
### やったこと

#### 1. salepoint モジュールの新設
- domain/entities/store/ のうち salepoint 登録（フォーム・検証・変換）に関わるものを domain/entities/salepoint/ として独立モジュールに分離
   - 移設対象: Form* 型、DISTRIBUTION_REGION_TYPES 系定数（OpenAPI の salepoints エンドポイントとして概念が分かれているため）
```
