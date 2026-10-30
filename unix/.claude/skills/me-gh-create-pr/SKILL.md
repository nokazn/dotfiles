---
name: me-gh-create-pr
description: Use when the user wants to open a GitHub pull request with `gh pr create`. Inspects the repository for a PR template under `.github/` and follows it when present; otherwise falls back to a Japanese default template (やったこと / やらないこと / Why・背景 / Before/After / 確認URL / 確認方法 / 観点 / 補足). Keeps each section concise instead of explanatory. For UI changes, captures before/after screenshots and attaches them side by side with `gh --attach`; when verification needs specific data, includes the SQL or scripts to prepare it in a collapsed details block.
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
  - 機能の追加・改修の場合 → 細かいファイルや関数・メソッドの内容までは書かず、ユーザーから見た機能の差分を完結に記載する
  - リファクタの場合 → 整理した内容を書き、必要によってはファイルや関数・メソッドの整理内容も記載する
- やらないこと
- Why・背景
  - AI エージェントで開発した場合は、ユーザー（人間）が判断したことと根拠を表にまとめる（後述の「人間の判断の載せ方」）
- Before/After
  - 画面変更時のみ記載し、base ブランチと現在のブランチのスクリーンショットを表で横に並べる（後述の「Before/After のスクリーンショット」）
- 確認URL
- 確認方法
  - 確認に特定のデータが要る場合は、抽出・作成する SQL やスクリプトを `<details>` に入れて載せる（後述の「テストデータの載せ方」）
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

| 判断 | 根拠 |
| --- | --- |
| ... | ... |

## Before/After

| Before | After |
| --- | --- |
| ![before](./before-list.png) | ![after](./after-list.png) |

## 確認URL

- ...

## 確認方法

1. ...

<details>
<summary>テストデータ</summary>

```sql
...
```

</details>

## 観点

- [ ] ...
- [ ] ...

## 補足

...
```

#### 人間の判断の載せ方

AI エージェントで開発した PR では、どの選択が人間の意図でどれが AI の既定の選択かを、レビュアーがコードから見分けられない。
人間が判断したことを Why・背景の表に残し、レビュアーが「意図した選択」と「見直してよい選択」を区別できるようにする。

- 載せるのは、ユーザーが選んだ・決めた・却下したこと。仕様の解釈、スコープの線引き、設計案の選択、受け入れたトレードオフ、AI の提案を退けたことなど。会話の中でユーザーが答えた質問や、ユーザーによる修正指示から拾う。
- AI が自分で決めたことは載せない。
- 根拠はユーザーが述べた理由を1行で書く。理由が述べられていなければ推測で埋めず、ユーザーに聞く。
- AI エージェントを使っていない場合は表を作らない。使ったが人間の判断がない場合は、見落としがないかユーザーに確認する。

#### Before/After のスクリーンショット

レビュアーが差分を一目で比べられるよう、同じ画面・同じ状態の Before と After を並べる。

1. 撮影対象を差分から決める。変更したコンポーネントの storybook か、そのコンポーネントを使う実際の画面。
2. Before は base ブランチで撮る。作業ツリーを切り替えずに済むよう `git worktree add <tmp-dir> origin/<base>` で別の作業ツリーを作り、そこで dev server や storybook を起動する。
3. After は現在のブランチで撮る。ビューポート・ログインユーザー・表示データを Before とそろえないと、変更以外の差分が混ざる。
4. `/screenshot` skill や `/playwright` skill で撮り、PR 本文と同じ一時ディレクトリに `before-<画面名>.png` / `after-<画面名>.png` として保存する。
5. 本文では上の表のようにローカルパスで参照する。`gh pr create/edit --attach` がアップロードして GitHub 上の URL に書き換える。

`--attach` は gh v2.99.0 以降で使え、リポジトリへの push 権限が要る。
`gh --version` が古い、または撮影できない画面（外部サービス連携や本番データが必要など）の場合は、表のセルに `<!-- TODO: スクリーンショット -->` を残してユーザーに依頼する。
作った worktree とスクリーンショットは、PR 作成後にユーザーに確認してから削除する。

#### テストデータの載せ方

確認方法に「この状態のアカウントで」「このデータがあるとき」のような前提があるなら、レビュアーがそのデータを用意できるよう SQL やスクリプトを載せる。
長くなりやすく本文の流れを妨げるので、`<details>` に入れて折りたたむ。

- 既存データから条件に合うものを探す抽出クエリを優先し、ない場合に作成用の INSERT やスクリプトを書く。既存データを書き換える UPDATE は、元に戻す手順も添える。
- 対象環境（ローカル / 開発環境など）を `<summary>` か直前の手順に書く。本番環境で実行する前提のものは載せない。
- 実在の個人情報・認証情報・本番の ID は入れない。値はダミーにするか、抽出クエリで取得させる。
- `<summary>` の後とコードブロックの前後には空行を入れる。空行がないと GitHub 上でコードブロックとして表示されない。

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
gh pr create --base <base> --title "<title>" --assignee @me --body "$(cat <<'EOF'
<本文>
EOF
)"
```

良い例: `` `foo.ts` を編集 `` → GitHub 上で `foo.ts` が code 表示
悪い例: ``\`foo.ts\` を編集`` → GitHub 上で `\foo.ts\` と表示される

スクリーンショットを添付する場合は、本文をスクリーンショットと同じディレクトリのファイルに書き出し、`--body-file` と `--attach` で渡す。
`--body-file` 内の相対パスはそのファイルのディレクトリを基準に解決されるため。

```bash
gh pr create --base <base> --title "<title>" --assignee @me \
  --body-file <tmp-dir>/body.md \
  --attach <tmp-dir>/before-list.png --attach <tmp-dir>/after-list.png
```

一部の添付だけ失敗した場合、PR は成功した分だけで作成され、コマンドは非 0 で終了する。失敗したファイルは `gh pr edit --body-file ... --attach ...` で付け直す。

PRが作成済みの場合は、`gh pr edit` で不足している内容の更新、古くなっている説明の更新・削除を行う。

作成/更新後、PR の URL を返す。

## 記述スタイル

- **簡潔さを最優先**にする。読み手の負荷を下げるため、1 bullet = 1行で完結させ、複数行の説明文や段落を書かない。
- 括弧での補足（`（〇〇のため）`、`（後続タスクで対応）` 等）を入れない。理由は Why 節に集約し、本文の bullet には入れない。括弧で補足したくなった時は、その情報が本当に必要かまず疑う。
- 「コードを読めばわかる」内容を本文で繰り返さない。特に具体的な変数名やファイル名、項目名を用いた説明は不要。ユーザー視点から見た変更点を中心に記載する。
- 該当のないセクションは見出しを残し、本文は「なし」と記載する。テンプレートとの整合性のため。テンプレートに書かれていた雛形（例: 空のテーブル、途中の箇条書きのような雛形）は **そのまま残さず削除** して「なし」に置き換える。
- 「観点」は `- [ ] ` のチェックボックスで列挙し、レビュー時にチェック可能にする。

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
