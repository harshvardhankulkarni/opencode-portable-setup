# Environment Variables — Full Matrix

> Source snapshot 2026-08-26. Template is `.env.example` at repo root. Also see `omniroute/.env.example` + `upstream-.env.example` for OmniRoute server config.

## FreeLLMAPI / Claude gateway (port 31415) — REQUIRED for unified models

| Variable | Where consumed | Required | How to get |
|----------|---------------|----------|------------|
| `FREELLMAPI_API_KEY` | `~/.config/opencode/opencode.json` provider `freellmapi.options.apiKey={env:FREELLMAPI_API_KEY}`, `~/.codex/config.toml` `[model_providers.freellmapi] env_key` | yes | Your FreeLLMAPI dashboard / API keys page. Source had `freellmapi-keys.{json,csv}` on Desktop (not committed). Example redacted in `freellmapi/keys.{json,csv}.example`. |
| `ANTHROPIC_AUTH_TOKEN` | `~/.claude/settings.json` env `ANTHROPIC_AUTH_TOKEN` (Claude Code) | yes | Same gateway token but under Anthropic naming. Often identical to `FREELLMAPI_API_KEY` with `freellmapi-` prefix. `npx freellmapi setup-claude` writes this. |
| `ANTHROPIC_BASE_URL` | `~/.claude/settings.json` env | yes | `http://127.0.0.1:31415` (hardcoded by `freellmapi setup-claude`) |
| `ANTHROPIC_MODEL` | `~/.claude/settings.json` env | no | `auto` |
| `ANTHROPIC_DEFAULT_*_MODEL` | `~/.claude/settings.json` env | no | `auto` / `auto/claude-sonnet` |

Setup commands (also run by installer):

```bash
npx freellmapi setup-claude   --url http://127.0.0.1:31415
npx freellmapi setup-codex    --url http://127.0.0.1:31415
npx freellmapi setup-opencode --url http://127.0.0.1:31415
npx freellmapi setup-qwen     --url http://127.0.0.1:31415
```

Check:

```bash
curl http://127.0.0.1:31415/v1/models -H "Authorization: Bearer $FREELLMAPI_API_KEY"
```

## OmniRoute (port 20128) — OpenAI-compatible router

| Variable | Where | Required |
|----------|-------|----------|
| `OMNIROUTE_API_KEY` | `opencode.json` provider `omniroute.options.apiKey=${OMNIROUTE_API_KEY}` + `.env` for installer | if using provider `omniroute` |
| `STORAGE_ENCRYPTION_KEY` | `~/.omniroute/.env` (server) | yes on first boot — `openssl rand -hex 32` |
| `JWT_SECRET` | `~/.omniroute/.env` | yes — `openssl rand -base64 48` |
| `API_KEY_SECRET` | `~/.omniroute/.env` | yes — `openssl rand -hex 32` |
| `INITIAL_PASSWORD` | `~/.omniroute/.env` bootstrap | yes — change from `CHANGEME` |
| `PORT` | server | 20128 default |
| + 50 more | see `omniroute/upstream-.env.example` (full annotated 129 KB) | optional |

Full upstream contract is at `omniroute/upstream-.env.example` (copy of `node_modules/omniroute/.env.example`).

## Opencode MCP servers

| Variable | MCP | Required |
|----------|-----|----------|
| `GITHUB_TOKEN` / `GITHUB_PERSONAL_ACCESS_TOKEN` | `mcp.github` (`npx @modelcontextprotocol/server-github`), also opencode `mcp.github.env` | yes for github MCP — scopes `repo workflow read:org gist` — `gh auth login` or https://github.com/settings/tokens |
| `FIRECRAWL_API_KEY` | `mcp.firecrawl` remote `https://mcp.firecrawl.dev/v2/mcp`, also `claude/.mcp.json` firecrawl env + `codex/config.toml` firecrawl env | yes for firecrawl — https://firecrawl.dev |
| `VERCEL_TOKEN` | `mcp.vercel` (legacy `mcp-legacy.json`) | if using vercel MCP |
| `LINEAR_API_KEY` | `mcp.linear` | if using Linear |
| `SENTRY_AUTH_TOKEN` | `mcp.sentry` | if using Sentry |
| `E2B_API_KEY` | `mcp.e2b` | if using E2B |
| `SUPABASE_ACCESS_TOKEN` | `mcp.supabase` | if using Supabase |
| `SUPABASE_URL` / `SUPABASE_ANON_KEY` / `SUPABASE_SERVICE_ROLE_KEY` | `supabase-mcp-config.json.example` | if using Supabase MCP |
| `BROWSERBASE_API_KEY` + `BROWSERBASE_PROJECT_ID` | `mcp.browserbase` + `mcp.stagehand` | if using Browserbase |
| `SKYVERN_API_KEY` | `mcp.skyvern` | if using Skyvern |
| `TWOS_TRIAL` | `mcp.twos-io` | `1` |

Context7, playwright, sequential-thinking, correctover, filesystem, codebase-memory-mcp, officecli, graphify — no tokens.

## How .env is loaded

- **Opencode**: reads `opencode.json` `mcp.*.env` and `provider.*.options.apiKey` at runtime — `${VAR}` or `{env:VAR}` expands from process env. So `source .env` or `set -a; source .env; set +a` before launching `opencode`.
- **Claude Code**: reads `~/.claude/settings.json` `env` object + process env. The installer does `npx freellmapi setup-claude` which writes the `env` block; you still need `ANTHROPIC_AUTH_TOKEN` exported.
- **Codex**: reads `~/.codex/config.toml` + env var `FREELLMAPI_API_KEY` via `env_key`.
- **OmniRoute server**: reads `~/.omniroute/.env` directly (not the repo `.env`). Installer copies `omniroute/.env.example -> ~/.omniroute/.env` if missing.

Tip — auto-load repo `.env` into shell:

```bash
# bash/zsh: add to ~/.bashrc or ~/.zshrc
set -a; source ~/opencode-portable-setup/.env 2>/dev/null; set +a
set -a; source ~/.omniroute/.env 2>/dev/null; set +a
```
```powershell
# PowerShell $PROFILE
Get-Content ~/opencode-portable-setup/.env | ForEach-Object {
  if($_ -match '^([^#=]+)=(.*)$'){ Set-Item -Path Env:$($matches[1].Trim()) -Value $matches[2].Trim() }
}
```


## freellmapi-keys.json — 21 provider keys bundle

Your real keys live in `freellmapi-keys.json` (gitignored) — **not** in `.env`. `.env` holds only the *gateway* auth (`FREELLMAPI_API_KEY` / `ANTHROPIC_AUTH_TOKEN`). The bundle holds *per-provider* upstream keys (agnes, aion, bai, cerebras, cloudflare, github, google, groq, huggingface, llm7, nvidia, ollama, opencode, openrouter, orcarouter, pollinations, reka, requesty, routeway, siliconflow, zhipu).

On a new machine:

```bash
cp ~/Downloads/freellmapi-keys.json ./freellmapi-keys.json  # or ./freellmapi/keys.json — both gitignored
node scripts/lib/import-freellmapi-keys.mjs --check        # validates 21 keys (masked)
# optionally: node scripts/lib/import-freellmapi-keys.mjs --export-env >> .env
```

Full per-provider table: where each key comes from, prefix, and link — see `docs/FREELLMAPI_KEYS.md`. Template (redacted) is `freellmapi/keys.json.example`.

## Where to fill on a new machine

1. `cp .env.example .env` at repo root — fill `FREELLMAPI_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `GITHUB_TOKEN`, `FIRECRAWL_API_KEY`, `OMNIROUTE_API_KEY`
2. `cp omniroute/.env.example ~/.omniroute/.env` — fill `STORAGE_ENCRYPTION_KEY`, `JWT_SECRET`, `API_KEY_SECRET`, `INITIAL_PASSWORD` + optionally `PORT`, `DATA_DIR`, etc. Full docs in `omniroute/upstream-.env.example`
3. `gh auth login` (also sets `GITHUB_TOKEN` via keyring)
4. Optional: `~/.qwen/.env`, `~/.gemini/config/config.json` if using those CLIs
