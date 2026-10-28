export const CATEGORIES = [
  "tmp",
  "npm",
  "yarn",
  "pnpm",
  "bun",
  "go",
  "go-mod",
  "cargo",
  "docker-image",
  "docker-build-cache",
  "pip",
  "uv",
  "brew",
  "nix",
  "xcode",
  "user-cache",
  "survey",
] as const;

export type Category = (typeof CATEGORIES)[number];

/** report が出力する行の種類。`tmp-review` と `tmp-large` は `tmp` の report にだけ現れる */
export type RowCategory = Category | "tmp-review" | "tmp-large";

export type Row = {
  category: RowCategory;
  /** サイズを事前に測れないものは null */
  sizeInKilobytes: number | null;
  target: string;
  note: string;
};

export type Thresholds = {
  tmpDays: number;
  tmpLargeKilobytes: number;
  cacheDays: number;
  nixDays: number;
  surveyKilobytes: number;
};

export type DirectorySize = { sizeInKilobytes: number; path: string };

const KILOBYTE = 1024;
const DAY_IN_MILLISECONDS = 24 * 60 * 60 * 1000;

function readNonNegativeInteger(name: string, value: string | undefined, fallback: number): number {
  if (value === undefined || value === "") {
    return fallback;
  }
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 0) {
    throw new Error(`${name} must be a non-negative integer: ${value}`);
  }
  return parsed;
}

export function readThresholds(environment: Record<string, string | undefined>): Thresholds {
  return {
    tmpDays: readNonNegativeInteger("CLEANUP_TMP_DAYS", environment.CLEANUP_TMP_DAYS, 1),
    tmpLargeKilobytes: readNonNegativeInteger("CLEANUP_TMP_LARGE_KB", environment.CLEANUP_TMP_LARGE_KB, 1048576),
    cacheDays: readNonNegativeInteger("CLEANUP_CACHE_DAYS", environment.CLEANUP_CACHE_DAYS, 30),
    nixDays: readNonNegativeInteger("CLEANUP_NIX_DAYS", environment.CLEANUP_NIX_DAYS, 7),
    surveyKilobytes: readNonNegativeInteger("CLEANUP_SURVEY_KB", environment.CLEANUP_SURVEY_KB, 2097152),
  };
}

export function isCategory(value: string): value is Category {
  return (CATEGORIES as readonly string[]).includes(value);
}

export function findUnknownCategories(values: readonly string[]): string[] {
  return values.filter((value) => !isCategory(value));
}

export function formatKilobytes(kilobytes: number): string {
  const units = ["K", "M", "G", "T"];
  let size = kilobytes;
  let unitIndex = 0;
  while (size >= KILOBYTE && unitIndex < units.length - 1) {
    size /= KILOBYTE;
    unitIndex += 1;
  }
  return unitIndex === 0 ? `${Math.trunc(size)}${units[0]}` : `${size.toFixed(1)}${units[unitIndex]}`;
}

/** TSV の列: category, size_kb, size, target, note */
export function formatRow(row: Row): string {
  const size = row.sizeInKilobytes === null ? "-" : formatKilobytes(row.sizeInKilobytes);
  return [row.category, row.sizeInKilobytes ?? "-", size, row.target, row.note].join("\t");
}

export function cutoffTime(now: number, days: number): number {
  return now - days * DAY_IN_MILLISECONDS;
}

/** @param size docker の表記（例: `77.03MB`, `4.799GB`, `0B`）。docker は 1000 単位で表記する */
export function convertDockerSizeToKilobytes(size: string): number {
  const match = /^([0-9.]+)\s*([a-zA-Z]*)$/.exec(size.trim());
  if (match === null) {
    return 0;
  }
  const factors: Record<string, number> = { B: 1, KB: 1e3, MB: 1e6, GB: 1e9, TB: 1e12 };
  const factor = factors[match[2].toUpperCase()] ?? 0;
  return Math.trunc((Number(match[1]) * factor) / KILOBYTE);
}

/**
 * `docker system df -v` で `{{println <参照数> <サイズ>}}` を並べた出力から、参照数 0 のものを合計する
 */
export function sumUnreferencedDockerSizes(output: string): { count: number; totalKilobytes: number } {
  return output
    .split("\n")
    .map((line) => line.trim().split(/\s+/))
    .filter(([references, size]) => references === "0" && size !== undefined)
    .reduce(
      (summary, [, size]) => ({
        count: summary.count + 1,
        totalKilobytes: summary.totalKilobytes + convertDockerSizeToKilobytes(size),
      }),
      { count: 0, totalKilobytes: 0 },
    );
}

/** @param output `docker system df --format '{{.Type}}\t{{.Size}}'` の出力 */
export function parseBuildCacheKilobytes(output: string): number {
  const line = output.split("\n").find((candidate) => candidate.startsWith("Build Cache\t"));
  const size = line?.split("\t")[1];
  return size === undefined ? 0 : convertDockerSizeToKilobytes(size);
}

/** @param output `lsof -nP -Fn` の出力 */
export function parseLsofNames(output: string): string[] {
  return output
    .split("\n")
    .filter((line) => line.startsWith("n"))
    .map((line) => line.slice(1));
}

/**
 * 開かれているパスを、走査対象ルート直下のエントリ単位に畳む。
 * エントリごとに数万行の lsof 出力を照合すると tmp の走査だけで数分かかる
 */
export function collapseOpenPathsToEntries(openPaths: Iterable<string>, roots: readonly string[]): Set<string> {
  const prefixes = roots.filter((root) => root !== "").map((root) => `${root}/`);
  const entries = new Set<string>();
  for (const openPath of openPaths) {
    for (const prefix of prefixes) {
      if (!openPath.startsWith(prefix)) {
        continue;
      }
      const [firstSegment] = openPath.slice(prefix.length).split("/");
      entries.add(`${prefix}${firstSegment}`);
    }
  }
  return entries;
}

export function isProtectedTmpName(name: string): boolean {
  const protectedPrefixes = [".", "claude-", "com.apple.", "systemd-private-", "tmux-", "ssh-"];
  const protectedNames = ["cc-socks", "snap-private-tmp"];
  return protectedNames.includes(name) || protectedPrefixes.some((prefix) => name.startsWith(prefix));
}

/**
 * tmp 直下のエントリを分類する。
 * tmp: 古く安全に消せるもの / tmp-review: 古いが git の作業が残るもの / tmp-large: 新しいが大きいもの
 */
export function classifyTmpEntry(input: {
  hasRecentFile: boolean;
  sizeInKilobytes: number;
  thresholds: Thresholds;
}): "stale" | "large" | null {
  if (!input.hasRecentFile) {
    return "stale";
  }
  return input.sizeInKilobytes >= input.thresholds.tmpLargeKilobytes ? "large" : null;
}

export function buildTmpRow(input: {
  kind: "stale" | "large";
  entry: string;
  sizeInKilobytes: number;
  gitRisk: string;
  thresholds: Thresholds;
}): Row {
  const { kind, entry, sizeInKilobytes, gitRisk, thresholds } = input;
  if (kind === "large") {
    return { category: "tmp-large", sizeInKilobytes, target: entry, note: gitRisk };
  }
  return gitRisk === ""
    ? { category: "tmp", sizeInKilobytes, target: entry, note: `older than ${thresholds.tmpDays}d` }
    : { category: "tmp-review", sizeInKilobytes, target: entry, note: gitRisk };
}

/** @param output `du -k` の出力（`<size>\t<path>` の行） */
export function parseDuOutput(output: string): DirectorySize[] {
  return output
    .split("\n")
    .map((line) => line.split("\t"))
    .filter(([size, path]) => path !== undefined && /^\d+$/.test(size))
    .map(([size, path]) => ({ sizeInKilobytes: Number(size), path }));
}

/** 子孫にも閾値超えがあるディレクトリは子孫側だけを残し、どこが大きいかを具体的に示す */
export function selectLargeLeafDirectories(directories: readonly DirectorySize[], minimumKilobytes: number): DirectorySize[] {
  const large = directories.filter((directory) => directory.sizeInKilobytes >= minimumKilobytes);
  return large
    .filter((directory) => !large.some((other) => other.path.startsWith(`${directory.path}/`)))
    .toSorted((left, right) => right.sizeInKilobytes - left.sizeInKilobytes);
}
