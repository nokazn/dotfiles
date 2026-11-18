import { describe, expect, test } from "bun:test";
import {
  buildArchiveDirectory,
  convertToEditablePath,
  extractLinks,
  extractReferences,
  extractSessionWorkingDirectory,
  findIndexProblems,
  parseFrontmatter,
  parseIndex,
  resolveEncodedPath,
} from "./lib.ts";

const home = "/Users/someone";

describe("parseFrontmatter", () => {
  test("reads top-level fields and the body", () => {
    const parsed = parseFrontmatter("---\nname: a-memory\ntype: feedback\n---\n\nbody text\n");
    expect(parsed.fields).toEqual({ name: "a-memory", type: "feedback" });
    expect(parsed.body).toBe("\nbody text\n");
  });

  test("flattens fields nested under metadata", () => {
    const parsed = parseFrontmatter("---\nname: a\ndescription: 'quoted'\nmetadata:\n  type: project\n---\nbody");
    expect(parsed.fields).toEqual({ name: "a", description: "quoted", type: "project" });
  });

  test("treats the whole text as the body when there is no frontmatter", () => {
    expect(parseFrontmatter("just text")).toEqual({ fields: {}, body: "just text" });
  });
});

describe("parseIndex", () => {
  test("reads title, file, and hook from each list item", () => {
    const text = "# Memory Index\n\n- [Title A](a.md) — hook A\n- [Title B](b.md)\nnot an entry\n";
    expect(parseIndex(text)).toEqual([
      { title: "Title A", file: "a.md", hook: "hook A" },
      { title: "Title B", file: "b.md", hook: "" },
    ]);
  });
});

describe("findIndexProblems", () => {
  test("reports missing, orphan, and duplicate files", () => {
    const entries = parseIndex("- [A](a.md) — x\n- [B](b.md) — y\n- [A again](a.md) — z\n");
    expect(findIndexProblems(entries, ["a.md", "c.md"])).toEqual({
      missingFiles: ["b.md"],
      orphanFiles: ["c.md"],
      duplicateFiles: ["a.md"],
    });
  });
});

describe("extractLinks", () => {
  test("returns unique link names", () => {
    expect(extractLinks("see [[a-memory]] and [[b]] and [[a-memory]]")).toEqual(["a-memory", "b"]);
  });
});

describe("extractReferences", () => {
  const isHomeEntry = (name: string) => ["work", ".agents"].includes(name);

  test("keeps only paths under the home directory", () => {
    const body = "Run `~/work/repo/scripts/build.sh` or /Users/someone/.agents/doc.md, not /api/v2 or src/a.ts";
    expect(extractReferences(body, home, isHomeEntry).paths).toEqual([
      "~/work/repo/scripts/build.sh",
      "/Users/someone/.agents/doc.md",
    ]);
  });

  test("skips path aliases whose first segment is not in the home directory", () => {
    expect(extractReferences("import from `~/hooks/useSnackbar`", home, isHomeEntry).paths).toEqual([]);
  });

  test("skips placeholder paths", () => {
    expect(extractReferences("`~/.agents/<dir>/YYYYmmdd_*.md`", home, isHomeEntry).paths).toEqual([]);
  });

  test("returns pull request URLs and normalized numbers without duplicates", () => {
    const body = "Merged in https://github.com/owner/repo/pull/12 after PR #2238, #2238 and #7; see a&#39;b";
    expect(extractReferences(body, home, isHomeEntry).pullRequests).toEqual([
      "https://github.com/owner/repo/pull/12",
      "#2238",
      "#7",
    ]);
  });
});

describe("resolveEncodedPath", () => {
  const tree: Record<string, string[]> = {
    "/": ["Users"],
    "/Users": ["o.kazuki"],
    "/Users/o.kazuki": ["work", ".agents", "my-app", "my"],
    "/Users/o.kazuki/work": [],
    "/Users/o.kazuki/.agents": [],
    "/Users/o.kazuki/my-app": [],
    "/Users/o.kazuki/my": ["app2"],
    "/Users/o.kazuki/my/app2": [],
  };
  const listDirectoryNames = (directory: string) => tree[directory] ?? [];

  test("restores dots inside a directory name", () => {
    expect(resolveEncodedPath("-Users-o-kazuki-work", listDirectoryNames)).toBe("/Users/o.kazuki/work");
  });

  test("restores a leading dot from an empty token", () => {
    expect(resolveEncodedPath("-Users-o-kazuki--agents", listDirectoryNames)).toBe("/Users/o.kazuki/.agents");
  });

  test("tries both a separator and a hyphen inside a name", () => {
    expect(resolveEncodedPath("-Users-o-kazuki-my-app", listDirectoryNames)).toBe("/Users/o.kazuki/my-app");
    expect(resolveEncodedPath("-Users-o-kazuki-my-app2", listDirectoryNames)).toBe("/Users/o.kazuki/my/app2");
  });

  test("returns null when no existing directory matches", () => {
    expect(resolveEncodedPath("-Users-o-kazuki-gone", listDirectoryNames)).toBeNull();
  });
});

describe("extractSessionWorkingDirectory", () => {
  test("reads the first cwd field and unescapes it", () => {
    const head = '{"type":"x"}\n{"cwd":"/Users/someone/my \\"app\\"","sessionId":"1"}\n{"cwd":"/other"}';
    expect(extractSessionWorkingDirectory(head)).toBe('/Users/someone/my "app"');
  });

  test("returns null when there is no cwd field", () => {
    expect(extractSessionWorkingDirectory('{"type":"x"}')).toBeNull();
  });
});

describe("buildArchiveDirectory", () => {
  test("uses up to two levels below the home directory", () => {
    expect(buildArchiveDirectory("/Users/someone/work", home)).toBe("/Users/someone/.agents/work");
    expect(buildArchiveDirectory("/Users/someone/private/app/sub", home)).toBe("/Users/someone/.agents/private/app");
  });

  test("returns null outside the home directory", () => {
    expect(buildArchiveDirectory("/opt/project", home)).toBeNull();
  });
});

describe("convertToEditablePath", () => {
  const exists = (path: string) => path === "/Users/someone/dotfiles/unix/.claude/CLAUDE.md";

  test("keeps a real path outside the Nix store", () => {
    expect(
      convertToEditablePath({ path: "/Users/someone/work/CLAUDE.md", realPath: "/Users/someone/work/CLAUDE.md", home, exists }),
    ).toBe("/Users/someone/work/CLAUDE.md");
  });

  test("maps a home-manager managed file to its dotfiles source", () => {
    expect(
      convertToEditablePath({ path: "/Users/someone/.claude/CLAUDE.md", realPath: "/nix/store/abc-hm_CLAUDE.md", home, exists }),
    ).toBe("/Users/someone/dotfiles/unix/.claude/CLAUDE.md");
  });

  test("returns null when the dotfiles source does not exist", () => {
    expect(
      convertToEditablePath({ path: "/Users/someone/.config/x", realPath: "/nix/store/abc-x", home, exists }),
    ).toBeNull();
  });
});
