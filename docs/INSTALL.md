# Installation — Step by Step

> Full portable Harsh workstation: **opencode (236 agents, 105 skills, 19 MCP)** + **Claude Code (274 agents, 222 skills, 177 plugins)** + **Codex** + **OmniRoute :20128** + **FreeLLMAPI :31415** + gemini/qwen/kilocode.

## 1. Prerequisites (all OS)

| Tool | Minimum | How to get |
|------|---------|------------|
| Node | 20+ (you had 24.15.0) | https://nodejs.org or `nvm install 22` or `brew install node` or `winget install OpenJS.NodeJS` |
| npm | 11+ | bundled with Node |
| Git | any | https://git-scm.com / `brew install git` / `winget install Git.Git` |
| GitHub CLI `gh` | optional but strongly recommended | https://cli.github.com — needed for `github` MCP & repo ops |
| Bun | optional, recommended | `curl -fsSL https://bun.sh/install \| bash` or `npm i -g bun@1.3.14` |

Check:

```bash
node --version; npm --version; bun --version; git --version; gh --version
```

## 2. Clone

```bash
git clone https://github.com/harshvardhankulkarni/opencode-portable-setup.git
cd opencode-portable-setup
```

On Windows:

```powershell
git clone https://github.com/harshvardhankulkarni/opencode-portable-setup.git
cd opencode-portable-setup
```

## 3. Env file

```bash
cp .env.example .env
nano .env   # or notepad .env on Windows
```

Fill **at minimum**:

- `FREELLMAPI_API_KEY` + `ANTHROPIC_AUTH_TOKEN` (same FreeLLMAPI gateway — Claude reads `ANTHROPIC_AUTH_TOKEN`)
- `GITHUB_TOKEN` (for github MCP)
- `FIRECRAWL_API_KEY` (for firecrawl MCP)

OmniRoute needs its own secrets (for `~/.omniroute/.env`): see `omniroute/.env.example` + `omniroute/upstream-.env.example`. The installer copies `omniroute/.env.example -> ~/.omniroute/.env` and prompts for `STORAGE_ENCRYPTION_KEY` etc. Generate:

```bash
openssl rand -hex 32   # STORAGE_ENCRYPTION_KEY
openssl rand -base64 48 # JWT_SECRET
openssl rand -hex 32   # API_KEY_SECRET
```

Never commit `.env` — it is gitignored.

## 4. Run the installer

### Linux / macOS

```bash
chmod +x scripts/install.sh scripts/verify.sh
./scripts/install.sh              # interactive
# flags:
# --force        overwrite without prompts, skip version checks
# --no-backup    do not backup existing ~/.config/opencode
# --latest       install latest npm globals instead of pinned versions
# --skip-globals skip npm i -g
# --verbose      extra logs
# --skip-mcp-bin skip local binary checks
./scripts/install.sh --force --verbose
```

### Windows (PowerShell)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\install.ps1              # interactive
# flags:
# -Force  -NoBackup  -Latest  -SkipGlobals  -Verbose  -SkipMcpBin
.\scripts\install.ps1 -Force -Verbose
```

### What the installer does (9 steps)

1. **Prereqs** — checks Node/npm/Git/gh/bun versions
2. **Backups** — `~/.config/opencode -> ~/.config/opencode.backup-<ts>`, `~/.agents/skills -> backup`, `~/.claude -> backup` (disable with `--no-backup`)
3. **Global npm packages (pinned)** — installs via `tools/global-npm-packages.txt`:
   `opencode-ai@1.18.23`, `@opencode-ai/cli@0.0.0-beta-18155`, `@anthropic-ai/claude-code@2.1.241`, `omniroute@3.8.49`, `freellmapi@0.5.0`, `vercel@54.18.5`, `openclaw@2026.6.9`, `agent-browser@0.29.1`, `ruflo@3.10.46`, `bun@1.3.14`, etc. Use `--latest` to float.
4. **Dirs** — ensures `~/.config/opencode`, `~/.agents/skills`, `~/.claude/{agents,skills,commands,hooks}`, `~/.codex`, `~/.omniroute`, `~/.local/bin`
5. **Configs (with path patching)** — copies `config/* -> ~/.config/opencode/*` via `scripts/lib/patch-config.mjs` which rewrites Windows hardcoded paths (`C:/Users/PilzIndia/...`) -> `$HOME` / `~/.local/bin`. Same for `claude/settings.json` env placeholders + `claude/mcp.json` firecrawl redaction + `codex/config.toml` base URLs.
6. **npm install** in `~/.config/opencode` — installs `ponytail@4.8.4` + `@opencode-ai/plugin@1.17.0` + other plugin deps.
7. **Agents** — `agents/ (236) -> ~/.config/opencode/agents/`, `claude/agents/ (274) -> ~/.claude/agents/`
8. **Skills** —
   - `skills/opencode-managed (14) -> ~/.config/opencode/skills/`
   - `skills/external-full (91) -> ~/.agents/skills/`
   - `claude/skills (222 tops) -> ~/.claude/skills/` (dereferenced, .git excluded)
   - `codex/skills (~~59) -> ~/.codex/skills/`
   - recreates 33 `firecrawl*` symlinks: `~/.config/opencode/skills/firecrawl* -> ~/.agents/skills/firecrawl*` (on Windows uses `New-Item -ItemType SymbolicLink` with fallback to copy/junction if Developer Mode off)
   - restores `claude/commands (148) -> ~/.claude/commands`, `claude/hooks (23) -> ~/.claude/hooks`, `claude/plugins/*.json` inventory
   - restores `.oh-my-opencode-slim` + `~/.agents/.skill-lock.json`
9. **Wire gateways** — runs:
   ```bash
   npx freellmapi setup-claude  --url http://127.0.0.1:31415
   npx freellmapi setup-codex   --url http://127.0.0.1:31415
   npx freellmapi setup-opencode --url http://127.0.0.1:31415
   npx freellmapi setup-qwen    --url http://127.0.0.1:31415
   ```
   and copies `omniroute/.env.example -> ~/.omniroute/.env` (if missing). On next launch you set passwords/keys there.

Idempotent — safe to run multiple times.

## 5. Env loader

```bash
# Linux/macOS
set -a; source .env; set +a
# or
source .env.loader.sh

# Windows PowerShell
Get-Content .env | ForEach-Object { if($_ -match '^([^#=]+)=(.*)$'){ Set-Item -Path Env:$($matches[1]) -Value $matches[2] } }
```

## 6. Start gateways

```bash
# Terminal 1: OmniRoute (port 20128)
omniroute        # or: omniroute start    # dashboard at http://localhost:20128
# first run will ask INITIAL_PASSWORD — use the one from ~/.omniroute/.env

# Terminal 2: FreeLLMAPI (port 31415) — if running as separate daemon
npx freellmapi serve --port 31415   # or: freellmapi start
curl http://127.0.0.1:31415/v1/models -H "Authorization: Bearer $FREELLMAPI_API_KEY" | head
curl http://127.0.0.1:20128/v1/models -H "Authorization: Bearer $OMNIROUTE_API_KEY" | head
```

On the source machine these were long-running in the background (not systemd). On the new machine pick one:

- foreground `tmux`/`screen`
- `pm2 start "omniroute" --name omniroute`
- `systemd` (Linux) / `launchd` (macOS) — see `docs/TROUBLESHOOTING.md`

## 7. Verify

```bash
./scripts/verify.sh           # Linux/macOS
# or
.\scripts\verify.ps1          # Windows
```

Expected:

- `opencode --version` >= 1.18
- `claude --version` >= 2.1.241
- `codex --version` (whatever you had)
- `agents counts` 236 + 274
- `skills` 14 + 91 + 222
- `mcp` filesystem/github/playwright ok, firecrawl/github need tokens
- `omniroute :20128` reachable, `freellmapi :31415` reachable when running

## 8. Launch

```bash
opencode              # TUI at http://127.0.0.1:3000
claude                # Claude Code — should hit FreeLLMAPI, model "auto"
codex                 # Codex — same gateway
omniroute             # check dashboard
```

## Manual fallback (if scripts blocked)

```bash
# 1. opencode configs
mkdir -p ~/.config/opencode ~/.agents/skills
cp config/opencode.json ~/.config/opencode/opencode.json
node scripts/lib/patch-config.mjs --src ~/.config/opencode/opencode.json --home $HOME
cp config/cli.json config/tui.json config/AGENTS.md ~/.config/opencode/
cp config/package.json config/package-lock.json ~/.config/opencode/ && (cd ~/.config/opencode && npm install)
cp -r agents/* ~/.config/opencode/agents/
cp -r skills/opencode-managed/* ~/.config/opencode/skills/
cp -r skills/external-full/* ~/.agents/skills/
ln -sf ~/.agents/skills/firecrawl* ~/.config/opencode/skills/

# 2. claude
mkdir -p ~/.claude/{agents,skills,commands,hooks}
cp claude/settings.json ~/.claude/settings.json
cp claude/mcp.json ~/.claude/.mcp.json
cp claude/CLAUDE.md ~/.claude/CLAUDE.md
cp -r claude/agents/* ~/.claude/agents/
cp -r claude/skills/* ~/.claude/skills/
cp -r claude/commands/* ~/.claude/commands/
cp -r claude/hooks/* ~/.claude/hooks/

# 3. codex
mkdir -p ~/.codex
cp codex/config.toml ~/.codex/config.toml

# 4. gateways
npm i -g freellmapi@0.5.0 omniroute@3.8.49
npx freellmapi setup-claude --url http://127.0.0.1:31415
npx freellmapi setup-codex --url http://127.0.0.1:31415
npx freellmapi setup-opencode --url http://127.0.0.1:31415
cp omniroute/.env.example ~/.omniroute/.env   # then edit
```

## Updating later

On **source** after you change agents/skills/configs:

```bash
node scripts/lib/capture-full.mjs   # re-snapshot opencode + claude + codex + omniroute + freellmapi
# or: ./scripts/capture.sh
git add -A && git commit -m "chore: snapshot $(date -I)" && git push
```

On **target**:

```bash
git pull
./scripts/install.sh        # or .ps1 — re-patches & restores
./scripts/verify.sh
```
