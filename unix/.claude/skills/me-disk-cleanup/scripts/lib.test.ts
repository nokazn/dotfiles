import { describe, expect, test } from "bun:test";
import {
  buildTmpRow,
  classifyTmpEntry,
  collapseOpenPathsToEntries,
  convertDockerSizeToKilobytes,
  findUnknownCategories,
  formatKilobytes,
  formatRow,
  isProtectedTmpName,
  parseBuildCacheKilobytes,
  parseDuOutput,
  parseLsofNames,
  readThresholds,
  selectLargeLeafDirectories,
  sumUnreferencedDockerSizes,
} from "./lib.ts";

const thresholds = readThresholds({});

describe("readThresholds", () => {
  test("uses defaults when environment variables are unset", () => {
    expect(thresholds).toEqual({
      tmpDays: 1,
      tmpLargeKilobytes: 1048576,
      cacheDays: 30,
      nixDays: 7,
      surveyKilobytes: 2097152,
    });
  });

  test("overrides defaults with environment variables", () => {
    expect(readThresholds({ CLEANUP_TMP_DAYS: "3", CLEANUP_SURVEY_KB: "0" })).toMatchObject({ tmpDays: 3, surveyKilobytes: 0 });
  });

  test("rejects values that are not non-negative integers", () => {
    expect(() => readThresholds({ CLEANUP_TMP_DAYS: "1.5" })).toThrow("CLEANUP_TMP_DAYS");
    expect(() => readThresholds({ CLEANUP_CACHE_DAYS: "-1" })).toThrow("CLEANUP_CACHE_DAYS");
  });
});

describe("findUnknownCategories", () => {
  test("returns only names that are not categories", () => {
    expect(findUnknownCategories(["tmp", "tmp-review", "docker", "survey"])).toEqual(["tmp-review", "docker"]);
  });
});

describe("formatKilobytes", () => {
  test.each([
    [0, "0K"],
    [1023, "1023K"],
    [1024, "1.0M"],
    [1536, "1.5M"],
    [1048576, "1.0G"],
    [1024 ** 4, "1024.0T"],
  ])("%d KB is shown as %s", (kilobytes, expected) => {
    expect(formatKilobytes(kilobytes)).toBe(expected);
  });
});

describe("formatRow", () => {
  test("formats a row as TSV", () => {
    expect(formatRow({ category: "npm", sizeInKilobytes: 2048, target: "/cache", note: "note" })).toBe("npm\t2048\t2.0M\t/cache\tnote");
  });

  test("shows unknown size as a dash", () => {
    expect(formatRow({ category: "nix", sizeInKilobytes: null, target: "nix store", note: "" })).toBe("nix\t-\t-\tnix store\t");
  });
});

describe("convertDockerSizeToKilobytes", () => {
  test.each([
    ["0B", 0],
    ["1024B", 1],
    ["1.024kB", 1],
    ["77.03MB", 75224],
    ["4.799GB", 4686523],
    ["unknown", 0],
    ["12XB", 0],
  ])("%s is %d KB", (size, expected) => {
    expect(convertDockerSizeToKilobytes(size)).toBe(expected);
  });
});

describe("sumUnreferencedDockerSizes", () => {
  test("sums only entries referenced by no container", () => {
    expect(sumUnreferencedDockerSizes("0 1.024MB\n2 10GB\n0 2.048MB\n\n")).toEqual({ count: 2, totalKilobytes: 3000 });
  });
});

describe("parseBuildCacheKilobytes", () => {
  test("reads the size of the build cache line", () => {
    const output = "Images\t1.024GB\nBuild Cache\t2.048MB\nLocal Volumes\t0B";
    expect(parseBuildCacheKilobytes(output)).toBe(2000);
  });

  test("returns 0 when there is no build cache line", () => {
    expect(parseBuildCacheKilobytes("Images\t0B")).toBe(0);
  });
});

describe("parseLsofNames", () => {
  test("extracts only file name fields", () => {
    expect(parseLsofNames("p123\nfcwd\nn/tmp/a\nf3\nn/var/tmp/b c\n")).toEqual(["/tmp/a", "/var/tmp/b c"]);
  });
});

describe("collapseOpenPathsToEntries", () => {
  test("collapses open paths to the entry directly under each root", () => {
    const entries = collapseOpenPathsToEntries(["/tmp/a/b/c", "/tmp/a/d", "/tmp/e", "/tmpx/f", "/cache/g/h", "/other"], ["/tmp", "/cache"]);
    expect([...entries].toSorted()).toEqual(["/cache/g", "/tmp/a", "/tmp/e"]);
  });
});

describe("isProtectedTmpName", () => {
  test.each([".hidden", "claude-1234", "cc-socks", "com.apple.launchd", "systemd-private-x", "tmux-501", "ssh-agent", "snap-private-tmp"])(
    "%s is protected",
    (name) => {
      expect(isProtectedTmpName(name)).toBe(true);
    },
  );

  test.each(["build", "cc-socks-old", "node-compile-cache"])("%s is not protected", (name) => {
    expect(isProtectedTmpName(name)).toBe(false);
  });
});

describe("classifyTmpEntry", () => {
  test("treats entries without recent files as stale regardless of size", () => {
    expect(classifyTmpEntry({ hasRecentFile: false, sizeInKilobytes: 0, thresholds })).toBe("stale");
  });

  test("treats recent entries at or above the large threshold as large", () => {
    expect(classifyTmpEntry({ hasRecentFile: true, sizeInKilobytes: thresholds.tmpLargeKilobytes, thresholds })).toBe("large");
  });

  test("ignores recent entries below the large threshold", () => {
    expect(classifyTmpEntry({ hasRecentFile: true, sizeInKilobytes: thresholds.tmpLargeKilobytes - 1, thresholds })).toBeNull();
  });
});

describe("buildTmpRow", () => {
  const base = { entry: "/tmp/a", sizeInKilobytes: 10, thresholds };

  test("stale entries without git risk are deletable tmp rows", () => {
    expect(buildTmpRow({ ...base, kind: "stale", gitRisk: "" })).toEqual({
      category: "tmp",
      sizeInKilobytes: 10,
      target: "/tmp/a",
      note: "older than 1d",
    });
  });

  test("stale entries with git risk need review", () => {
    expect(buildTmpRow({ ...base, kind: "stale", gitRisk: "git-dirty:/tmp/a" })).toMatchObject({ category: "tmp-review", note: "git-dirty:/tmp/a" });
  });

  test("large entries carry git risk as their note", () => {
    expect(buildTmpRow({ ...base, kind: "large", gitRisk: "" })).toMatchObject({ category: "tmp-large", note: "" });
  });
});

describe("parseDuOutput", () => {
  test("parses size and path, keeping tabs-free paths with spaces", () => {
    expect(parseDuOutput("12\t/a b\n\nbroken\n34\t/c\n")).toEqual([
      { sizeInKilobytes: 12, path: "/a b" },
      { sizeInKilobytes: 34, path: "/c" },
    ]);
  });
});

describe("selectLargeLeafDirectories", () => {
  test("keeps only the deepest directories above the threshold, largest first", () => {
    const directories = [
      { sizeInKilobytes: 100, path: "/home" },
      { sizeInKilobytes: 60, path: "/home/a" },
      { sizeInKilobytes: 50, path: "/home/a/b" },
      { sizeInKilobytes: 30, path: "/home/ab" },
      { sizeInKilobytes: 5, path: "/home/c" },
    ];
    expect(selectLargeLeafDirectories(directories, 30)).toEqual([
      { sizeInKilobytes: 50, path: "/home/a/b" },
      { sizeInKilobytes: 30, path: "/home/ab" },
    ]);
  });
});
