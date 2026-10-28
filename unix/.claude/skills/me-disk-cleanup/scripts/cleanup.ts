#!/usr/bin/env bun

import { $ } from "bun";
import { access, constants, lstat, readdir, readlink, realpath, rm, stat } from "node:fs/promises";
import type { Stats } from "node:fs";
import { homedir } from "node:os";
import { basename, dirname, join } from "node:path";
import {
  CATEGORIES,
  type Category,
  type Row,
  buildTmpRow,
  classifyTmpEntry,
  collapseOpenPathsToEntries,
  cutoffTime,
  findUnknownCategories,
  formatRow,
  isProtectedTmpName,
  parseBuildCacheKilobytes,
  parseDuOutput,
  parseLsofNames,
  readThresholds,
  selectLargeLeafDirectories,
  sumUnreferencedDockerSizes,
} from "./lib.ts";

const thresholds = (() => {
  try {
    return readThresholds(process.env);
  } catch (error) {
    log(error instanceof Error ? error.message : String(error));
    process.exit(2);
  }
})();
const home = homedir();
const isDarwin = process.platform === "darwin";
const userId = process.getuid?.();

function usage(): string {
  const command = basename(process.argv[1] ?? "cleanup.ts");
  return `Usage:
  ${command} report [category...]   削除候補とサイズを表示する（何も消さない）
  ${command} run <category...>      カテゴリ単位で削除する
  ${command} delete-tmp <path...>   tmp 直下のエントリを個別に削除する
  ${command} categories             カテゴリ一覧と利用可否を表示する

Categories: ${CATEGORIES.join(" ")}

report の出力は TSV: category, size_kb, size, target, note
survey は削除対象外の大きなものを報告するだけで、run できない`;
}

function log(message: string): void {
  console.error(`[cleanup] ${message}`);
}

function has(command: string): boolean {
  return Bun.which(command) !== null;
}

// プロジェクト配下で実行すると toolchain や packageManager の指定を拾うため、中立なディレクトリで実行する
function neutral(strings: TemplateStringsArray, ...expressions: unknown[]) {
  return $(strings, ...(expressions as never[]))
    .cwd("/")
    .env({ ...process.env, GOTOOLCHAIN: "local", COREPACK_ENABLE_DOWNLOAD_PROMPT: "0" });
}

async function outputOf(command: ReturnType<typeof $>): Promise<string> {
  return (await command.quiet().nothrow().text()).trim();
}

async function succeeds(command: ReturnType<typeof $>): Promise<boolean> {
  return (await command.quiet().nothrow()).exitCode === 0;
}

async function statOrNull(path: string): Promise<Stats | null> {
  return path === "" ? null : stat(path).catch(() => null);
}

async function lstatOrNull(path: string): Promise<Stats | null> {
  return lstat(path).catch(() => null);
}

async function existingDirectories(paths: readonly string[]): Promise<string[]> {
  const directories = await Promise.all(
    paths.map(async (path) => ((await statOrNull(path))?.isDirectory() ? path : null)),
  );
  return directories.filter((directory) => directory !== null);
}

async function canonicalDirectory(path: string): Promise<string | null> {
  return (await statOrNull(path))?.isDirectory() ? realpath(path) : null;
}

function isOwned(stats: Stats): boolean {
  return stats.uid === userId;
}

async function sizeInKilobytes(path: string): Promise<number> {
  const [first] = parseDuOutput(await outputOf($`du -sk ${path}`));
  return first?.sizeInKilobytes ?? 0;
}

type Visit = { path: string; depth: number; stats: Stats };

/** find と同じくシンボリックリンクはたどらず、読めないディレクトリは黙って飛ばす */
async function* walk(path: string, maxDepth = Number.POSITIVE_INFINITY, depth = 0): AsyncGenerator<Visit> {
  const stats = await lstatOrNull(path);
  if (stats === null) {
    return;
  }
  yield { path, depth, stats };
  if (!stats.isDirectory() || depth >= maxDepth) {
    return;
  }
  for (const name of await readdir(path).catch(() => [])) {
    yield* walk(join(path, name), maxDepth, depth + 1);
  }
}

async function hasRecentFile(path: string, days: number): Promise<boolean> {
  const cutoff = cutoffTime(Date.now(), days);
  for await (const visit of walk(path)) {
    if (visit.stats.mtimeMs > cutoff) {
      return true;
    }
  }
  return false;
}

async function containsSocket(path: string): Promise<boolean> {
  for await (const visit of walk(path)) {
    if (visit.stats.isSocket()) {
      return true;
    }
  }
  return false;
}

/** @returns git リポジトリの状態。消すと失われうるものがなければ空文字 */
async function describeGitRisk(path: string): Promise<string> {
  const notes: string[] = [];
  for await (const visit of walk(path, 3)) {
    if (basename(visit.path) !== ".git" || visit.depth === 0) {
      continue;
    }
    const repository = dirname(visit.path);
    if (visit.stats.isFile()) {
      // ディレクトリだけ消すと本体側に worktree 登録が残り、prune しか消す手段がなくなる
      notes.push(`git-worktree:${repository}`);
      continue;
    }
    if ((await outputOf($`git -C ${repository} status --porcelain --ignore-submodules=all`)) !== "") {
      notes.push(`git-dirty:${repository}`);
    }
    if ((await outputOf($`git -C ${repository} log --branches --not --remotes --oneline -1`)) !== "") {
      notes.push(`git-unpushed:${repository}`);
    }
  }
  return notes.join(" ");
}

async function listTmpRoots(): Promise<string[]> {
  const configured = process.env.CLEANUP_TMP_ROOTS ?? `/tmp:/var/tmp:${process.env.TMPDIR ?? ""}`;
  const roots = await Promise.all(
    configured
      .split(":")
      .filter((root) => root !== "")
      .map(canonicalDirectory),
  );
  return [...new Set(roots.filter((root) => root !== null))].toSorted();
}

function userCacheRoot(): string {
  return isDarwin ? join(home, "Library/Caches") : (process.env.XDG_CACHE_HOME ?? join(home, ".cache"));
}

async function listOpenPaths(): Promise<string[]> {
  if (has("lsof")) {
    return parseLsofNames(await outputOf($`lsof -nP -Fn`));
  }
  const processIds = await readdir("/proc").catch(() => null);
  if (processIds === null) {
    log("lsof も /proc もないため使用中ファイルを判定できない");
    process.exit(1);
  }
  const links = await Promise.all(
    processIds
      .filter((processId) => /^\d+$/.test(processId))
      .map(async (processId) => {
        const descriptors = await readdir(`/proc/${processId}/fd`).catch(() => []);
        const targets = [...descriptors.map((descriptor) => `/proc/${processId}/fd/${descriptor}`), `/proc/${processId}/cwd`];
        return Promise.all(targets.map((target) => readlink(target).catch(() => null)));
      }),
  );
  return links.flat().filter((link) => link !== null);
}

let inUseEntries: Promise<Set<string>> | null = null;

async function isInUse(entry: string): Promise<boolean> {
  inUseEntries ??= (async () => {
    const roots = [...(await listTmpRoots()), await canonicalDirectory(userCacheRoot())];
    return collapseOpenPathsToEntries(
      await listOpenPaths(),
      roots.filter((root) => root !== null),
    );
  })();
  return (await inUseEntries).has(entry);
}

async function* scanTmp(): AsyncGenerator<Row> {
  for (const root of await listTmpRoots()) {
    for (const name of await readdir(root).catch(() => [])) {
      if (isProtectedTmpName(name)) {
        continue;
      }
      const entry = join(root, name);
      const stats = await lstatOrNull(entry);
      if (stats === null || stats.isSymbolicLink() || !(stats.isFile() || stats.isDirectory()) || !isOwned(stats)) {
        continue;
      }
      if ((await isInUse(entry)) || (stats.isDirectory() && (await containsSocket(entry)))) {
        continue;
      }
      const size = await sizeInKilobytes(entry);
      const kind = classifyTmpEntry({
        hasRecentFile: await hasRecentFile(entry, thresholds.tmpDays),
        sizeInKilobytes: size,
        thresholds,
      });
      if (kind !== null) {
        yield buildTmpRow({ kind, entry, sizeInKilobytes: size, gitRisk: await describeGitRisk(entry), thresholds });
      }
    }
  }
}

// 専用カテゴリで消せるキャッシュは user-cache に重ねて出さない
async function listDedicatedCacheNames(): Promise<Set<string>> {
  const candidates: [Category, string[]][] = [
    ["brew", ["Homebrew"]],
    ["yarn", ["Yarn", "yarn"]],
    ["go", ["go-build"]],
    ["pip", ["pip"]],
    ["uv", ["uv"]],
  ];
  const available = await Promise.all(
    candidates.map(async ([category, names]) => ((await isAvailable(category)) ? names : [])),
  );
  return new Set(available.flat());
}

async function* scanUserCache(): AsyncGenerator<Row> {
  const root = userCacheRoot();
  if (!(await statOrNull(root))?.isDirectory()) {
    return;
  }
  const dedicated = await listDedicatedCacheNames();
  for (const name of await readdir(root).catch(() => [])) {
    if (name.startsWith(".") || name.startsWith("com.apple.") || dedicated.has(name)) {
      continue;
    }
    const entry = join(root, name);
    const stats = await lstatOrNull(entry);
    if (stats === null || stats.isSymbolicLink() || !isOwned(stats)) {
      continue;
    }
    if ((await hasRecentFile(entry, thresholds.cacheDays)) || (await isInUse(entry))) {
      continue;
    }
    yield {
      category: "user-cache",
      sizeInKilobytes: await sizeInKilobytes(entry),
      target: entry,
      note: `not modified for ${thresholds.cacheDays}d`,
    };
  }
}

async function* rowsForPaths(category: Row["category"], note: string, paths: readonly string[]): AsyncGenerator<Row> {
  for (const path of paths) {
    if ((await statOrNull(path)) !== null) {
      yield { category, sizeInKilobytes: await sizeInKilobytes(path), target: path, note };
    }
  }
}

function yarnCacheDirectories(): Promise<string[]> {
  return existingDirectories([
    join(home, "Library/Caches/Yarn"),
    join(process.env.XDG_CACHE_HOME ?? join(home, ".cache"), "yarn"),
    join(home, ".yarn/berry/cache"),
  ]);
}

function cargoCacheDirectories(): Promise<string[]> {
  const cargoHome = process.env.CARGO_HOME ?? join(home, ".cargo");
  return existingDirectories([
    join(cargoHome, "registry/cache"),
    join(cargoHome, "registry/src"),
    join(cargoHome, "git/checkouts"),
  ]);
}

function xcodeCacheDirectories(): Promise<string[]> {
  return existingDirectories([
    join(home, "Library/Developer/Xcode/DerivedData"),
    join(home, "Library/Developer/CoreSimulator/Caches"),
  ]);
}

function runtimeVersionDirectories(): Promise<string[]> {
  return existingDirectories([
    join(process.env.FNM_DIR ?? join(home, ".local/share/fnm"), "node-versions"),
    join(home, "Library/Application Support/fnm/node-versions"),
    join(home, ".local/share/mise/installs"),
    join(home, ".nvm/versions"),
    join(home, ".proto/tools"),
    join(home, ".volta/tools/image"),
    join(home, ".rustup/toolchains"),
    join(home, ".pyenv/versions"),
  ]);
}

async function* reportDockerImages(): AsyncGenerator<Row> {
  const format = "{{range .Images}}{{println .Containers .UniqueSize}}{{end}}";
  const { count, totalKilobytes } = sumUnreferencedDockerSizes(await outputOf($`docker system df -v --format ${format}`));
  // system df の Reclaimable は使用中イメージと共有するレイヤまで数えるので、イメージ固有分を積み上げる
  yield {
    category: "docker-image",
    sizeInKilobytes: totalKilobytes,
    target: `${count} images not used by any container`,
    note: "image prune -a。共有レイヤの分だけ実際はもう少し空く",
  };
}

async function* reportDockerBuildCache(): AsyncGenerator<Row> {
  // Reclaimable は共有扱いのキャッシュを数えないが、builder prune -a はそれも含めて全部消すので Size を使う
  const format = "{{.Type}}\\t{{.Size}}";
  yield {
    category: "docker-build-cache",
    sizeInKilobytes: parseBuildCacheKilobytes(await outputOf($`docker system df --format ${format}`)),
    target: "build cache",
    note: "builder prune -a",
  };
}

// 削除カテゴリに含めないが容量を食っているものを、ユーザーが判断できるよう並べる
async function* reportSurvey(): AsyncGenerator<Row> {
  yield* rowsForPaths("survey", "language runtime versions", await runtimeVersionDirectories());
  yield* rowsForPaths("survey", "Playwright browsers", [join(userCacheRoot(), "ms-playwright")]);
  const trash = join(home, ".Trash");
  if (await access(trash, constants.R_OK).then(() => true, () => false)) {
    yield* rowsForPaths("survey", "Trash", [trash]);
  }

  if (await isAvailable("docker-image")) {
    const format = "{{range .Volumes}}{{println .Links .Size}}{{end}}";
    const { count, totalKilobytes } = sumUnreferencedDockerSizes(await outputOf($`docker system df -v --format ${format}`));
    if (count > 0) {
      yield {
        category: "survey",
        sizeInKilobytes: totalKilobytes,
        target: `${count} docker volumes not used by any container`,
        note: "DB などのデータが入っていることがある",
      };
    }
  }

  const directories = parseDuOutput(await outputOf($`du -xk -d 3 ${home}`));
  for (const directory of selectLargeLeafDirectories(directories, thresholds.surveyKilobytes)) {
    yield { category: "survey", sizeInKilobytes: directory.sizeInKilobytes, target: directory.path, note: "large directory under HOME" };
  }
}

async function isAvailable(category: Category): Promise<boolean> {
  switch (category) {
    case "tmp":
    case "user-cache":
    case "survey":
      return true;
    case "npm":
    case "pnpm":
    case "bun":
    case "brew":
    case "uv":
      return has(category) && succeeds(neutral`${category} --version`);
    case "go":
    case "go-mod":
      return has("go") && succeeds(neutral`go version`);
    case "yarn":
      return (await yarnCacheDirectories()).length > 0;
    case "cargo":
      return (await cargoCacheDirectories()).length > 0;
    case "docker-image":
    case "docker-build-cache":
      return has("docker") && succeeds($`docker info`);
    case "pip":
      return has("python3") && succeeds($`python3 -m pip --version`);
    case "nix":
      return has("nix-collect-garbage");
    case "xcode":
      return isDarwin && (await xcodeCacheDirectories()).length > 0;
  }
}

async function* reportCategory(category: Category): AsyncGenerator<Row> {
  switch (category) {
    case "tmp":
      return yield* scanTmp();
    case "user-cache":
      return yield* scanUserCache();
    case "npm":
      return yield* rowsForPaths("npm", "npm cache clean --force", [join(await outputOf(neutral`npm config get cache`), "_cacache")]);
    case "yarn":
      return yield* rowsForPaths("yarn", "rm -rf", await yarnCacheDirectories());
    case "pnpm":
      return yield* rowsForPaths("pnpm", "pnpm store prune (unreferenced only)", [await outputOf(neutral`pnpm store path`)]);
    case "bun":
      return yield* rowsForPaths("bun", "bun pm cache rm", [process.env.BUN_INSTALL_CACHE_DIR ?? join(home, ".bun/install/cache")]);
    case "go":
      return yield* rowsForPaths("go", "go clean -cache -testcache", [await outputOf(neutral`go env GOCACHE`)]);
    case "go-mod":
      return yield* rowsForPaths("go-mod", "go clean -modcache", [await outputOf(neutral`go env GOMODCACHE`)]);
    case "cargo":
      return yield* rowsForPaths("cargo", "rm -rf", await cargoCacheDirectories());
    case "docker-image":
      return yield* reportDockerImages();
    case "docker-build-cache":
      return yield* reportDockerBuildCache();
    case "survey":
      return yield* reportSurvey();
    case "pip":
      return yield* rowsForPaths("pip", "pip cache purge", [await outputOf($`python3 -m pip cache dir`)]);
    case "uv":
      return yield* rowsForPaths("uv", "uv cache clean", [await outputOf($`uv cache dir`)]);
    case "brew":
      return yield* rowsForPaths("brew", "brew cleanup --prune=all -s", [await outputOf($`brew --cache`)]);
    case "nix":
      yield {
        category: "nix",
        sizeInKilobytes: null,
        target: "nix store",
        note: `nix-collect-garbage --delete-older-than ${thresholds.nixDays}d (古い世代へ rollback できなくなる)`,
      };
      return;
    case "xcode":
      return yield* rowsForPaths("xcode", "rm -rf", await xcodeCacheDirectories());
  }
}

async function removeAll(paths: readonly string[]): Promise<void> {
  for (const path of paths) {
    await rm(path, { recursive: true, force: true });
    log(`deleted: ${path}`);
  }
}

async function deleteTmpEntry(path: string): Promise<boolean> {
  const parent = await canonicalDirectory(dirname(path));
  if (parent === null || !(await listTmpRoots()).includes(parent)) {
    log(`skip (tmp 直下ではない): ${path}`);
    return false;
  }
  const entry = join(parent, basename(path));
  const stats = await lstatOrNull(entry);
  if (stats === null || !isOwned(stats)) {
    log(`skip (自分の所有ではない): ${entry}`);
    return false;
  }
  if (await isInUse(entry)) {
    log(`skip (使用中): ${entry}`);
    return false;
  }
  await removeAll([entry]);
  return true;
}

async function runCategory(category: Exclude<Category, "survey">): Promise<void> {
  switch (category) {
    case "tmp":
      for await (const row of scanTmp()) {
        if (row.category === "tmp") {
          await deleteTmpEntry(row.target);
        }
      }
      return;
    case "user-cache":
      for await (const row of scanUserCache()) {
        await removeAll([row.target]);
      }
      return;
    case "npm":
      await neutral`npm cache clean --force`;
      return;
    case "yarn":
      return removeAll(await yarnCacheDirectories());
    case "pnpm":
      await neutral`pnpm store prune`;
      return;
    case "bun":
      await neutral`bun pm cache rm`;
      return;
    case "go":
      await neutral`go clean -cache -testcache`;
      return;
    case "go-mod":
      await neutral`go clean -modcache`;
      return;
    case "cargo":
      return removeAll(await cargoCacheDirectories());
    case "docker-image":
      await $`docker image prune -a -f`;
      return;
    case "docker-build-cache":
      await $`docker builder prune -a -f`;
      return;
    case "pip":
      await $`python3 -m pip cache purge`;
      return;
    case "uv":
      await $`uv cache clean`;
      return;
    case "brew":
      await $`brew cleanup --prune=all -s`;
      return;
    case "nix":
      await $`nix-collect-garbage --delete-older-than ${thresholds.nixDays}d`;
      return;
    case "xcode":
      await removeAll(await xcodeCacheDirectories());
      if (has("xcrun")) {
        await $`xcrun simctl delete unavailable`;
      }
      return;
  }
}

function validateCategories(values: readonly string[]): Category[] {
  const unknown = findUnknownCategories(values);
  if (unknown.length > 0) {
    log(`unknown category: ${unknown.join(" ")}`);
    process.exit(2);
  }
  return values as Category[];
}

async function main(argv: readonly string[]): Promise<void> {
  const [command, ...rest] = argv;
  switch (command) {
    case "categories":
      for (const category of CATEGORIES) {
        console.log(`${category}\t${(await isAvailable(category)) ? "available" : "unavailable"}`);
      }
      return;
    case "report":
      for (const category of validateCategories(rest.length === 0 ? CATEGORIES : rest)) {
        if (!(await isAvailable(category))) {
          continue;
        }
        try {
          for await (const row of reportCategory(category)) {
            console.log(formatRow(row));
          }
        } catch (error) {
          log(`report failed: ${category}: ${error}`);
        }
      }
      return;
    case "run":
      if (rest.length === 0) {
        break;
      }
      for (const category of validateCategories(rest)) {
        if (category === "survey") {
          log(`skip (survey は報告のみ): ${category}`);
          continue;
        }
        if (!(await isAvailable(category))) {
          log(`skip (unavailable): ${category}`);
          continue;
        }
        log(`run: ${category}`);
        await runCategory(category).catch((error) => log(`run failed: ${category}: ${error}`));
      }
      return;
    case "delete-tmp":
      if (rest.length === 0) {
        break;
      }
      for (const path of rest) {
        await deleteTmpEntry(path);
      }
      return;
  }
  console.error(usage());
  process.exit(2);
}

await main(process.argv.slice(2));
