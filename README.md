# opencode-portable-setup — Full Workstation Clone

> **One repo → identical workstation on any machine.** Your exact Harsh stack: **Opencode (237 agents, 105 skills, 19 MCP, 70+ models)** + **Claude Code (268 agents, 222 skills, 161 commands, 21 hooks, 177 plugins)** + **Codex** + **OmniRoute :20128** + **FreeLLMAPI :31415** + gemini/qwen stubs — with one installer.

Captured **2026-08-26** from Windows 11 (PilzIndia) — Node 24.15.0 · npm 11.13.0 · Bun 1.3.14 · Git 2.53 · GH CLI 2.93 · `opencode-ai@1.18.23` · `@opencode-ai/cli@0.0.0-beta-18155` · `ponytail@4.8.4` · `oh-my-opencode-slim@2.2.17` · `@anthropic-ai/claude-code@2.1.241` · `omniroute@3.8.49` · `freellmapi@0.4.0 → 0.5.0` · `vercel@54.18.5` · `ruflo@3.10.46` · `openclaw@2026.6.9`

Repo size: **~65 MB** (gstack 510 MB binaries pruned, see `claude/skills/gstack/BINARIES_EXCLUDED.md` — auto-rebuilt on install)

---

## ⚡ Quick Start

### Windows (PowerShell)

```powershell
git clone https://github.com/harshvardhankulkarni/opencode-portable-setup.git
cd opencode-portable-setup
Copy-Item .env.example .env    # <- fill keys (see below)
notepad .env                   # GITHUB_TOKEN, FIRECRAWL_API_KEY, FREELLMAPI_API_KEY, ANTHROPIC_AUTH_TOKEN, OMNIROUTE_API_KEY
notepad $HOME\.omniroute\.env  # STORAGE_ENCRYPTION_KEY / JWT_SECRET / API_KEY_SECRET / INITIAL_PASSWORD (from omniroute/.env.example)
Copy-Item freellmapi-keys.json ./freellmapi-keys.json  # <- your 21-provider bundle (upload here, gitignored) — see docs/FREELLMAPI_KEYS.md
node scripts/lib/import-freellmapi-keys.mjs --check  # validates 21 keys (masked, never prints raw)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\install.ps1            # add -Force to overwrite, -Latest to float versions, -Verbose for logs
.\scripts\verify.ps1             # health check (versions, 510 agents, MCP, :20128, :31415, env, + freellmapi-keys 21)
# start gateways in separate terminals:
omniroute                        # :20128 dashboard
npx freellmapi serve --port 31415
opencode                         # TUI :3000
claude                           # -> FreeLLMAPI auto
```

### macOS / Linux

```bash
git clone https://github.com/harshvardhankulkarni/opencode-portable-setup.git
cd opencode-portable-setup
cp .env.example .env && nano .env
# also:
cp omniroute/.env.example ~/.omniroute/.env && nano ~/.omniroute/.env
cp ~/Downloads/freellmapi-keys.json ./freellmapi-keys.json  # <- your 21-provider bundle (gitignored)
node scripts/lib/import-freellmapi-keys.mjs --check  # validates 21 keys (masked, never prints raw)
chmod +x scripts/install.sh scripts/verify.sh
./scripts/install.sh             # --force / --latest / --verbose
./scripts/verify.sh              # also checks freellmapi-keys 21
# gateways:
omniroute &                      # :20128
npx freellmapi serve --port 31415 &
opencode
claude
```

### One-liners (after you push)

```bash
# Linux/macOS
curl -fsSL https://raw.githubusercontent.com/harshvardhankulkarni/opencode-portable-setup/main/scripts/bootstrap.sh | bash
# Windows
irm https://raw.githubusercontent.com/harshvardhankulkarni/opencode-portable-setup/main/scripts/bootstrap.ps1 | iex
```

---

## 🧠 AI Agent Prompt (paste on a fresh machine)

```
You are on a fresh machine. Clone and install my full workstation:

1. git clone https://github.com/harshvardhankulkarni/opencode-portable-setup.git && cd opencode-portable-setup
2. Read README.md, docs/INVENTORY.md, docs/INSTALL.md, docs/ENV_VARS.md, docs/MCP.md, mcp/README.md, freellmapi/README.md, claude/settings.json, codex/config.toml
3. Run the installer:
   - Windows: powershell -ExecutionPolicy Bypass -File scripts/install.ps1 -Verbose
   - Linux/macOS: bash scripts/install.sh --verbose
   It backs up any existing ~/.config/opencode, ~/.claude, ~/.codex, ~/.omniroute, ~/.agents/skills
4. Ensure .env is created from .env.example — prompt the human for missing keys (GITHUB_TOKEN, FIRECRAWL_API_KEY, FREELLMAPI_API_KEY, ANTHROPIC_AUTH_TOKEN, OMNIROUTE_API_KEY, STORAGE_ENCRYPTION_KEY etc). Never hardcode secrets. Also ensure ~/.omniroute/.env from omniroute/.env.example.
   Also: freellmapi-keys.json — this is the 21-provider bundle the user will upload (to ./freellmapi-keys.json or ./freellmapi/keys.json, both gitignored). Validate with `node scripts/lib/import-freellmapi-keys.mjs --check` (masked). If missing, warn and point to docs/FREELLMAPI_KEYS.md.
5. Patch paths: installer auto-rewrites Windows hardcoded paths (C:/Users/PilzIndia/...) -> $HOME/.local/bin etc via scripts/lib/patch-config.mjs. If a local binary (codebase-memory-mcp.exe, officecli.exe, graphify) is missing, report which MCP will be disabled and where to get it (tools/local-binaries/README.md + mcp/manifest.unified.json).
6. Restore:
   - opencode: 237 agents -> ~/.config/opencode/agents/, 14 managed skills -> ~/.config/opencode/skills/, 91 external -> ~/.agents/skills/, 33 firecrawl symlinks, skill-lock + oh-my manifest, npm install ponytail+plugin, pinned globals (opencode-ai@1.18.23, @opencode-ai/cli, etc.)
   - claude: 268 agents -> ~/.claude/agents/, 222 skills (dereferenced, .git excluded) -> ~/.claude/skills/, 161 commands -> ~/.claude/commands/, 21 hooks -> ~/.claude/hooks/, plugins inventories, settings.json (ANTHROPIC_BASE_URL -> :31415) + .mcp.json (codebase-memory-mcp + firecrawl)
   - codex: config.toml -> ~/.codex/config.toml (freellmapi provider + mcp), skills -> ~/.codex/skills/
   - omniroute: ~/.omniroute/.env, freellmapi via `npx freellmapi setup-{claude,codex,opencode,qwen} --url http://127.0.0.1:31415`
7. npm i -g pinned globals from tools/global-npm-packages.txt (opencode-ai, @opencode-ai/cli, @anthropic-ai/claude-code, omniroute@3.8.49, freellmapi@0.5.0, bun, vercel, openclaw, ruflo, agent-browser, etc). Use --latest to float.
8. Run scripts/verify.sh (or .ps1) and report: node/opencode/claude/codex/omniroute/freellmapi versions, agents counts (237+268), skills counts (14/91/222), mcp connectivity, :20128 and :31415 reachability, env keys.
9. If anything fails, consult docs/TROUBLESHOOTING.md and propose a precise fix with commands.

Do not skip steps. Do not invent configs. All real secrets are in .env (gitignored) — only templates are in repo.
```

---

## 📦 What is inside

```
.
├── config/                  # opencode verbatim (opencode.json: 2 providers+70 models,3 agents,mcp8,permissions,server,experimental)
│   ├── opencode.json        # main — model google/gemini-2.5-flash, providers omniroute(2)+freellmapi(70+), agents build/plan/general
│   ├── cli.json             # theme github, plugins oh-my-opencode-slim, diffs, session
│   ├── tui.json             # theme dark, layout, keybindings leader ctrl+space, editor/terminal/chat
│   ├── mcp-legacy.json      # legacy 14 mcpServers (merged)
│   ├── AGENTS.md            # codebase-memory graph guidance (search_graph > trace_path)
│   ├── package.json/.lock   # ponytail 4.8.4 + @opencode-ai/plugin 1.17.0
│   ├── skills-manifest.json # oh-my-opencode-slim 2.2.17 — 8 skills
│   ├── skill-lock.json      # .agents lock v3 — 91 external skills
│   └── .ponytail-active     # full
├── agents/           237    # opencode subagents (3d-scene-developer … zk-steward)
├── skills/
│   ├── opencode-managed/ 14 # clonedeps,codemap,deepwork,graphify,oh-my-opencode-slim,rag-pipelines,reflect,simplify,verification-planning,worktrees,zoho*4
│   └── external-full/ 91    # all ~/.agents/skills — mattpocock/* 28 + huggingface/* 18 + firecrawl/*33 + vercel/*6 + other
├── claude/                  # Claude Code full clone
│   ├── settings.json        # sanitized (ANTHROPIC_BASE_URL=http://127.0.0.1:31415, ANTHROPIC_AUTH_TOKEN=${...}, 177 enabledPlugins)
│   ├── mcp.json             # sanitized (codebase-memory-mcp + firecrawl remote, FIRECRAWL_API_KEY=${...})
│   ├── CLAUDE.md            # ruflo + graphify hooks
│   ├── agents/      268     # academic-*, engineering-*, marketing-*, gsd-*, security-*, etc.
│   ├── skills/      222 dirs (2430 files) — agentdb-*, gstack (pruned), firecrawl/*, gsd-*, vercel/*, huggingface-*, etc.
│   ├── commands/    161     # agents/*, analysis/*, automation/*, github/*, swarm/*, etc.
│   ├── hooks/       21      # cbm-code-discovery-gate, cbm-session-reminder, gsd-*.js/*.sh
│   └── plugins/             # installed_plugins.json (91 KB) + enabledPlugins.json + marketplaces
├── codex/                   # Codex
│   ├── config.toml          # freellmapi provider (base_url http://127.0.0.1:31415/v1) + mcp codebase-memory + firecrawl + hooks
│   ├── auth.json.example    # redacted
│   ├── AGENTS.md
│   └── skills/ ~117 files   # firecrawl/*, zoho* etc.
├── omniroute/               # OmniRoute :20128
│   ├── .env.example         # sanitized (STORAGE_ENCRYPTION_KEY=${...})
│   └── upstream-.env.example # full 129 KB annotated contract (PORT 20128, JWT_SECRET etc.)
├── freellmapi/              # FreeLLMAPI :31415 (central gateway for Claude/Codex/Opencode/Qwen)
│   ├── README.md            # wiring table, install, setup-* commands, troubleshooting
│   ├── package.json         # freellmapi 0.4.0 (npx cache) — latest 0.5.0
│   ├── keys.{json,csv}.example # redacted templates (21 providers)
│   └── (on new machine) freellmapi-keys.json — your REAL 21-key bundle (upload here, gitignored) — see docs/FREELLMAPI_KEYS.md
├── gemini/ qwen/ kilocode/  # stubs + source-layout + sanitized settings/.env examples
├── mcp/
│   ├── README.md            # live vs legacy + portability notes
│   └── manifest.unified.json # 19 merged servers
├── tools/
│   ├── global-npm-packages.txt # 19 globals pinned
│   ├── local-bin-list.txt      # .local/bin + bin (codebase-memory-mcp.exe 261 MB etc.)
│   └── local-binaries/README.md
├── scripts/
│   ├── install.sh/.ps1      # 13-step full-stack installer (idempotent, backups, patching, globals, freellmapi setup-*)
│   ├── verify.sh/.ps1       # health check (versions, 510 agents, skills, mcp, :20128/:31415, env)
│   ├── bootstrap.sh/.ps1    # curl|bash one-liners
│   ├── capture.sh           # wrapper for capture-full.mjs
│   └── lib/{patch-config,capture-full}.mjs
├── docs/ INVENTORY.md INSTALL.md ENV_VARS.md MCP.md TROUBLESHOOTING.md
├── .env.example             # unified template (FreeLLMAPI + OmniRoute + MCP + optional)
└── .github/workflows/verify.yml
```

**Counts:** opencode 237 agents + Claude 268 = **505 agents**, skills `14 + 91 + 222 dirs (2400 files) + codex 75`, MCP `8+14=19`, models `70+ freellmapi +2 omniroute`, plugins `177 enabled`, commands `161`, hooks `21`, globals `19 pinned`.

---

## 🔑 Environment — what to fill

```bash
cp .env.example .env            # repo root — opencode/MCP/claude/codex keys
cp omniroute/.env.example ~/.omniroute/.env  # OmniRoute server secrets
nano .env
nano ~/.omniroute/.env
# then: set -a; source .env; set +a   (or source .env.loader.sh created by installer)
```

| Variable | Used in | Required | Get |
|----------|---------|----------|-----|
| `FREELLMAPI_API_KEY` | opencode `freellmapi` provider, codex `env_key`, freellmapi gateway | **yes** | your FreeLLMAPI dashboard — see `docs/FREELLMAPI_KEYS.md` (per-provider where-to-get) + 21-key `freellmapi-keys.json` bundle |
| `ANTHROPIC_AUTH_TOKEN` | Claude Code `~/.claude/settings.json` env | **yes** | same gateway token as above but as `freellmapi-...` — written by `npx freellmapi setup-claude` |
| `freellmapi-keys.json` | 21 provider keys (agnes/aion/bai/cerebras/cloudflare/github/google/groq/huggingface/llm7/nvidia/ollama/opencode/openrouter/orcarouter/pollinations/reka/requesty/routeway/siliconflow/zhipu) | **yes** for 70+ models | upload your real `freellmapi-keys.json` to `./freellmapi-keys.json` (gitignored) — `node scripts/lib/import-freellmapi-keys.mjs --check` — full per-provider table in `docs/FREELLMAPI_KEYS.md` |
| `GITHUB_TOKEN` | mcp.github (`npx @modelcontextprotocol/server-github`) | yes for github MCP | https://github.com/settings/tokens — scopes `repo workflow read:org gist` or `gh auth login` |
| `FIRECRAWL_API_KEY` | mcp.firecrawl (`https://mcp.firecrawl.dev/v2/mcp`) in opencode+claude+codex | yes for firecrawl | https://firecrawl.dev → API keys |
| `OMNIROUTE_API_KEY` | opencode provider `omniroute` | if using omniroute | your OmniRoute instance (local `omniroute` dashboard → API keys) |
| `STORAGE_ENCRYPTION_KEY` | `~/.omniroute/.env` | yes — OmniRoute server | `openssl rand -hex 32` |
| `JWT_SECRET` | `~/.omniroute/.env` | yes | `openssl rand -base64 48` |
| `API_KEY_SECRET` | `~/.omniroute/.env` | yes | `openssl rand -hex 32` |
| `INITIAL_PASSWORD` | `~/.omniroute/.env` | yes | change from `CHANGEME` |

Optional MCP: `VERCEL_TOKEN`, `LINEAR_API_KEY`, `SENTRY_AUTH_TOKEN`, `E2B_API_KEY`, `SUPABASE_*`, `BROWSERBASE_*`, `SKYVERN_API_KEY` — see `.env.example` + `docs/ENV_VARS.md`.

> Never commit `.env` — it is `.gitignore`'d. Only `*.example` files are in repo.

---

## 🛠️ Installer behavior (13 steps)

Both `install.sh` and `install.ps1`:

1. Prereqs — `node>=20 npm git` required, `gh bun pnpm vercel` optional
2. Backups — `~/.config/opencode`, `~/.agents/skills`, `~/.claude`, `~/.codex`, `~/.omniroute` → `*.backup-<timestamp>` ( `--no-backup` to skip)
3. Globals — `npm i -g` pinned from `tools/global-npm-packages.txt` (`opencode-ai@1.18.23`, `@opencode-ai/cli`, `@anthropic-ai/claude-code@2.1.241`, `omniroute@3.8.49`, `freellmapi@0.5.0`, `vercel`, `openclaw`, `agent-browser`, `ruflo`, `bun`, `sass`, `pnpm`, `bobshell`, …) — use `--latest` to float
4. Dirs — ensure all `~/.config/opencode`, `~/.agents/skills`, `~/.claude/{agents,skills,commands,hooks}`, `~/.codex`, `~/.omniroute`, `~/.local/bin`
5. Opencode configs — copy with path patching (`scripts/lib/patch-config.mjs`) — `C:/Users/PilzIndia/...` → `$HOME`
6. `npm install` in `~/.config/opencode` (ponytail + plugin)
7. Opencode agents (237) + skills (14 managed + 91 external) + 33 firecrawl symlinks (Windows falls back to junction/copy if Developer Mode off)
8. Claude Code — `settings.json` (sanitized `${ANTHROPIC_AUTH_TOKEN}`), `.mcp.json` (sanitized firecrawl key), `CLAUDE.md`, **268 agents**, **222 skills** (dereferenced, `.git` excluded), **161 commands**, **21 hooks**, plugins inventories, `~/.mcp.json` (ruflo claude-flow)
9. Codex — `config.toml` + skills
10. OmniRoute — `~/.omniroute/.env` from template (if missing)
11. Gateways — `npx freellmapi setup-{claude,codex,opencode,qwen} --url http://127.0.0.1:31415` (if `freellmapi`/`npx freellmapi` available)
12. Env file — `cp .env.example .env` if missing + loader ` .env.loader.sh`
13. Verify — auto-runs `scripts/verify.sh --quick`

Idempotent — safe to run multiple times. Use `--force` to overwrite without prompts.

---

## ✅ Verify

```bash
./scripts/verify.sh --verbose    # or .\scripts\verify.ps1 on Windows
```

Checks: `node opencode claude codex omniroute freellmapi` versions, `~/.config/opencode/agents` 237, `claude/agents` 268, `claude/skills` 222 dirs, `codex/skills`, `mcp` entries, `filesystem` allowed dir, `GITHUB_TOKEN`/`FIRECRAWL_API_KEY` set, `ANTHROPIC_AUTH_TOKEN`, reachability `:20128` and `:31415`, `.env` populated.

---

## 🔄 Updating this repo (on source machine)

```bash
node scripts/lib/capture-full.mjs   # re-snapshot opencode+claude+codex+omniroute+freellmapi+gemini/qwen
# or: ./scripts/capture.sh
git add -A && git commit -m "chore: snapshot $(date -I)" && git push
# then on targets:
git pull && ./scripts/install.sh --force && ./scripts/verify.sh
```

---

## 🧩 Manual fallback

See `docs/INSTALL.md` → Manual fallback for copy-paste commands per OS.

---

## 📄 License

MIT — see `LICENSE`. Secrets are **never** committed.

---

## 🙏 Credits

Built from Harsh's live Windows workstation 2026-08-26. Pruned `claude/skills/gstack` binaries for size — see `BINARIES_EXCLUDED.md`; rebuilt via `npm run build` after install.

> After `gh repo create`, replace `harshvardhankulkarni` with your GitHub handle everywhere (`README`, `scripts/bootstrap.*`).
