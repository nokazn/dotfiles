#!/usr/bin/env bash

set -euo pipefail

# macOS の /bin/bash 3.2 でも動くよう、連想配列や mapfile は使わない

readonly TMP_DAYS="${CLEANUP_TMP_DAYS:-1}"
readonly TMP_LARGE_KB="${CLEANUP_TMP_LARGE_KB:-1048576}"
readonly CACHE_DAYS="${CLEANUP_CACHE_DAYS:-30}"
readonly NIX_DAYS="${CLEANUP_NIX_DAYS:-7}"
readonly SURVEY_KB="${CLEANUP_SURVEY_KB:-2097152}"
OS="$(uname -s)"
readonly OS
readonly CATEGORIES=(tmp npm yarn pnpm bun go go-mod cargo docker-image docker-build-cache pip uv brew nix xcode user-cache survey)

IN_USE_ENTRIES=""
IN_USE_LOADED=0

function usage() {
  cat <<EOF
Usage:
  $(basename "$0") report [category...]   削除候補とサイズを表示する（何も消さない）
  $(basename "$0") run <category...>      カテゴリ単位で削除する
  $(basename "$0") delete-tmp <path...>   tmp 直下のエントリを個別に削除する
  $(basename "$0") categories             カテゴリ一覧と利用可否を表示する

Categories: ${CATEGORIES[*]}

report の出力は TSV: category, size_kb, size, target, note
survey は削除対象外の大きなものを報告するだけで、run できない
EOF
}

# @param {string} - 標準エラーに出すメッセージ
function log() {
  echo "[cleanup] $*" >&2
}

function has() {
  command -v "$1" >/dev/null 2>&1
}

# @param {number} - KB 単位のサイズ
# @return {string} - 人間が読める表記
function format_kb() {
  awk -v kb="$1" 'BEGIN {
    split("K M G T", unit, " ");
    size = kb; i = 1;
    while (size >= 1024 && i < 4) { size /= 1024; i++ }
    printf (i == 1 ? "%d%s" : "%.1f%s"), size, unit[i]
  }'
}

function size_kb() {
  local -r path="$1"
  { du -sk "$path" 2>/dev/null || true; } | awk 'NR == 1 { print $1 } END { if (NR == 0) print 0 }'
}

# @param {string} category
# @param {number} size_kb - 不明なら空文字
# @param {string} target
# @param {string} note
function emit() {
  local -r category="$1" kb="$2" target="$3" note="${4:-}"
  local human="-"
  [[ -n "$kb" ]] && human="$(format_kb "$kb")"
  printf '%s\t%s\t%s\t%s\t%s\n' "$category" "${kb:--}" "$human" "$target" "$note"
}

function emit_paths() {
  local -r category="$1" note="$2"
  shift 2
  local path
  for path in "$@"; do
    [[ -e "$path" ]] && emit "$category" "$(size_kb "$path")" "$path" "$note"
  done
  return 0
}

function canonical_dir() {
  (cd "$1" 2>/dev/null && pwd -P)
}

function list_open_paths() {
  if has lsof; then
    lsof -nP -Fn 2>/dev/null | sed -n 's/^n//p' || true
  elif [[ -d /proc ]]; then
    local link
    for link in /proc/[0-9]*/fd/* /proc/[0-9]*/cwd; do readlink "$link" 2>/dev/null || true; done
  else
    log "lsof も /proc もないため使用中ファイルを判定できない"
    exit 1
  fi
}

# 開かれているパスを走査対象ルート直下のエントリ単位に畳んでおく。
# エントリごとに数万行の lsof 出力を照合すると tmp の走査だけで数分かかる
function load_in_use_entries() {
  [[ "$IN_USE_LOADED" == 1 ]] && return 0
  local -r roots="$( (list_tmp_roots; canonical_dir "$(user_cache_root)") | sort -u)"
  IN_USE_ENTRIES="$(list_open_paths | SCAN_ROOTS="$roots" awk '
    BEGIN { count = split(ENVIRON["SCAN_ROOTS"], root, "\n") }
    {
      for (i = 1; i <= count; i++) {
        prefix = root[i] "/"
        if (root[i] != "" && index($0, prefix) == 1) {
          rest = substr($0, length(prefix) + 1)
          slash = index(rest, "/")
          print prefix (slash ? substr(rest, 1, slash - 1) : rest)
        }
      }
    }' | sort -u)"
  IN_USE_LOADED=1
}

# @param {string} - 走査対象ルート直下のエントリの正規化済みパス
function is_in_use() {
  load_in_use_entries
  printf '%s\n' "$IN_USE_ENTRIES" | grep -qxF -- "$1"
}

function has_recent_file() {
  local -r path="$1" days="$2"
  [[ -n "$(find "$path" -mtime -"$days" -print 2>/dev/null | head -n 1)" ]]
}

function contains_socket() {
  [[ -n "$(find "$1" -type s -print 2>/dev/null | head -n 1)" ]]
}

# @return {string} - git リポジトリの状態。消すと失われうるものがなければ空
function describe_git_risk() {
  local -r path="$1"
  [[ -d "$path" ]] || return 0
  local notes="" git_path repo
  while IFS= read -r git_path; do
    repo="$(dirname "$git_path")"
    if [[ -f "$git_path" ]]; then
      # ディレクトリだけ消すと本体側に worktree 登録が残り、prune しか消す手段がなくなる
      notes="${notes}git-worktree:${repo} "
      continue
    fi
    if [[ -n "$(git -C "$repo" status --porcelain --ignore-submodules=all 2>/dev/null | head -n 1)" ]]; then
      notes="${notes}git-dirty:${repo} "
    fi
    if [[ -n "$(git -C "$repo" log --branches --not --remotes --oneline -1 2>/dev/null)" ]]; then
      notes="${notes}git-unpushed:${repo} "
    fi
  done < <(find "$path" -maxdepth 3 -name .git -print 2>/dev/null)
  printf '%s' "${notes% }"
}

function list_tmp_roots() {
  local roots root
  IFS=: read -r -a roots <<<"${CLEANUP_TMP_ROOTS:-/tmp:/var/tmp:${TMPDIR:-}}"
  for root in "${roots[@]}"; do
    [[ -n "$root" && -d "$root" ]] && canonical_dir "$root"
  done | sort -u
}

function is_protected_tmp_name() {
  case "$1" in
    .* | claude-* | cc-socks | com.apple.* | systemd-private-* | tmux-* | ssh-* | snap-private-tmp) return 0 ;;
    *) return 1 ;;
  esac
}

# tmp 直下のエントリを分類して emit する。
# tmp: 古く安全に消せるもの / tmp-review: 古いが git の作業が残るもの / tmp-large: 新しいが大きいもの
function scan_tmp() {
  local root entry name kb git_risk
  while IFS= read -r root; do
    for entry in "$root"/* "$root"/.[!.]*; do
      [[ -e "$entry" || -L "$entry" ]] || continue
      name="$(basename "$entry")"
      is_protected_tmp_name "$name" && continue
      [[ -L "$entry" ]] && continue
      [[ -f "$entry" || -d "$entry" ]] || continue
      [[ -O "$entry" ]] || continue
      is_in_use "$entry" && continue
      [[ -d "$entry" ]] && contains_socket "$entry" && continue

      kb="$(size_kb "$entry")"
      if ! has_recent_file "$entry" "$TMP_DAYS"; then
        git_risk="$(describe_git_risk "$entry")"
        if [[ -n "$git_risk" ]]; then
          emit tmp-review "$kb" "$entry" "$git_risk"
        else
          emit tmp "$kb" "$entry" "older than ${TMP_DAYS}d"
        fi
      elif ((kb >= TMP_LARGE_KB)); then
        emit tmp-large "$kb" "$entry" "$(describe_git_risk "$entry")"
      fi
    done
  done < <(list_tmp_roots)
}

function user_cache_root() {
  if [[ "$OS" == Darwin ]]; then
    echo "$HOME/Library/Caches"
  else
    echo "${XDG_CACHE_HOME:-$HOME/.cache}"
  fi
}

# 専用カテゴリで消せるキャッシュは user-cache に重ねて出さない
function list_dedicated_cache_names() {
  is_available brew && echo Homebrew
  is_available yarn && printf '%s\n' Yarn yarn
  is_available go && echo go-build
  is_available pip && echo pip
  is_available uv && echo uv
  return 0
}

function scan_user_cache() {
  local -r root="$(user_cache_root)"
  [[ -d "$root" ]] || return 0
  local -r dedicated="$(list_dedicated_cache_names)"
  local entry name
  for entry in "$root"/*; do
    [[ -e "$entry" && ! -L "$entry" && -O "$entry" ]] || continue
    name="$(basename "$entry")"
    case "$name" in com.apple.*) continue ;; esac
    printf '%s\n' "$dedicated" | grep -qxF -- "$name" && continue
    has_recent_file "$entry" "$CACHE_DAYS" && continue
    is_in_use "$entry" && continue
    emit user-cache "$(size_kb "$entry")" "$entry" "not modified for ${CACHE_DAYS}d"
  done
}

function yarn_cache_dirs() {
  local dir
  for dir in "$HOME/Library/Caches/Yarn" "${XDG_CACHE_HOME:-$HOME/.cache}/yarn" "$HOME/.yarn/berry/cache"; do
    [[ -d "$dir" ]] && echo "$dir"
  done
  return 0
}

function cargo_cache_dirs() {
  local -r cargo_home="${CARGO_HOME:-$HOME/.cargo}"
  local dir
  for dir in "$cargo_home/registry/cache" "$cargo_home/registry/src" "$cargo_home/git/checkouts"; do
    [[ -d "$dir" ]] && echo "$dir"
  done
  return 0
}

function xcode_cache_dirs() {
  local dir
  for dir in "$HOME/Library/Developer/Xcode/DerivedData" "$HOME/Library/Developer/CoreSimulator/Caches"; do
    [[ -d "$dir" ]] && echo "$dir"
  done
  return 0
}

# @param {string} - docker の表記（例: 77.03MB, 4.799GB, 0B）
# @return {number} - KB
function convert_docker_size_to_kb() {
  awk -v size="$1" 'BEGIN {
    match(size, /^[0-9.]+/)
    number = substr(size, 1, RLENGTH); unit = toupper(substr(size, RLENGTH + 1))
    factor["B"] = 1; factor["KB"] = 1e3; factor["MB"] = 1e6; factor["GB"] = 1e9; factor["TB"] = 1e12
    printf "%d", number * factor[unit] / 1024
  }'
}

function report_docker_images() {
  local containers unique_size total_kb=0 count=0
  while read -r containers unique_size; do
    [[ "$containers" == 0 ]] || continue
    total_kb=$((total_kb + $(convert_docker_size_to_kb "$unique_size")))
    count=$((count + 1))
  done < <(docker system df -v --format '{{range .Images}}{{println .Containers .UniqueSize}}{{end}}')
  # system df の Reclaimable は使用中イメージと共有するレイヤまで数えるので、イメージ固有分を積み上げる
  emit docker-image "$total_kb" "${count} images not used by any container" "image prune -a。共有レイヤの分だけ実際はもう少し空く"
}

function report_docker_build_cache() {
  local -r reclaimable="$(docker system df --format '{{.Type}}\t{{.Reclaimable}}' | awk -F '\t' '$1 == "Build Cache" { print $2 }')"
  emit docker-build-cache "$(convert_docker_size_to_kb "${reclaimable%% *}")" "build cache" "builder prune -a"
}

function list_runtime_version_dirs() {
  local dir
  for dir in "${FNM_DIR:-$HOME/.local/share/fnm}/node-versions" "$HOME/Library/Application Support/fnm/node-versions" \
    "$HOME/.local/share/mise/installs" "$HOME/.nvm/versions" "$HOME/.proto/tools" "$HOME/.volta/tools/image" \
    "$HOME/.rustup/toolchains" "$HOME/.pyenv/versions"; do
    [[ -d "$dir" ]] && echo "$dir"
  done
  return 0
}

# 削除カテゴリに含めないが容量を食っているものを、ユーザーが判断できるよう並べる
function report_survey() {
  local dir
  while IFS= read -r dir; do
    emit_paths survey "language runtime versions" "$dir"
  done < <(list_runtime_version_dirs)
  emit_paths survey "Playwright browsers" "$(user_cache_root)/ms-playwright"
  [[ -r "$HOME/.Trash" ]] && emit_paths survey "Trash" "$HOME/.Trash"

  if is_available docker-image; then
    local links size total_kb=0 count=0
    while read -r links size; do
      [[ "$links" == 0 ]] || continue
      total_kb=$((total_kb + $(convert_docker_size_to_kb "$size")))
      count=$((count + 1))
    done < <(docker system df -v --format '{{range .Volumes}}{{println .Links .Size}}{{end}}')
    ((count > 0)) && emit survey "$total_kb" "${count} docker volumes not used by any container" "DB などのデータが入っていることがある"
  fi

  # 子孫にも閾値超えがあるディレクトリは子孫側だけを残し、どこが大きいかを具体的に示す
  { du -xk -d 3 "$HOME" 2>/dev/null || true; } | awk -v min="$SURVEY_KB" -F '\t' '$1 >= min' | awk -F '\t' '
    { size[NR] = $1; path[NR] = $2 }
    END {
      for (i = 1; i <= NR; i++) {
        leaf = 1
        for (j = 1; j <= NR; j++) if (j != i && index(path[j], path[i] "/") == 1) { leaf = 0; break }
        if (leaf) printf "%s\t%s\n", size[i], path[i]
      }
    }' | sort -rn | while IFS=$'\t' read -r kb dir; do
    emit survey "$kb" "$dir" "large directory under HOME"
  done
}

# プロジェクト配下で実行すると toolchain や packageManager の指定を拾うため、中立なディレクトリで実行する
function run_neutral() {
  (cd / && GOTOOLCHAIN=local COREPACK_ENABLE_DOWNLOAD_PROMPT=0 "$@")
}

function is_available() {
  case "$1" in
    tmp | user-cache) return 0 ;;
    npm | pnpm | bun | brew | uv) has "$1" && run_neutral "$1" --version >/dev/null 2>&1 ;;
    go | go-mod) has go && run_neutral go version >/dev/null 2>&1 ;;
    yarn) [[ -n "$(yarn_cache_dirs)" ]] ;;
    cargo) [[ -n "$(cargo_cache_dirs)" ]] ;;
    docker-image | docker-build-cache) has docker && docker info >/dev/null 2>&1 ;;
    survey) return 0 ;;
    pip) has python3 && python3 -m pip --version >/dev/null 2>&1 ;;
    nix) has nix-collect-garbage ;;
    xcode) [[ "$OS" == Darwin && -n "$(xcode_cache_dirs)" ]] ;;
    *) return 1 ;;
  esac
}

function report_category() {
  local -r category="$1"
  case "$category" in
    tmp) scan_tmp ;;
    user-cache) scan_user_cache ;;
    npm) emit_paths npm "npm cache clean --force" "$(run_neutral npm config get cache)/_cacache" ;;
    yarn) while IFS= read -r dir; do emit_paths yarn "rm -rf" "$dir"; done < <(yarn_cache_dirs) ;;
    pnpm) emit_paths pnpm "pnpm store prune (unreferenced only)" "$(run_neutral pnpm store path 2>/dev/null)" ;;
    bun) emit_paths bun "bun pm cache rm" "${BUN_INSTALL_CACHE_DIR:-$HOME/.bun/install/cache}" ;;
    go) emit_paths go "go clean -cache -testcache" "$(run_neutral go env GOCACHE)" ;;
    go-mod) emit_paths go-mod "go clean -modcache" "$(run_neutral go env GOMODCACHE)" ;;
    cargo) while IFS= read -r dir; do emit_paths cargo "rm -rf" "$dir"; done < <(cargo_cache_dirs) ;;
    docker-image) report_docker_images ;;
    docker-build-cache) report_docker_build_cache ;;
    survey) report_survey ;;
    pip) emit_paths pip "pip cache purge" "$(python3 -m pip cache dir 2>/dev/null)" ;;
    uv) emit_paths uv "uv cache clean" "$(uv cache dir)" ;;
    brew) emit_paths brew "brew cleanup --prune=all -s" "$(brew --cache)" ;;
    nix) emit nix "" "nix store" "nix-collect-garbage --delete-older-than ${NIX_DAYS}d (古い世代へ rollback できなくなる)" ;;
    xcode) while IFS= read -r dir; do emit_paths xcode "rm -rf" "$dir"; done < <(xcode_cache_dirs) ;;
  esac
}

function delete_tmp_entry() {
  local -r path="$1"
  local -r parent="$(canonical_dir "$(dirname "$path")")"
  local -r entry="${parent}/$(basename "$path")"
  if ! list_tmp_roots | grep -qxF "$parent"; then
    log "skip (tmp 直下ではない): $path"
    return 1
  fi
  if [[ ! -O "$entry" ]]; then
    log "skip (自分の所有ではない): $entry"
    return 1
  fi
  if is_in_use "$entry"; then
    log "skip (使用中): $entry"
    return 1
  fi
  rm -rf -- "$entry"
  log "deleted: $entry"
}

function run_category() {
  local -r category="$1"
  local dir path
  case "$category" in
    tmp)
      while IFS=$'\t' read -r _ _ _ path _; do
        delete_tmp_entry "$path" || true
      done < <(scan_tmp | awk -F '\t' '$1 == "tmp"')
      ;;
    user-cache)
      while IFS=$'\t' read -r _ _ _ path _; do
        rm -rf -- "$path"
        log "deleted: $path"
      done < <(scan_user_cache)
      ;;
    npm) run_neutral npm cache clean --force ;;
    yarn) while IFS= read -r dir; do rm -rf -- "$dir"; done < <(yarn_cache_dirs) ;;
    pnpm) run_neutral pnpm store prune ;;
    bun) run_neutral bun pm cache rm ;;
    go) run_neutral go clean -cache -testcache ;;
    go-mod) run_neutral go clean -modcache ;;
    cargo) while IFS= read -r dir; do rm -rf -- "$dir"; done < <(cargo_cache_dirs) ;;
    docker-image) docker image prune -a -f ;;
    docker-build-cache) docker builder prune -a -f ;;
    pip) python3 -m pip cache purge ;;
    uv) uv cache clean ;;
    brew) brew cleanup --prune=all -s ;;
    nix) nix-collect-garbage --delete-older-than "${NIX_DAYS}d" ;;
    xcode)
      while IFS= read -r dir; do rm -rf -- "$dir"; done < <(xcode_cache_dirs)
      has xcrun && xcrun simctl delete unavailable
      ;;
  esac
}

function validate_categories() {
  local category
  for category in "$@"; do
    case " ${CATEGORIES[*]} " in
      *" ${category} "*) ;;
      *)
        log "unknown category: $category"
        exit 2
        ;;
    esac
  done
}

function main() {
  local -r command="${1:-}"
  [[ $# -gt 0 ]] && shift
  local category
  case "$command" in
    categories)
      for category in "${CATEGORIES[@]}"; do
        if is_available "$category"; then echo "$category"$'\t'available; else echo "$category"$'\t'unavailable; fi
      done
      ;;
    report)
      [[ $# -eq 0 ]] && set -- "${CATEGORIES[@]}"
      validate_categories "$@"
      for category in "$@"; do
        if is_available "$category"; then
          report_category "$category" || log "report failed: $category"
        fi
      done
      ;;
    run)
      [[ $# -eq 0 ]] && { usage >&2; exit 2; }
      validate_categories "$@"
      for category in "$@"; do
        if [[ "$category" == survey ]]; then
          log "skip (survey は報告のみ): $category"
          continue
        fi
        if ! is_available "$category"; then
          log "skip (unavailable): $category"
          continue
        fi
        log "run: $category"
        run_category "$category" || log "run failed: $category"
      done
      ;;
    delete-tmp)
      [[ $# -eq 0 ]] && { usage >&2; exit 2; }
      local path
      for path in "$@"; do delete_tmp_entry "$path" || true; done
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
