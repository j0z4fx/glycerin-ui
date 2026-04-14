---
name: roblox-creator-docs
description: Use when the task needs answers, code, or explanations grounded in the official Roblox Creator Docs for building Roblox experiences. This skill mirrors the full create.roblox.com documentation source tree under content/en-us as a docs-first knowledge corpus, including Luau docs, guides, tutorials, engine reference, and cloud reference.
---

# Roblox Creator Docs

This skill packages the official Roblox Creator Docs as local reference files. The mirrored source comes from the official `Roblox/creator-docs` repository under `content/en-us`, which is the source tree that powers the public docs experience for Roblox creators.

## Use This Skill When

- The user asks how to build a Roblox game, system, UI, avatar flow, animation setup, monetization flow, production workflow, or cloud integration using official Roblox documentation.
- The user needs Luau language docs, scripting guides, Studio guidance, tutorials, engine API reference, or Open Cloud reference.
- The user wants the latest official docs mirrored locally before working offline.
- The task needs a fast local search across the official Creator Docs corpus instead of ad hoc browsing.

## Local Sources

- Start with [references/creator-docs-index.md](references/creator-docs-index.md) to see the mirrored scope, source commit, top-level sections, and search shortcuts.
- The mirrored docs tree lives under `references/creator-docs/content/en-us/`.
- Engine API reference lives under `references/creator-docs/content/en-us/reference/engine/`.
- Open Cloud and web API reference lives under `references/creator-docs/content/en-us/reference/cloud/`.
- The local mirror is knowledge-only by default, so binary-heavy media such as videos and downloadable assets are excluded.
- Source metadata lives in `references/source-metadata.json`.
- The source repository license lives in `references/source-license.txt`.
- The repository code license lives in `references/source-license-code.txt`.

## Workflow

1. Open `references/creator-docs-index.md` and identify the relevant section.
2. Search within `references/creator-docs/content/en-us/` to find the exact page, YAML reference file, or JSON reference file you need.
3. Read the mirrored source file directly before answering or coding.
4. If the user asks for the newest docs, refresh the mirror first with `node scripts/sync-roblox-creator-docs.mjs`.
5. When the task is about engine members, prefer the exact YAML or JSON reference files under `reference/`.

## Coverage

The mirror targets the full official `content/en-us` tree from `Roblox/creator-docs`, including:

- Root docs pages such as platform overviews and creator entry points.
- Guide sections such as `get-started`, `scripting`, `studio`, `projects`, `production`, `physics`, `ui`, `audio`, `characters`, `chat`, `avatar`, `marketplace`, and more.
- Curriculum and tutorial content under `tutorials/`.
- The complete Luau docs section under `luau/`.
- The engine reference under `reference/engine/`, including class YAML for services like `TextService`.
- The cloud reference under `reference/cloud/`, including OpenAPI and product-specific JSON files.
- Default sync excludes binary-heavy media such as videos and other downloadable assets so the local mirror stays fast and bandwidth-friendly.

## Search Shortcuts

Use ripgrep to keep context small and load only the pages you need:

```powershell
rg -n "TextService|LocalizationService|TextChatService" references/creator-docs/content/en-us
rg -n "DataStoreService|MemoryStoreService|MessagingService" references/creator-docs/content/en-us
rg -n "strict|type alias|union|intersection|generic|type pack" references/creator-docs/content/en-us/luau
rg -n "ScreenGui|TextLabel|UIListLayout|TweenService" references/creator-docs/content/en-us
rg -n "Humanoid|Animator|AnimationTrack|Motor6D" references/creator-docs/content/en-us
rg -n "PathfindingService|Raycast|Constraint|CollisionGroup" references/creator-docs/content/en-us
```

## Refresh

Run this from the skill folder:

```powershell
node scripts/sync-roblox-creator-docs.mjs
```

The refresh script downloads the official GitHub zip snapshot for `Roblox/creator-docs`, mirrors `content/en-us/` into `references/creator-docs/content/en-us/`, and prunes binary-heavy media so the result stays focused on searchable docs and reference data. Every run updates `references/source-metadata.json` and regenerates `references/creator-docs-index.md`.

## Notes

- This skill mirrors the official Creator Docs source tree, not the Developer Forum or undocumented engine behavior.
- Keep `SKILL.md` lean; the full content belongs in `references/creator-docs/content/en-us/`.
- If Roblox adds or removes docs upstream, rerun the sync script to update coverage.
- The local mirror is intentionally docs-first. If you need video or downloadable sample assets, that would require a separate asset fetch path outside this skill.
