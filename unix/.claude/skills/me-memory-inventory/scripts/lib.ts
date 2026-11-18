import { join } from "node:path";

export type Frontmatter = {
  fields: Record<string, string>;
  body: string;
};

export type IndexEntry = {
  title: string;
  file: string;
  hook: string;
};

export type IndexProblems = {
  /** 索引にあるがファイルが存在しない */
  missingFiles: string[];
  /** ファイルはあるが索引に載っていない */
  orphanFiles: string[];
  /** 索引に2回以上載っている */
  duplicateFiles: string[];
};

export type References = {
  paths: string[];
  pullRequests: string[];
};

const FRONTMATTER_PATTERN = /^---\n([\s\S]*?)\n---\n?([\s\S]*)$/;
const INDEX_ENTRY_PATTERN = /^\s*-\s*\[([^\]]+)\]\(([^)]+)\)\s*(?:[—–-]+\s*(.*))?$/;
const LINK_PATTERN = /\[\[([^\]]+)\]\]/g;
const PULL_REQUEST_URL_PATTERN = /https:\/\/github\.com\/[^/\s]+\/[^/\s]+\/pull\/\d+/g;
const PULL_REQUEST_NUMBER_PATTERN = /(?<![\w/&])(?:PR\s*)?#\d+\b/g;
const PATH_CHARACTER_EXCLUSIONS = /[<>*{}$]/;
const TRAILING_PUNCTUATION = /[)\]、。,.:;'"`]+$/;
const ENCODED_PATH_SEPARATORS = ["-", ".", "_", " "] as const;

/**
 * `metadata:` 配下の入れ子のキーは、トップレベルのキーと同じ階層に平坦化する。
 * 旧形式（`type:` がトップレベル）と新形式（`metadata.type`）を同じ扱いにするため。
 */
export function parseFrontmatter(text: string): Frontmatter {
  const match = FRONTMATTER_PATTERN.exec(text.replace(/\r\n/g, "\n"));
  if (match === null) {
    return { fields: {}, body: text };
  }
  const [, header = "", body = ""] = match;
  const fields = Object.fromEntries(
    header.split("\n").flatMap((line) => {
      const field = /^\s*([A-Za-z][\w-]*):\s*(.*)$/.exec(line);
      if (field === null) {
        return [];
      }
      const [, key = "", value = ""] = field;
      return value === "" ? [] : [[key, unquote(value.trim())]];
    }),
  );
  return { fields, body };
}

function unquote(value: string): string {
  const quoted = /^(["'])(.*)\1$/.exec(value);
  return quoted?.[2] ?? value;
}

export function parseIndex(text: string): IndexEntry[] {
  return text.split("\n").flatMap((line) => {
    const match = INDEX_ENTRY_PATTERN.exec(line);
    if (match === null) {
      return [];
    }
    const [, title = "", file = "", hook = ""] = match;
    return [{ title: title.trim(), file: file.trim(), hook: hook.trim() }];
  });
}

export function findIndexProblems(entries: readonly IndexEntry[], files: readonly string[]): IndexProblems {
  const indexedFiles = entries.map((entry) => entry.file);
  const existingFiles = new Set(files);
  const indexedSet = new Set(indexedFiles);
  return {
    missingFiles: [...indexedSet].filter((file) => !existingFiles.has(file)),
    orphanFiles: files.filter((file) => !indexedSet.has(file)),
    duplicateFiles: [...indexedSet].filter(
      (file) => indexedFiles.filter((indexedFile) => indexedFile === file).length > 1,
    ),
  };
}

export function extractLinks(body: string): string[] {
  return [...new Set([...body.matchAll(LINK_PATTERN)].map((match) => (match[1] ?? "").trim()))];
}

/**
 * 実在確認できるのはホーム配下の絶対パスだけに絞る。
 * `/api/v2` のような URL パスや、リポジトリ内の相対パスまで拾うと、存在しないことが古さの根拠にならないため。
 * `~/hooks/x` のような TypeScript のパスエイリアスと区別するため、ホーム直下の先頭要素が実在するものだけを残す。
 */
export function extractReferences(
  body: string,
  home: string,
  isHomeEntry: (name: string) => boolean,
): References {
  const tokens = body.split(/[\s`()（）「」]+/);
  const paths = tokens.flatMap((token) => {
    const trimmed = token.replace(TRAILING_PUNCTUATION, "");
    const relative = trimmed.startsWith("~/")
      ? trimmed.slice(2)
      : trimmed.startsWith(`${home}/`)
        ? trimmed.slice(home.length + 1)
        : null;
    const firstSegment = relative?.split("/")[0] ?? "";
    const isReference = relative !== null && !PATH_CHARACTER_EXCLUSIONS.test(trimmed) && isHomeEntry(firstSegment);
    return isReference ? [trimmed] : [];
  });
  const pullRequests = [
    ...(body.match(PULL_REQUEST_URL_PATTERN) ?? []),
    ...(body.replace(PULL_REQUEST_URL_PATTERN, "").match(PULL_REQUEST_NUMBER_PATTERN) ?? []).map(
      (reference) => reference.replace(/^PR\s*/, ""),
    ),
  ];
  return { paths: [...new Set(paths)], pullRequests: [...new Set(pullRequests)] };
}

export function expandHome(path: string, home: string): string {
  return path.startsWith("~/") ? join(home, path.slice(2)) : path;
}

/**
 * Claude Code は cwd の英数字以外をすべて `-` に置き換えてディレクトリ名にするため、元の区切り文字は失われている。
 * トークンの間ごとに「ディレクトリ区切り」か「名前の中の記号」かを試し、実在するディレクトリにたどり着く候補を返す。
 */
export function resolveEncodedPath(
  encoded: string,
  listDirectoryNames: (directory: string) => readonly string[],
): string | null {
  if (!encoded.startsWith("-")) {
    return null;
  }
  const tokens = encoded.slice(1).split("-");

  function search(directory: string, segment: string, index: number): string | null {
    const names = listDirectoryNames(directory);
    if (!names.some((name) => name.startsWith(segment))) {
      return null;
    }
    const isCompleteName = segment !== "" && names.includes(segment);
    if (index === tokens.length) {
      return isCompleteName ? join(directory, segment) : null;
    }
    const token = tokens[index] ?? "";
    const descended = isCompleteName ? search(join(directory, segment), token, index + 1) : null;
    if (descended !== null) {
      return descended;
    }
    for (const separator of ENCODED_PATH_SEPARATORS) {
      const extended = search(directory, `${segment}${separator}${token}`, index + 1);
      if (extended !== null) {
        return extended;
      }
    }
    return null;
  }

  return search("/", tokens[0] ?? "", 1);
}

export function extractSessionWorkingDirectory(logHead: string): string | null {
  const match = /"cwd":"((?:[^"\\]|\\.)*)"/.exec(logHead);
  return match?.[1] === undefined ? null : JSON.parse(`"${match[1]}"`);
}

/** グローバルルールの「ホームからの相対パスで2階層」に合わせる */
export function buildArchiveDirectory(projectPath: string, home: string): string | null {
  if (projectPath !== home && !projectPath.startsWith(`${home}/`)) {
    return null;
  }
  const levels = projectPath.slice(home.length).split("/").filter(Boolean).slice(0, 2);
  return join(home, ".agents", ...levels);
}

/**
 * home-manager は `~/dotfiles/unix/<相対パス>` を Nix store 経由で `~/<相対パス>` に symlink する。
 * store 側は読み取り専用で再適用時に上書きされるので、編集先は dotfiles 側の実体にする。
 */
export function convertToEditablePath(input: {
  path: string;
  realPath: string;
  home: string;
  exists: (path: string) => boolean;
}): string | null {
  const { path, realPath, home, exists } = input;
  if (!realPath.startsWith("/nix/store/")) {
    return realPath;
  }
  if (!path.startsWith(`${home}/`)) {
    return null;
  }
  const source = join(home, "dotfiles", "unix", path.slice(home.length + 1));
  return exists(source) ? source : null;
}
