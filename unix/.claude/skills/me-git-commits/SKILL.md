---
name: me-git-commits
description: Use when committing staged changes. Splits diff by Conventional Commits category, generates a message per commit, and appends task/project ID from branch name if present.
---

# Claude Commit

Conventional Commits 形式のコミットメッセージを生成し、コミットを実行するスキル。

コミットメッセージは **英語** で、基本的には1行で記述する。

## Conventional Commits

### type prefix

| prefix     | 説明                                                 | 分類 |
| ---------- | ---------------------------------------------------- | ---- |
| `feat`     | 新機能・既存機能の変更                               | A    |
| `fix`      | バグ修正                                             | A    |
| `perf`     | パフォーマンス改善                                   | A    |
| `refactor` | バグ修正でも機能追加でもないコードの変更             | A    |
| `build`    | ビルドシステムや外部依存関係に影響する変更           | A    |
| `ci`       | CI 設定・スクリプトの変更                            | A    |
| `test`     | テストの追加・修正                                   | B    |
| `docs`     | ドキュメントのみの変更                               | B    |
| `style`    | コードの意味に影響しない変更（空白、フォーマット等） | C    |
| `chore`    | その他のメンテナンス                                 | —    |

### range prefix

- 影響範囲が限定できる変更に対して、影響範囲を示す subsystem / package / domain の名称を type prefix に続けて`()`内にを付与する
  - range prefix に記載する名称はシステム内で横断的に使用されていて通じるものである場合のみに付与する
- 3つまでは`,`つなぎでつなげて列挙してよく、それ以上になる場合は range prefix 自体を書かない

例）`fix(web,admin)`

## ワークフロー

### 1. 差分を確認してコミット方針を決める

```bash
git diff --cached  # ステージ済み
git diff           # 未ステージ
```

- **ステージ済みの変更がある場合**: そのままコミットメッセージを生成してコミット（ステップ2へ）
- **ステージ済みの変更がない場合**: 未ステージの変更を以下の方針で分割し、`git add` → コミットを繰り返す
  - 分類Aの変更を1コミット1トピックで分割する
  - 分類Bの変更は関連する分類Aのコミットにまとめる。Bのみの場合は単独コミット
  - 分類Cの変更は原則として関連コミットに含める。フォーマッタ設定や純粋なフォーマット変更のみなら単独コミット
  - どれにも当てはまらない変更は `chore` でまとめる

### 2. コミットを実行

ブランチ名に `/` が含まれる場合、prefix（`/` より前の部分）を取得し、英字と数字の両方を含む場合のみ ID として扱う（例: `PJ-123/add-feature` → `PJ-123`）:

```bash
git symbolic-ref --short HEAD | sed 's|/.*||'
```

ID と判断した場合は2行目に付与してコミットする:

```bash
# ID が含まれる場合
git commit -m "<生成したメッセージ>" -m "<ID>"

# ID が含まれない場合
git commit -m "<生成したメッセージ>"
```
