# Tools — What's Installed & What's Needed

## Global npm (19 pinned — see tools/global-npm-packages.txt)

| Package | Version at capture | Install on new machine |
|---------|-------------------|------------------------|
| `opencode-ai` | 1.18.23 | `npm i -g opencode-ai@1.18.23` |
| `@opencode-ai/cli` | 0.0.0-beta-18155 | `npm i -g @opencode-ai/cli@0.0.0-beta-18155` |
| `@anthropic-ai/claude-code` | 2.1.241 | `npm i -g @anthropic-ai/claude-code@2.1.241` |
| `omniroute` | 3.8.49 | `npm i -g omniroute@3.8.49` |
| `freellmapi` | 0.4.0 cached → **0.5.0 latest** | `npm i -g freellmapi@0.5.0` (was npx cached at `AppData/Local/npm-cache/_npx/e995436d190f44dd`) |
| `vercel` | 54.18.5 | `npm i -g vercel@54.18.5` |
| `ruflo` (claude-flow) | 3.10.46 | `npm i -g ruflo@3.10.46` |
| `openclaw` | 2026.6.9 | `npm i -g openclaw@2026.6.9` |
| `agent-browser` | 0.29.1 | `npm i -g agent-browser@0.29.1` |
| `firecrawl-cli` | 1.20.0 | `npm i -g firecrawl-cli@1.20.0` |
| `bun` | 1.3.14 | `curl -fsSL https://bun.sh/install \| bash` or `npm i -g bun@1.3.14` |
| `sass` | 1.101.0 | `npm i -g sass@1.101.0` |
| `pnpm` | 11.20.0 | `npm i -g pnpm@11.20.0` |
| `@kilocode/cli` | 7.3.45 | `npm i -g @kilocode/cli@7.3.45` |
| `bobshell` | 1.0.4 | `npm i -g bobshell@1.0.4` |
| `skills` | 1.5.21 | `npm i -g skills@1.5.21` |
| `zcatalyst-cli` | 1.25.3 | `npm i -g zcatalyst-cli@1.25.3` |
| `zoho-extension-toolkit` | 1.0.28 | `npm i -g zoho-extension-toolkit@1.0.28` |

Installer handles these (`--skip-globals` to skip, `--latest` to float). Verify file: `tools/global-npm-packages.txt`.

## Local runtime versions (pinned — see tools/*-version.txt)

| Tool | Version |
|------|---------|
| Node | 24.15.0 |
| npm | 11.13.0 |
| Bun | 1.3.14 |
| Git | 2.53.0.windows.3 |
| GH CLI | 2.93.0 |
| Ruflo | 3.10.46 |
| OpenClaw | 2026.6.9 |
| Vercel | 54.18.5 |

## Local binaries (platform-specific — NOT in repo, need rebuild per OS)

| Binary | Source path (Windows) | Size | New machine |
|--------|----------------------|------|-------------|
| `codebase-memory-mcp.exe` | `~/.local/bin/codebase-memory-mcp.exe` | 261 MB | Build per OS or download matching asset — see `tools/local-binaries/README.md` + `mcp/manifest.unified.json` notes. Used by opencode+claude+codex MCP. |
| `graphify.exe` / `graphify-mcp.exe` | `~/.local/bin/` | 45 KB | Platform specific |
| `officecli.exe` | `~/bin/officecli.exe` | 33 MB | `npm i -g officecli` or GitHub releases |
| `specify.exe`, `nano-pdf.exe`, `python3.11.exe` | `~/.local/bin/` | 45 KB | npm packages |

Full listing in `tools/local-bin-list.txt`.

## Gateways — not global npm but daemon processes

| Service | Port | Package | Start |
|---------|------|---------|-------|
| **OmniRoute** | 20128 | `omniroute@3.8.49` global | `omniroute` or `omniroute start` (reads `~/.omniroute/.env`) |
| **FreeLLMAPI** | 31415 | `freellmapi@0.5.0` global or npx cache | `npx freellmapi serve --port 31415` or `freellmapi start` (reads `FREELLMAPI_API_KEY`) |

## What the installer checks

`./scripts/verify.sh` checks all of the above: node/npm/bun/git/gh, `opencode`, `claude`, `codex`, `omniroute`, `freellmapi`, `vercel`, `ruflo`, `openclaw`, `agent-browser`, agents counts, skills counts, MCP files, gateway reachability, env keys.

## What is NOT needed on the new machine

- Docker (not used)
- Python `pip` packages (none required for opencode/claude — only if you re-derive `omniroute` from source)
- `sqlite3` binary (only for inspecting `~/.omniroute/storage.sqlite` — optional)

## Update tools

```bash
# On source after you update globals:
npm list -g --depth=0 > tools/global-npm-packages.txt
node --version > tools/node-version.txt
# etc. — or: node scripts/lib/capture-full.mjs
git add tools/ && git commit -m "chore: tools snapshot" && git push
```
