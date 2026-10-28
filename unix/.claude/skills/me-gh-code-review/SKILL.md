---
name: me-gh-code-review
description: GitHub の PR をレビューし、ask / must / should / better / imo / nits（必要に応じて security を付加）のラベル付きインラインコメントを、submit せず pending review（下書き）として追加する。ユーザーが内容を確認して OK を出してから、REQUEST_CHANGES / COMMENT / APPROVE のいずれかで submit する。「この PR レビューして」「#123 見て」「レビューコメント付けて」「PR の URL を渡されてレビューを頼まれた」ときに使う。自分の PR のセルフレビューを頼まれた場合も使う。
---

# gh-code-review

PR をレビューし、コメントを下書きとして積んでから、ユーザーの承認を得て submit するワークフロー。
submit すると作者に通知が飛び、取り消せない。だから下書きの段階でユーザーに見てもらう。

コメントのラベルは [references/review-labels.md](references/review-labels.md) に従う。レビューを始める前に読む。

## 1. PR を把握する

PR 番号・URL が渡されなければ、現在のブランチの PR を対象にする。

```bash
gh pr view <pr> --json number,url,title,body,author,baseRefName,headRefName,headRefOid,closingIssuesReferences,reviews
gh pr diff <pr>
gh api repos/{owner}/{repo}/pulls/<pr>/comments   # 既存のインラインコメント
gh api user --jq .login                            # 自分のログイン名
```

- 仕様は PR 本文と `closingIssuesReferences` の issue から読み取る。ここで分からない仕様は、レビューで `ask` にする根拠になる。
- 既存のコメントと同じ指摘は重ねない。
- 差分だけで判断できないときは、周辺のコードを読む。ローカルにリポジトリがあれば `git fetch origin pull/<pr>/head` してから `git show FETCH_HEAD:<path>` で読む。作業ツリーは切り替えない。

## 2. レビューする

差分の各変更について、バグ・仕様との整合・セキュリティ・UI/UX・規約・保守性の順に見る。
リポジトリに規約（`CLAUDE.md`、`CONTRIBUTING.md`、lint 設定、`tcj-*-coding-guidelines` などのスキル）があれば、それを基準にする。

指摘ごとにラベルを1つ選ぶ（`security` は付加）。コメント本文は次のように書く。

- 1コメント1指摘。何が問題で、どうすると良いかを書く。根拠（再現条件、規約の該当箇所）があれば添える。
- 小さく具体的な修正案は ```` ```suggestion ```` ブロックで示す。作者がそのまま取り込める。
- PR 本文やコードと同じ言語で書く。
- 問題が見つからなかった観点を列挙しない。コメントは指摘だけにする。

## 3. 下書き（pending review）として追加する

`event` を指定せずにレビューを作ると、submit されない pending review になる。pending の内容は自分にしか見えない。

先に、自分の pending review がすでにないか確かめる。pending review は1つの PR につき1人1つしか作れない。

```bash
gh api repos/{owner}/{repo}/pulls/<pr>/reviews \
  --jq '.[] | select(.state == "PENDING") | {id, user: .user.login}'
```

自分の pending review があれば、ユーザーに「既存の下書きを削除して作り直すか、そのまま見るか」を聞く。黙って削除しない。

コメントを JSON で組み立てて作成する。`line` は変更後のファイルの行番号で、diff の hunk に含まれる行しか指定できない。
hunk 外の指摘や PR 全体への指摘は、`body` にまとめる。

```bash
gh api repos/{owner}/{repo}/pulls/<pr>/reviews --method POST --input - <<'EOF'
{
  "commit_id": "<headRefOid>",
  "body": "",
  "comments": [
    { "path": "src/foo.ts", "line": 42, "side": "RIGHT", "body": "[should] ..." },
    { "path": "src/bar.ts", "start_line": 10, "line": 14, "side": "RIGHT", "body": "[nits] ..." }
  ]
}
EOF
```

## 4. ユーザーに確認してもらう

追加したコメントを、重いラベル順（must → should → ask → better → imo → nits）に一覧にして見せる。
PR の URL も添え、GitHub の Files changed タブで下書きを直接確認できることを伝える。

```
| ラベル | 場所 | 指摘 |
|---|---|---|
| must, security | src/api.ts:42 | ユーザー入力を SQL に直接埋め込んでいる |
| should | src/list.tsx:18 | 0 件のとき例外になる |
```

あわせて submit の種類を提案する。

- `must` がある → `REQUEST_CHANGES`
- `must` はないが指摘がある → `COMMENT`
- 指摘がない → `APPROVE`
- 自分の PR → `COMMENT` しか選べない

修正を頼まれたら、下書きのコメントを直接編集・削除する。

```bash
gh api repos/{owner}/{repo}/pulls/<pr>/reviews/<review_id>/comments --jq '.[] | {id, path, line, body}'
gh api repos/{owner}/{repo}/pulls/comments/<comment_id> --method PATCH -f body="..."
gh api repos/{owner}/{repo}/pulls/comments/<comment_id> --method DELETE
```

## 5. submit する

ユーザーが submit の種類を含めて明示的に OK を出してから実行する。「内容は良さそう」のような感想は submit の許可として扱わず、種類を確認する。

```bash
gh api repos/{owner}/{repo}/pulls/<pr>/reviews/<review_id>/events --method POST \
  -f event=<REQUEST_CHANGES|COMMENT|APPROVE> -f body="<全体コメント>"
```

`REQUEST_CHANGES` と `COMMENT` は `body` が必須なので、指摘の件数と主な must / should を1〜2行でまとめて書く。

submit 後、レビューの URL を返す。
