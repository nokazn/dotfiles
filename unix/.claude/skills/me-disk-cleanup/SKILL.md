---
name: me-disk-cleanup
description: macOS / Linux のディスクを掃除する。tmp の古いファイル・巨大ファイル、npm/yarn/pnpm/bun・Go・Rust(cargo)・pip/uv・Homebrew のキャッシュ、Docker の未使用イメージと build cache、Nix の古い世代、Xcode DerivedData、~/Library/Caches や ~/.cache の古いエントリを、サイズを見せて確認を取ってから削除する。削除対象外でも容量を食っているもの（ランタイムの旧バージョン、Docker volume、worktree、ローカル DB のデータなど）を報告する。「ディスクがいっぱい」「容量を空けたい」「何が容量食ってる？」「キャッシュを消したい」「tmp を掃除して」「docker のイメージを消して」「go clean して」「定期掃除」のような依頼や、No space left on device で作業が止まったときに使う。特定のキャッシュ1つだけを消す依頼でも、使用中ファイルや git の作業を巻き込まない判定が入っているのでこのスキルを使う。
---

# Disk Cleanup

削除の判定と実行は同梱の `scripts/cleanup.ts` に任せる。
自分で `rm -rf` や `find -delete` を組み立てると、使用中のソケットや未コミットの clone を消す事故が起きやすいので、スクリプトにない対象を消すときもまずユーザーに確認する。

スクリプトは bun（mise で管理）で動く。`bun` が見つからなければ、`mise install bun` を実行してよいかユーザーに聞く。

```bash
SCRIPT=~/.claude/skills/me-disk-cleanup/scripts/cleanup.ts
"$SCRIPT" categories             # カテゴリと利用可否
"$SCRIPT" report [category...]   # 削除候補を TSV で出す。何も消さない
"$SCRIPT" run <category...>      # カテゴリ単位で削除
"$SCRIPT" delete-tmp <path...>   # tmp 直下のエントリを個別に削除
```

report の TSV は `category, size_kb, size, target, note` の5列。
`$HOME` 全体を du する `survey` の report は1〜3分かかり、それ以外は合わせて数十秒で終わる。
`report survey` とそれ以外のカテゴリの report を別々の Bash 呼び出しで並列に走らせ、どちらも timeout は 600000 にする。

## 手順

1. `df -h ~` で空き容量を控える（終わったあと比較する）。
2. `report` を実行する。ユーザーがカテゴリを指定していればそのカテゴリだけ、指定がなければ全部。
3. 結果をカテゴリごとに集計して表で見せる（後述）。
4. 消すカテゴリをユーザーに選んでもらう。ユーザーが最初の依頼でカテゴリを名指ししていれば、それが選択なので改めて聞かずに進めてよい。ただし `tmp-review` と `tmp-large` は、名指しされていても1件ずつ確認する。
5. `run` / `delete-tmp` を実行し、もう一度 `df -h ~` を取って空いた量を報告する。失敗したカテゴリ（スクリプトが `run failed` を出す）があれば理由と一緒に伝える。

依頼の言葉とカテゴリの粒度を合わせる。
「使ってないイメージ」なら `docker-image` だけで `docker-build-cache` は含めない。
「go のビルドキャッシュ」なら `go` だけで `go-mod` は含めない。
「/tmp だけ」なら `CLEANUP_TMP_ROOTS=/tmp` を report と run の両方に付ける（既定では `/tmp`, `/var/tmp`, `$TMPDIR` を走査する）。
「でかいものがあったら教えて」なら `CLEANUP_TMP_LARGE_KB=102400`（100MB）くらいまで下げて、最近の大きいものも `tmp-large` に出す。

## カテゴリ

| category | 対象 | 消すと起きること |
|---|---|---|
| `tmp` | tmp 直下で、配下に1日以内に更新されたファイルがないもの | 基本なし |
| `tmp-review` | 上の条件を満たすが、未コミット・未 push の git リポジトリや worktree を含むもの | 作業が失われうる。`run tmp` では消えない |
| `tmp-large` | 1日以内に更新されているが 1GB 以上のもの | 実行中の作業の成果物かもしれない。`run tmp` では消えない |
| `npm` / `yarn` / `pnpm` / `bun` | パッケージマネージャのキャッシュ（pnpm は参照されていないものだけ） | 次回 install で再ダウンロード |
| `go` | ビルドキャッシュとテストキャッシュ | 次回ビルドが遅くなる |
| `go-mod` | モジュールキャッシュ | 全モジュールを再ダウンロード。オフラインだとビルドできなくなる |
| `cargo` | `~/.cargo` の registry と git checkout | 次回ビルドで再ダウンロード |
| `docker-image` | どのコンテナ（停止中を含む）にも使われていないイメージ全部。タグ付きも消える | 次回 pull / build が遅くなる |
| `docker-build-cache` | build cache 全部 | 次回 build が遅くなる |
| `pip` / `uv` / `brew` | 各キャッシュ（brew は古いバージョンも削除） | 再ダウンロード |
| `nix` | 7日より古い世代と、どこからも参照されないストアパス | 古い世代へ rollback できなくなる |
| `xcode` | DerivedData、CoreSimulator のキャッシュ、利用できないシミュレータ | 次回ビルドがフルビルドになる（macOS のみ） |
| `user-cache` | `~/Library/Caches`（macOS）や `~/.cache`（Linux）直下で、30日間更新がないもの。専用カテゴリがあるキャッシュは除く | アプリが作り直す |
| `survey` | 削除対象外だが大きいもの（後述）。`run` できない | — |

`tmp-review` と `tmp-large` は `report tmp` の出力に現れる行の種類で、カテゴリ引数としては指定できない。

閾値は環境変数で変えられる: `CLEANUP_TMP_DAYS`（1）, `CLEANUP_TMP_LARGE_KB`（1048576 = 1GB）, `CLEANUP_CACHE_DAYS`（30）, `CLEANUP_NIX_DAYS`（7）, `CLEANUP_SURVEY_KB`（2097152 = 2GB）。
ユーザーが「3日より古いもの」「500MB 以上」のように言ったら、環境変数で渡して report からやり直す。

tmp 系では、隠しファイル、ソケットを含むもの、自分の所有でないもの、プロセスが開いているもの、`claude-*` / `cc-socks` などシステムや Claude Code 自身が使う名前は最初から候補に出ない。
「10/15 以前のものを消したい」と言われて該当が全部こうした除外対象だった場合は、消さなかった理由をそのまま伝える。

## survey

ユーザーが判断しないと消せないが、容量の大部分を占めていることが多いものを出す。

- 言語ランタイムの複数バージョン（fnm, mise, nvm, proto, volta, rustup, pyenv）
- Playwright のブラウザ、ゴミ箱
- どのコンテナにも使われていない Docker volume の合計
- `$HOME` から深さ3までで `CLEANUP_SURVEY_KB` 以上のディレクトリ。閾値を超える子孫があれば子孫側だけを出す

`large directory under HOME` の行は、上のカテゴリと重なるもの（`~/go/pkg/mod`, `~/Library/Caches` など）を除いてから見せる。
Docker Desktop の仮想ディスク（`Library/Containers/com.docker.docker`）は、`docker-image` などの削除後もすぐには縮まないことがあるので、そう書き添える。
残りは何のディレクトリかを `ls` や `git -C <dir> status -sb` で確かめ、一言で説明する（例: ローカル DB のデータ、worktree、node_modules）。

ユーザーが survey の項目を消したいと言ったら、スクリプトではなくそれぞれの正規の手段を案内または実行する。
worktree は `git -C <本体> worktree remove <path>`、ランタイムは各ツールの uninstall（`fnm uninstall <version>` など）、Docker volume は `docker volume ls -f dangling=true` で名前を見せて1つずつ `docker volume rm` する。
ローカル DB のデータのように中身の要否が分からないものは、消し方を提案するだけにする。

## 結果の見せ方

TSV をそのまま貼らず、カテゴリごとの合計サイズの表にまとめる。

```
| カテゴリ | サイズ | 内容 |
|---|---|---|
| docker-build-cache | 10.1G | build cache |
| docker-image | 7.2G（10個） | どのコンテナにも使われていないイメージ |
| yarn | 5.2G | ~/.yarn/berry/cache |
| tmp | 23M（97件） | 1日以上更新のない tmp のエントリ |
```

- サイズが大きい順に並べ、0 や数 KB のものは「その他」にまとめる。
- `tmp` の中身は、大きいものだけ数件名前を挙げれば十分。0K のエントリが大量にあっても列挙しない。
- `tmp-review` と `tmp-large` は表とは別に1件ずつ、パス・サイズ・note（`git-dirty:<repo>` など）を出し、消すかどうかを聞く。git の note が付いていれば `git -C <repo> status -s` などで中身を見て、何が失われるかを具体的に添える。
- `go-mod`, `docker-image`, `nix` は消したあとの影響が大きいので、表の「内容」か補足で一言触れる。`docker-image` は消えるタグ付きイメージを `docker images` で確かめ、主なものを挙げる。
- nix はサイズを事前に出せないので「不明」と書く。
- survey は削除候補の表とは別に「削除対象外だが大きいもの」として大きい順に見せる。

## やってはいけないこと

- `sudo` を付けない。root 所有のファイルや nix-darwin のシステム世代は対象外とし、必要ならユーザーに自分で実行してもらう。
- `tmp-review` の note に `git-worktree` があるものを `rm -rf` しない。本体リポジトリに worktree 登録が残り、片付けるには `git worktree prune` が必要になる。prune は見えない worktree の登録を一括で消す事故を起こすので、`git -C <本体> worktree remove <path>` を案内する。
- `docker system prune --volumes` や `docker volume prune` を実行しない。DB などのデータ volume がまとめて消える。
- report を見せずに `run` しない。
