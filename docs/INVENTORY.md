# Inventory — Source Machine Snapshot (2026-08-26)

> Windows 11 — user PilzIndia — `C:/Users/PilzIndia` — full workstation clone (opencode + Claude Code + Codex + OmniRoute + FreeLLMAPI).

## Core versions (pinned — see tools/*)

| Tool | Version | Install |
|------|---------|---------|
| Node | 24.15.0 | nodejs.org / `winget install OpenJS.NodeJS` |
| npm | 11.13.0 | bundled |
| Bun | 1.3.14 | `bun.sh` / `npm i -g bun` |
| Git | 2.53.0.windows.3 | git-scm.com |
| GH CLI | 2.93.0 | cli.github.com |
| opencode-ai | 1.18.23 | `npm i -g opencode-ai` |
| @opencode-ai/cli | 0.0.0-beta-18155 | `npm i -g @opencode-ai/cli` |
| ponytail | 4.8.4 | `@dietrichgebert/ponytail` |
| @opencode-ai/plugin | 1.17.0 | opencode `~/.config/opencode/package.json` |
| oh-my-opencode-slim | 2.2.17 | `~/.config/opencode/.oh-my-opencode-slim/skills-manifest.json` |
| Claude Code | 2.1.241 | `npm i -g @anthropic-ai/claude-code` |
| Codex | (via npm) | `~/.codex` |
| OmniRoute | 3.8.49 | `npm i -g omniroute` |
| FreeLLMAPI | 0.4.0 (npx cache) → 0.5.0 latest | `npm i -g freellmapi` / `npx freellmapi@0.5.0` |
| Vercel | 54.18.5 | `npm i -g vercel` |
| Ruflo (claude-flow) | 3.10.46 | `npm i -g ruflo` |
| OpenClaw | 2026.6.9 | `npm i -g openclaw` |
| agent-browser | 0.29.1 | `npm i -g agent-browser` |

Global npm list (19): see `tools/global-npm-packages.txt`.

## Config files

| Repo path | Live path | Notes |
|-----------|-----------|-------|
| `config/opencode.json` | `~/.config/opencode/opencode.json` | model `google/gemini-2.5-flash`, `provider.freellmapi` 70+ models + `omniroute` 2, agents build/plan/general, mcp 8, permissions, server :3000, experimental batch_tool+otel |
| `config/cli.json` | `~/.config/opencode/cli.json` | theme `github`, plugins `oh-my-opencode-slim`, diffs/sessions |
| `config/tui.json` | `~/.config/opencode/tui.json` | theme `dark`, leader `ctrl+space`, editor/terminal/chat |
| `config/mcp-legacy.json` | (merged) | 14 `mcpServers` — merged into `mcp/manifest.unified.json` |
| `config/AGENTS.md` | `~/.config/opencode/AGENTS.md` | codebase-memory graph guidance |
| `config/package.json/.lock` | `~/.config/opencode/package.json` | ponytail + plugin |
| `config/.ponytail-active` | `~/.config/opencode/.ponytail-active` | `full` |
| `config/skills-manifest.json` | `~/.config/opencode/.oh-my-opencode-slim/skills-manifest.json` | 8 managed skills @2.2.17 |
| `config/skill-lock.json` | `~/.agents/.skill-lock.json` | v3 — 91 external skills |
| `claude/settings.json` | `~/.claude/settings.json` | env `ANTHROPIC_BASE_URL http://127.0.0.1:31415`, `ANTHROPIC_AUTH_TOKEN=${...}`, 177 `enabledPlugins`, hooks `cbm-*` + gsd |
| `claude/mcp.json` | `~/.claude/.mcp.json` | 2 servers: codebase-memory-mcp + firecrawl http |
| `claude/home-mcp.json.example` | `~/.mcp.json` | `claude-flow` ruflo v3 |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | ruflo + graphify |
| `codex/config.toml` | `~/.codex/config.toml` | `model_provider freellmapi http://127.0.0.1:31415/v1`, `wire_api responses`, `env_key FREELLMAPI_API_KEY`, mcp 2, hooks SessionStart |
| `codex/auth.json.example` | `~/.codex/auth.json` | redacted |
| `omniroute/.env.example` | `~/.omniroute/.env` | sanitized (`STORAGE_ENCRYPTION_KEY=${...}`) |
| `omniroute/upstream-.env.example` | (reference) | full 129 KB annotated contract from `node_modules/omniroute/.env.example` |
| `freellmapi/package.json` | (npx cache) | 0.4.0 |
| `freellmapi/keys.*.example` | `~/Desktop/freellmapi-keys.*` (source) | redacted templates |
| `qwen/settings.json.example` | `~/.qwen/settings.json` | redacted |
| `tools/global-npm-packages.txt` | `npm list -g` | snapshot |

## Agents

| Source | Repo | Live | Example |
|--------|------|------|---------|
| Opencode | `agents/` | `~/.config/opencode/agents/` | `3d-scene-developer.md … zk-steward.md` **237** (was 236, now 237 with latest scan) |
| Claude | `claude/agents/` | `~/.claude/agents/` | `academic-*, engineering-*, marketing-*, gsd-*, security-*, support-*, etc.` **268** |
| Codex | `codex/` also uses same `~/.codex` | |  |

Total **505 agents** tracked.

## Skills

| Scope | Repo | Live | Count |
|-------|------|------|-------|
| Opencode managed | `skills/opencode-managed/` | `~/.config/opencode/skills/` | **14** `clonedeps codemap deepwork graphify oh-my-opencode-slim rag-pipelines reflect simplify verification-planning worktrees zoho zoho-api zoho-creator zoho-crm-mcp` |
| External | `skills/external-full/` | `~/.agents/skills/` | **91** `mattpocock/* 28 + huggingface/* 18 + firecrawl/* 33 + vercel/* 6 + other` |
| Opencode symlinks | (33 firecrawl) | `~/.config/opencode/skills/firecrawl* -> ~/.agents/skills/firecrawl*` | **33** |
| Claude | `claude/skills/` | `~/.claude/skills/` | **222** dirs (2430 files) — `agentdb-* 5, gstack (pruned), firecrawl 33, gsd-* 40, vercel-optimize etc, huggingface-*, deploy-to-vercel ...` (gstack 510 MB binaries excluded; see BINARIES_EXCLUDED.md) |
| Codex | `codex/skills/` | `~/.codex/skills/` | **~75 files** `firecrawl* + zoho*` |
| Claude commands | `claude/commands/` | `~/.claude/commands/` | **161** `agents, analysis, automation, github, swarm ...` |
| Claude hooks | `claude/hooks/` | `~/.claude/hooks/` | **21** `cbm-* + gsd-*.js/*.sh` |
| Claude plugins | `claude/plugins/` | `~/.claude/plugins/` | **177 enabled** (see `claude/plugins/enabledPlugins.json` + `installed_plugins.json` 91 KB) |

## MCP servers (19 unified — see mcp/manifest.unified.json + docs/MCP.md)

Live 8 in `opencode.json:mcp`: `codebase-memory-mcp (binary 261 MB), firecrawl (http), filesystem (npx), github (npx), officecli (binary 33 MB), playwright (npx), twos-io, correctover`
Legacy 14 in `mcp-legacy.json`: `firecrawl, github, context7, playwright, vercel, linear, sentry, sequential-thinking, e2b, supabase, browser, skyvern, browserbase, stagehand` → merged 19 (duplicates deduped).
Claude `~/.claude/.mcp.json`: `codebase-memory-mcp, firecrawl`
Home `~/.mcp.json`: `claude-flow (ruflo v3 hierarchical-mesh)`
Codex `config.toml`: `[mcp_servers.codebase-memory-mcp + firecrawl]`

## Providers — the gateway architecture

```
FreeLLMAPI :31415  ── central ──►  Claude Code (ANTHROPIC_BASE_URL)
                ├─► Codex (model_provider freellmapi base_url .../v1)
                ├─► Opencode (provider freellmapi baseURL .../v1 apiKey {env:FREELLMAPI_API_KEY})
                └─► Qwen

OmniRoute :20128 ──► Opencode provider omniroute (baseURL http://localhost:20128/v1 apiKey ${OMNIROUTE_API_KEY}) — 2 models
                └─► also wired as claude gateway discovery (CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1)

Gemini model: google/gemini-2.5-flash (default + small)
```

Freellmapi setup (installer runs):

```bash
npx freellmapi setup-claude   --url http://127.0.0.1:31415  # writes ~/.claude/settings.json env
npx freellmapi setup-codex    --url http://127.0.0.1:31415  # writes ~/.codex/config.toml
npx freellmapi setup-opencode --url http://127.0.0.1:31415  # writes opencode.json provider.freellmapi
npx freellmapi setup-qwen     --url http://127.0.0.1:31415
```

70+ FreeLLMAPI models include `fusion, kimi-k2.7-code, minimax-m3, glm-5.2, kimi-k2.6, qwen3-coder-480b, qwen3-coder-next, deepseek-v4-flash, deepseek-r1, deepseek-v3.2, gpt-oss-120b, qwen3-vl-235b, nemotron-3-ultra, llama-4-maverick, nemotron-3-super, ...` (full list in `config/opencode.json` provider.freellmapi.models — 73 entries)

## Permissions / server / experimental (opencode.json)

```json
"permission": { "read":"allow","write":"ask","edit":"ask","bash":"ask","glob":"allow","grep":"allow","list":"allow","task":"ask","external_directory":"deny","webfetch":"ask","websearch":"ask" },
"server": { "port":3000,"hostname":"127.0.0.1","mdns":false },
"experimental": { "disable_paste_summary":false,"batch_tool":true,"openTelemetry":true },
"default_agent":"build","username":"Harsh","shell":"bash","logLevel":"INFO","snapshot":true,
"plugin": ["@dietrichgebert/ponytail","oh-my-opencode-slim","@devtheops/opencode-plugin-otel","opencode-copilot-auth","opencode-models-discovery"]
```

Claude `settings.json`: `model claude-fable-5`, hooks `PreToolUse Grep|Glob -> cbm-code-discovery-gate`, `SessionStart startup|resume|clear|compact -> cbm-session-reminder`, `SubagentStart -> cbm-subagent-reminder`, `enabledPlugins 177`, `extraKnownMarketplaces ecc https://github.com/affaan-m/ECC`.

## Tools — local binaries (platform-specific)

| Binary | Source file | Size | New machine |
|--------|-------------|------|-------------|
| `codebase-memory-mcp.exe` | `~/.local/bin/codebase-memory-mcp.exe` | 261 MB | Rebuild per OS: `cargo build` or download appropriate asset |
| `graphify.exe` / `graphify-mcp.exe` | `~/.local/bin/` | 45 KB | platform specific — rebuild |
| `officecli.exe` | `~/bin/officecli.exe` | 33 MB | `npm i -g officecli` or releases |
| `specify.exe` / `nano-pdf.exe` | `~/.local/bin/` | 45 KB | npm packages |
| `python3.11.exe` | `~/.local/bin/` | | via python.org |

All require path patching from `C:/Users/PilzIndia/...` → `~/.local/bin/...` (installer does it). See `tools/local-bin-list.txt` + `tools/local-binaries/README.md`.

## Repo layout (65 MB)

```
agents/                  237 agents
claude/{agents,skills,commands,hooks,plugins}   268/222/161/21 (+gstack pruned)
codex/                   config.toml + skills 75 files
config/                  14 files (opencode + cli + tui + mcp-legacy + manifests)
skills/{opencode-managed 14 + external-full 91}  105 distinct
omniroute/               .env.example + upstream 129 KB
freellmapi/              README + package.json + redacted keys
mcp/                     manifest.unified.json 19
tools/                   versions + globals pinned
scripts/{install,verify,bootstrap,capture + lib/patch-config + capture-full.mjs}
docs/{INVENTORY,INSTALL,ENV_VARS,MCP,TROUBLESHOOTING}
```

## How to re-capture on source

```bash
node scripts/lib/capture-full.mjs  # or: ./scripts/capture.sh
du -sh .                         # check ~65 MB (if 500+ MB, gstack binaries re-added — prune)
git add -A && git commit -m "chore: snapshot $(date -I)" && git push
```
