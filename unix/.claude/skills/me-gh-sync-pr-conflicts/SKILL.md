---
name: me-gh-sync-pr-conflicts
description: 自分の open な PR のうち、ベースブランチと conflict しているものを最新化して解消する。ベースが default branch でない PR（積み上げ PR）は、親から順に解消する。定期実行（1日1回）のほか、「自分の PR の conflict を直して」「PR を最新化して」と頼まれたときに使う。
---

# gh-sync-pr-conflicts

自分の PR を、ベースブランチの最新に追従させる。
この skill を呼んだこと自体が、merge と push の指示になる。ユーザーへの確認は挟まない。

## 対象

```bash
gh pr list --author @me --state open --json number,headRefName,baseRefName,mergeStateStatus
```

`mergeStateStatus` が `DIRTY`（conflict あり）の PR が対象。
`baseRefName` が default branch でない PR は、親の PR（`headRefName` が自分の `baseRefName` と一致するもの）を先に処理する。
親を更新したら、conflict の有無にかかわらず、その子も親の新しい先頭を取り込む。

## 方針

- 最新化は **merge**。rebase はしない（`pull.rebase = false` で運用しているため）。
- push は `git ps`。force push はしない。
- conflict を解消したら、`git ac` で conflict マーカーの残りを検出しながら stage する。
- 作業ツリーに未コミットの変更があるときは、その checkout では作業しない。`git worktree add` で別の作業場所を作る。

## 止める条件

次のどれかに当たった PR は、`git merge --abort` して push せず、報告に回す。その PR の子も処理しない。

- conflict の解消に、仕様や意図の判断が要る（どちらの変更を残すか決められない）
- 解消後に、そのリポジトリのテストや lint が落ちる

推測で解消して push するより、止めて報告するほうを優先する。

## 報告

```
## 最新化した PR
- #<number> <title> — <base> を取り込み（conflict: あり/なし）

## 止めた PR
- #<number> <title> — <理由>、conflict しているファイル
```
