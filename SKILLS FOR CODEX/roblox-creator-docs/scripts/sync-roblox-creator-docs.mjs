import { cp, mkdir, mkdtemp, readdir, readFile, rm, stat, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";

const REPO_OWNER = "Roblox";
const REPO_NAME = "creator-docs";
const REF = "main";
const SOURCE_PREFIX = "content/en-us";
const SNAPSHOT_URL = `https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/zip/refs/heads/${REF}`;
const KNOWLEDGE_EXTENSIONS = new Set([".md", ".yaml", ".json"]);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const skillRoot = path.resolve(__dirname, "..");
const referencesRoot = path.join(skillRoot, "references");
const creatorDocsRoot = path.join(referencesRoot, "creator-docs");
const mirrorRoot = path.join(creatorDocsRoot, "content", "en-us");
const metadataPath = path.join(referencesRoot, "source-metadata.json");
const indexPath = path.join(referencesRoot, "creator-docs-index.md");
const licensePath = path.join(referencesRoot, "source-license.txt");
const licenseCodePath = path.join(referencesRoot, "source-license-code.txt");
const readmePath = path.join(referencesRoot, "source-readme.md");

function ensureInside(basePath, targetPath) {
  const resolvedBase = path.resolve(basePath);
  const resolvedTarget = path.resolve(targetPath);
  if (
    resolvedTarget !== resolvedBase &&
    !resolvedTarget.startsWith(`${resolvedBase}${path.sep}`)
  ) {
    throw new Error(`Refusing to operate outside ${resolvedBase}: ${resolvedTarget}`);
  }
}

function quoteForPowerShell(value) {
  return `'${String(value).replaceAll("'", "''")}'`;
}

async function run(command, args, options = {}) {
  const { cwd } = options;

  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd,
      stdio: ["ignore", "pipe", "pipe"],
      windowsHide: true,
    });

    let stdout = "";
    let stderr = "";

    child.stdout.on("data", (chunk) => {
      stdout += chunk.toString();
    });

    child.stderr.on("data", (chunk) => {
      stderr += chunk.toString();
    });

    child.on("error", reject);
    child.on("close", (code) => {
      if (code === 0) {
        resolve({ stdout, stderr });
        return;
      }

      const details = [stdout.trim(), stderr.trim()].filter(Boolean).join("\n");
      reject(
        new Error(
          `Command failed (${command} ${args.join(" ")}): exit ${code}${details ? `\n${details}` : ""}`,
        ),
      );
    });
  });
}

async function fetchBytes(url) {
  const response = await fetch(url, {
    headers: {
      "User-Agent": "codex-roblox-creator-docs-sync",
      Accept: "*/*",
    },
  });

  if (!response.ok) {
    throw new Error(`Request failed for ${url}: ${response.status} ${response.statusText}`);
  }

  return Buffer.from(await response.arrayBuffer());
}

async function fetchJson(url) {
  const response = await fetch(url, {
    headers: {
      "User-Agent": "codex-roblox-creator-docs-sync",
      Accept: "application/vnd.github+json",
    },
  });

  if (!response.ok) {
    throw new Error(`Request failed for ${url}: ${response.status} ${response.statusText}`);
  }

  return response.json();
}

async function expandZip(zipPath, destinationPath) {
  const command = [
    "Expand-Archive",
    "-LiteralPath",
    quoteForPowerShell(zipPath),
    "-DestinationPath",
    quoteForPowerShell(destinationPath),
    "-Force",
  ].join(" ");

  await run("powershell", ["-NoProfile", "-Command", command]);
}

async function getSingleChildDirectory(parentDir) {
  const entries = await readdir(parentDir, { withFileTypes: true });
  const directories = entries.filter((entry) => entry.isDirectory());
  if (directories.length !== 1) {
    throw new Error(`Expected exactly one extracted directory in ${parentDir}`);
  }
  return path.join(parentDir, directories[0].name);
}

function parseFrontmatter(markdown) {
  const match = markdown.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
  if (!match) {
    return {};
  }

  const data = {};
  for (const line of match[1].split(/\r?\n/)) {
    const entry = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (!entry) {
      continue;
    }
    let value = entry[2].trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    data[entry[1]] = value;
  }
  return data;
}

function formatBytes(bytes) {
  if (bytes >= 1024 * 1024) {
    return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
  }
  if (bytes >= 1024) {
    return `${(bytes / 1024).toFixed(2)} KB`;
  }
  return `${bytes} B`;
}

async function pruneNonKnowledgeFiles(rootDir) {
  let removedCount = 0;

  function shouldKeepFile(entryName) {
    const extension = path.extname(entryName).toLowerCase() || "[no-ext]";
    if (KNOWLEDGE_EXTENSIONS.has(extension)) {
      return true;
    }
    return extension === "[no-ext]" && entryName === "STUDIO_VERSION";
  }

  async function walk(currentDir) {
    const entries = await readdir(currentDir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isDirectory()) {
        await walk(fullPath);
        const remaining = await readdir(fullPath).catch(() => []);
        if (remaining.length === 0) {
          await rm(fullPath, { recursive: true, force: true });
        }
        continue;
      }

      if (!entry.isFile()) {
        continue;
      }

      if (!shouldKeepFile(entry.name)) {
        await rm(fullPath, { force: true });
        removedCount += 1;
      }
    }
  }

  await walk(rootDir);
  return removedCount;
}

async function collectFiles(rootDir) {
  const files = [];

  async function walk(currentDir) {
    const entries = await readdir(currentDir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isDirectory()) {
        await walk(fullPath);
        continue;
      }

      if (!entry.isFile()) {
        continue;
      }

      const fileStat = await stat(fullPath);
      const relativePath = path.relative(rootDir, fullPath).replaceAll("\\", "/");
      const sourcePath = `${SOURCE_PREFIX}/${relativePath}`;
      const extension = path.extname(relativePath).toLowerCase() || "[no-ext]";
      const section = relativePath.includes("/") ? relativePath.split("/")[0] : "[root]";

      const record = {
        localPath: path.relative(referencesRoot, fullPath).replaceAll("\\", "/"),
        relativePath,
        sourcePath,
        sourceUrl: `https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REF}/${sourcePath}`,
        htmlUrl: `https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/${REF}/${sourcePath}`,
        extension,
        size: fileStat.size,
        section,
      };

      if (extension === ".md") {
        const frontmatter = parseFrontmatter(await readFile(fullPath, "utf8"));
        record.title = frontmatter.title ?? "";
        record.description = frontmatter.description ?? "";
      }

      files.push(record);
    }
  }

  await walk(rootDir);
  files.sort((a, b) => a.relativePath.localeCompare(b.relativePath));
  return files;
}

function buildIndexLines(metadata) {
  const studioVersionSingle = metadata.studioVersion
    ? metadata.studioVersion.split(/\r?\n/)[0]
    : "unknown";

  const rootPages = metadata.files
    .filter((file) => !file.relativePath.includes("/"))
    .map((file) => `- \`${file.relativePath}\`${file.title ? ` - ${file.title}` : ""}`);

  return [
    "# Roblox Creator Docs Index",
    "",
    "Local mirror of the official Roblox Creator Docs knowledge corpus for building Roblox experiences.",
    "",
    "- `Roblox/creator-docs` is the source repo.",
    "- `content/en-us` is the mirrored path.",
    "- `main` is the source ref.",
    `- Commit: \`${metadata.commitSha}\``,
    `- Synced at (UTC): \`${metadata.syncedAtUtc}\``,
    `- File count: \`${metadata.fileCount}\``,
    `- Total size: \`${formatBytes(metadata.totalBytes)}\``,
    `- Media mode: \`${metadata.mediaMode}\``,
    `- LFS pointer files present: \`${metadata.lfsPointerCount}\``,
    `- Non-knowledge binary files pruned: \`${metadata.prunedBinaryFileCount}\``,
    `- Studio version marker: \`${studioVersionSingle}\``,
    "- Docs content license: `source-license.txt`",
    "- Repository code license: `source-license-code.txt`",
    "",
    "## Key Areas",
    "",
    "- `creator-docs/content/en-us/get-started/` - onboarding and first-experience setup",
    "- `creator-docs/content/en-us/luau/` - Luau language docs",
    "- `creator-docs/content/en-us/scripting/` - scripting guides and patterns",
    "- `creator-docs/content/en-us/reference/engine/` - engine API reference, including services such as `TextService`",
    "- `creator-docs/content/en-us/reference/cloud/` - Open Cloud and web API reference",
    "- `creator-docs/content/en-us/tutorials/` - end-to-end tutorials and curricula",
    "- `creator-docs/content/en-us/studio/` - Studio tooling and workflows",
    "- `creator-docs/content/en-us/production/` - publishing, operations, analytics, and growth",
    "",
    "## Root Pages",
    "",
    ...(rootPages.length ? rootPages : ["- None"]),
    "",
    "## Top-Level Sections",
    "",
    ...metadata.topLevelSections.map(
      (section) =>
        `- \`${section.name}\` - ${section.count} files, ${formatBytes(section.bytes)}`,
    ),
    "",
    "## Search Examples",
    "",
    "```powershell",
    'rg -n "TextService|TextLabel|TextChatService" references/creator-docs/content/en-us',
    'rg -n "DataStoreService|MemoryStoreService|MessagingService" references/creator-docs/content/en-us',
    'rg -n "Humanoid|Animator|AnimationTrack|Motor6D" references/creator-docs/content/en-us',
    'rg -n "ScreenGui|UIListLayout|UIGradient|TweenService" references/creator-docs/content/en-us',
    'rg -n "PathfindingService|Raycast|Constraint|CollisionGroup" references/creator-docs/content/en-us',
    'rg -n "TeleportService|Matchmaking|ReserveServer" references/creator-docs/content/en-us',
    "```",
    "",
    "PowerShell fallback when `rg` is unavailable:",
    "",
    "```powershell",
    "Get-ChildItem -Recurse -File references/creator-docs/content/en-us |",
    '  Select-String -Pattern "TextService|DataStoreService|Humanoid"',
    "```",
    "",
    "This mirror excludes binary-heavy media and downloadable assets so the result stays fast and docs-focused.",
    "For the full machine-readable inventory, read `source-metadata.json`.",
    "",
  ];
}

async function main() {
  ensureInside(skillRoot, referencesRoot);
  ensureInside(skillRoot, creatorDocsRoot);
  ensureInside(skillRoot, mirrorRoot);

  await mkdir(referencesRoot, { recursive: true });

  const tempRoot = await mkdtemp(path.join(os.tmpdir(), "roblox-creator-docs-"));
  const zipPath = path.join(tempRoot, `${REPO_NAME}-${REF}.zip`);
  const extractRoot = path.join(tempRoot, "extract");

  try {
    await writeFile(zipPath, await fetchBytes(SNAPSHOT_URL));
    await mkdir(extractRoot, { recursive: true });
    await expandZip(zipPath, extractRoot);

    const extractedRepoRoot = await getSingleChildDirectory(extractRoot);

    await rm(creatorDocsRoot, { recursive: true, force: true });
    await mkdir(path.dirname(mirrorRoot), { recursive: true });
    await cp(path.join(extractedRepoRoot, "content", "en-us"), mirrorRoot, {
      recursive: true,
      force: true,
      preserveTimestamps: true,
    });

    const prunedBinaryFileCount = await pruneNonKnowledgeFiles(mirrorRoot);

    await cp(path.join(extractedRepoRoot, "LICENSE"), licensePath, { force: true });
    await cp(path.join(extractedRepoRoot, "LICENSE-CODE"), licenseCodePath, { force: true });
    await cp(path.join(extractedRepoRoot, "README.md"), readmePath, { force: true });

    const branch = await fetchJson(
      `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/branches/${REF}`,
    );
    const commitSha = branch.commit.sha;

    const files = await collectFiles(mirrorRoot);
    const totalBytes = files.reduce((sum, file) => sum + file.size, 0);

    const sectionSummary = new Map();
    const extensionSummary = new Map();
    for (const file of files) {
      const section = sectionSummary.get(file.section) ?? { count: 0, bytes: 0 };
      section.count += 1;
      section.bytes += file.size;
      sectionSummary.set(file.section, section);

      const extension = extensionSummary.get(file.extension) ?? { count: 0, bytes: 0 };
      extension.count += 1;
      extension.bytes += file.size;
      extensionSummary.set(file.extension, extension);
    }

    const studioVersion = await readFile(
      path.join(mirrorRoot, "reference", "engine", "STUDIO_VERSION"),
      "utf8",
    )
      .then((value) => value.trim())
      .catch(() => "");

    const metadata = {
      sourceRepo: `${REPO_OWNER}/${REPO_NAME}`,
      ref: REF,
      commitSha,
      mirroredPath: SOURCE_PREFIX,
      mediaMode: "knowledge-only",
      syncedAtUtc: new Date().toISOString(),
      fileCount: files.length,
      totalBytes,
      lfsPointerCount: 0,
      prunedBinaryFileCount,
      studioVersion,
      topLevelSections: [...sectionSummary.entries()]
        .map(([name, summary]) => ({ name, ...summary }))
        .sort((a, b) => a.name.localeCompare(b.name)),
      extensionSummary: [...extensionSummary.entries()]
        .map(([extension, summary]) => ({ extension, ...summary }))
        .sort((a, b) => a.extension.localeCompare(b.extension)),
      files,
    };

    await writeFile(metadataPath, `${JSON.stringify(metadata, null, 2)}\n`, "utf8");
    await writeFile(indexPath, `${buildIndexLines(metadata).join("\n")}\n`, "utf8");

    console.log(
      `Mirrored ${metadata.fileCount} files from ${metadata.sourceRepo}@${metadata.commitSha} (${formatBytes(metadata.totalBytes)}; media mode: ${metadata.mediaMode})`,
    );
  } finally {
    await rm(tempRoot, { recursive: true, force: true }).catch(() => {});
  }
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack : String(error));
  process.exitCode = 1;
});
