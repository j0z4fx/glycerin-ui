# Roblox Creator Docs Index

Local mirror of the official Roblox Creator Docs knowledge corpus for building Roblox experiences.

- `Roblox/creator-docs` is the source repo.
- `content/en-us` is the mirrored path.
- `main` is the source ref.
- Commit: `0a2389cb77f58c1c6fb486e3b55a36888e3b7cc2`
- Synced at (UTC): `2026-04-14T16:24:30.258Z`
- File count: `2223`
- Total size: `17.85 MB`
- Media mode: `knowledge-only`
- LFS pointer files present: `0`
- Non-knowledge binary files pruned: `6603`
- Studio version marker: `0.716.0.7160873`
- Docs content license: `source-license.txt`
- Repository code license: `source-license-code.txt`

## Key Areas

- `creator-docs/content/en-us/get-started/` - onboarding and first-experience setup
- `creator-docs/content/en-us/luau/` - Luau language docs
- `creator-docs/content/en-us/scripting/` - scripting guides and patterns
- `creator-docs/content/en-us/reference/engine/` - engine API reference, including services such as `TextService`
- `creator-docs/content/en-us/reference/cloud/` - Open Cloud and web API reference
- `creator-docs/content/en-us/tutorials/` - end-to-end tutorials and curricula
- `creator-docs/content/en-us/studio/` - Studio tooling and workflows
- `creator-docs/content/en-us/production/` - publishing, operations, analytics, and growth

## Root Pages

- `affiliates.md` - Creator Affiliate Program
- `ai-data-sharing.md` - AI data sharing
- `assets.md` - Create and access millions of assets
- `creation.md` - Creation overview
- `creator-hub.md` - Creator Hub
- `creator-rewards.md` - Creator Rewards
- `discovery.md` - Discovery
- `experiences.md` - Get started with experiences on Roblox
- `generative-AI.md` - Experiences with Generative AI
- `platform.md` - The social 3D creation platform
- `safety.md` - How you can help us make Roblox safer
- `scale.md` - Reach a massive global audience
- `unity.md` - Roblox for Unity developers
- `unreal.md` - Roblox for Unreal developers
- `what-is-roblox.md` - What is Roblox?

## Top-Level Sections

- `[root]` - 15 files, 141.70 KB
- `animation` - 8 files, 120.95 KB
- `art` - 109 files, 949.67 KB
- `assistant` - 4 files, 19.39 KB
- `audio` - 4 files, 48.40 KB
- `avatar` - 5 files, 64.77 KB
- `avatar-setup` - 4 files, 36.04 KB
- `characters` - 10 files, 88.74 KB
- `chat` - 11 files, 83.30 KB
- `cloud` - 28 files, 206.98 KB
- `cloud-services` - 20 files, 207.13 KB
- `creator-programs` - 20 files, 47.82 KB
- `education` - 167 files, 768.24 KB
- `effects` - 6 files, 71.38 KB
- `environment` - 7 files, 41.95 KB
- `get-started` - 8 files, 77.87 KB
- `includes` - 31 files, 43.33 KB
- `input` - 5 files, 47.47 KB
- `ip-licensing` - 6 files, 57.26 KB
- `luau` - 22 files, 135.98 KB
- `makeup` - 4 files, 35.13 KB
- `marketplace` - 10 files, 98.56 KB
- `matchmaking` - 6 files, 48.51 KB
- `parts` - 8 files, 185.65 KB
- `performance-optimization` - 11 files, 108.50 KB
- `physics` - 29 files, 120.55 KB
- `players` - 9 files, 64.71 KB
- `production` - 104 files, 986.85 KB
- `projects` - 25 files, 263.24 KB
- `reference` - 1255 files, 9.48 MB
- `resources` - 52 files, 689.13 KB
- `scripting` - 21 files, 187.72 KB
- `sound` - 4 files, 35.69 KB
- `studio` - 25 files, 285.03 KB
- `tutorials` - 135 files, 1.78 MB
- `ui` - 28 files, 292.81 KB
- `workspace` - 7 files, 82.55 KB

## Search Examples

```powershell
rg -n "TextService|TextLabel|TextChatService" references/creator-docs/content/en-us
rg -n "DataStoreService|MemoryStoreService|MessagingService" references/creator-docs/content/en-us
rg -n "Humanoid|Animator|AnimationTrack|Motor6D" references/creator-docs/content/en-us
rg -n "ScreenGui|UIListLayout|UIGradient|TweenService" references/creator-docs/content/en-us
rg -n "PathfindingService|Raycast|Constraint|CollisionGroup" references/creator-docs/content/en-us
rg -n "TeleportService|Matchmaking|ReserveServer" references/creator-docs/content/en-us
```

PowerShell fallback when `rg` is unavailable:

```powershell
Get-ChildItem -Recurse -File references/creator-docs/content/en-us |
  Select-String -Pattern "TextService|DataStoreService|Humanoid"
```

This mirror excludes binary-heavy media and downloadable assets so the result stays fast and docs-focused.
For the full machine-readable inventory, read `source-metadata.json`.

