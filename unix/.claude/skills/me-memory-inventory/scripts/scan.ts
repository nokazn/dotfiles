#!/usr/bin/env bun

import { existsSync, readdirSync, realpathSync, statSync } from "node:fs";
import { open, readFile, readdir, stat } from "node:fs/promises";
import { homedir } from "node:os";
import { basename, dirname, join } from "node:path";
import {
  buildArchiveDirectory,
  convertToEditablePath,
  expandHome,
  extractLinks,
  extractReferences,
  extractSessionWorkingDirectory,
  findIndexProblems,
  parseFrontmatter,
  parseIndex,
  resolveEncodedPath,
} from "./lib.ts";

const home = homedir();
const configDirectory = process.env.CLAUDE_CONFIG_DIR ?? join(home, ".claude");
const projectsDirectory = join(configDirectory, "projects");
const INSTRUCTION_FILE_NAMES = ["CLAUDE.md", "CLAUDE.local.md", join(".claude", "CLAUDE.md")];
const SESSION_LOG_HEAD_BYTES = 65536;

type FileLocation = { path: string; editablePath: string | null };

function describeLocation(path: string): FileLocation {
  return {
    path,
    editablePath: convertToEditablePath({ path, realPath: realpathSync(path), home, exists: existsSync }),
  };
}

function isDirectory(path: string): boolean {
  try {
    return statSync(path).isDirectory();
  } catch {
    return false;
  }
}

function listDirectoryNames(directory: string): string[] {
  try {
    return readdirSync(directory).filter((name) => isDirectory(join(directory, name)));
  } catch {
    return [];
  }
}

async function readSessionWorkingDirectory(projectDirectory: string): Promise<string | null> {
  const logs = (await readdir(projectDirectory)).filter((name) => name.endsWith(".jsonl"));
  const logsByNewest = await Promise.all(
    logs.map(async (name) => ({ name, modifiedAt: (await stat(join(projectDirectory, name))).mtimeMs })),
  );
  for (const { name } of logsByNewest.sort((left, right) => right.modifiedAt - left.modifiedAt)) {
    const handle = await open(join(projectDirectory, name));
    try {
      const { buffer, bytesRead } = await handle.read(Buffer.alloc(SESSION_LOG_HEAD_BYTES), 0, SESSION_LOG_HEAD_BYTES, 0);
      const workingDirectory = extractSessionWorkingDirectory(buffer.subarray(0, bytesRead).toString("utf8"));
      if (workingDirectory !== null) {
        return workingDirectory;
      }
    } finally {
      await handle.close();
    }
  }
  return null;
}

async function resolveProjectPath(projectDirectory: string) {
  const fromSession = await readSessionWorkingDirectory(projectDirectory);
  if (fromSession !== null) {
    return { projectPath: fromSession, projectPathSource: "session-log" as const };
  }
  const fromName = resolveEncodedPath(basename(projectDirectory), listDirectoryNames);
  return fromName === null
    ? { projectPath: null, projectPathSource: null }
    : { projectPath: fromName, projectPathSource: "directory-name" as const };
}

function findInstructionFiles(projectPath: string | null): FileLocation[] {
  if (projectPath === null) {
    return [];
  }
  const ancestors = projectPath
    .split("/")
    .map((_, index, segments) => segments.slice(0, index + 1).join("/") || "/");
  return ancestors.flatMap((directory) =>
    INSTRUCTION_FILE_NAMES.map((name) => join(directory, name))
      .filter((path) => existsSync(path))
      .map(describeLocation),
  );
}

async function scanMemory(memoryDirectory: string, file: string) {
  const path = join(memoryDirectory, file);
  const [text, stats] = await Promise.all([readFile(path, "utf8"), stat(path)]);
  const { fields, body } = parseFrontmatter(text);
  const references = extractReferences(body, home, (name) => existsSync(join(home, name)));
  return {
    file,
    ...describeLocation(path),
    name: fields.name ?? null,
    description: fields.description ?? null,
    type: fields.type ?? null,
    modifiedAt: stats.mtime.toISOString(),
    sizeBytes: stats.size,
    links: extractLinks(body),
    pathReferences: references.paths.map((reference) => ({
      path: reference,
      exists: existsSync(expandHome(reference, home)),
    })),
    pullRequestReferences: references.pullRequests,
  };
}

async function scanStore(projectDirectory: string) {
  const memoryDirectory = join(projectDirectory, "memory");
  const { projectPath, projectPathSource } = await resolveProjectPath(projectDirectory);
  const files = (await readdir(memoryDirectory)).filter((name) => name.endsWith(".md") && name !== "MEMORY.md").sort();
  const indexPath = join(memoryDirectory, "MEMORY.md");
  const indexText = existsSync(indexPath) ? await readFile(indexPath, "utf8") : null;
  const entries = indexText === null ? [] : parseIndex(indexText);
  const memories = await Promise.all(files.map((file) => scanMemory(memoryDirectory, file)));
  const linkTargets = new Set(memories.flatMap((memory) => [memory.name, memory.file.replace(/\.md$/, "")]));

  return {
    memoryDirectory,
    projectPath,
    projectPathSource,
    archiveDirectory: projectPath === null ? null : buildArchiveDirectory(projectPath, home),
    instructionFiles: findInstructionFiles(projectPath),
    index: {
      path: indexText === null ? null : indexPath,
      lineCount: indexText === null ? 0 : indexText.split("\n").length,
      entries,
      ...findIndexProblems(entries, files),
    },
    memories: memories.map(({ links, ...memory }) => ({
      ...memory,
      links: links.map((name) => ({ name, resolved: linkTargets.has(name) })),
    })),
  };
}

async function scanSkills() {
  const skillsDirectory = join(configDirectory, "skills");
  if (!existsSync(skillsDirectory)) {
    return [];
  }
  const names = (await readdir(skillsDirectory)).filter((name) => name.startsWith("me-")).sort();
  return Promise.all(
    names
      .map((name) => join(skillsDirectory, name, "SKILL.md"))
      .filter((path) => existsSync(path))
      .map(async (path) => ({
        name: basename(dirname(path)),
        description: parseFrontmatter(await readFile(path, "utf8")).fields.description ?? null,
        ...describeLocation(path),
      })),
  );
}

async function main() {
  const projectDirectories = existsSync(projectsDirectory)
    ? (await readdir(projectsDirectory))
        .map((name) => join(projectsDirectory, name))
        .filter((directory) => existsSync(join(directory, "memory")))
        .sort()
    : [];
  const globalInstructionPath = join(configDirectory, "CLAUDE.md");
  const report = {
    home,
    configDirectory,
    globalInstructions: existsSync(globalInstructionPath) ? describeLocation(globalInstructionPath) : null,
    skills: await scanSkills(),
    stores: await Promise.all(projectDirectories.map(scanStore)),
  };
  console.log(JSON.stringify(report, null, 2));
}

await main();
