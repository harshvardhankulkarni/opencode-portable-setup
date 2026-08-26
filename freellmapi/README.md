# FreeLLMAPI — unified gateway on :31415

> On your source machine **FreeLLMAPI is the single gateway** for Claude Code, Codex, Opencode and Qwen. Every client points to `http://127.0.0.1:31415`.

```
Claude Code  ─┐
Codex        ─┼─►  FreeLLMAPI  http://127.0.0.1:31415  ─►  70+ models (auto, kimi-k2.7-code, qwen3-coder-480b, deepseek-v4-flash, etc.)
Opencode     ─┘         (:31415/v1 for OpenAI, :31415 for Anthropic)
Qwen CLI     ─┘
```

Source evidence:

```bash
npx freellmapi setup-claude  --url http://127.0.0.1:31415   # writes ~/.claude/settings.json env
npx freellmapi setup-codex   --url http://127.0.0.1:31415   # writes ~/.codex/config.toml [model_providers.freellmapi]
npx freellmapi setup-opencode --url http://127.0.0.1:31415  # writes ~/.config/opencode/opencode.json provider.freellmapi
npx freellmapi setup-qwen    --url http://127.0.0.1:31415
```

Package:

- npm: `freellmapi@0.5.0` (latest) — source machine had `0.4.0` via npx cache (`AppData/Local/npm-cache/_npx/e995436d190f44dd/...`)
- Repo/global install: `npm i -g freellmapi` or `npx freellmapi@latest`

## Install on a new machine

```bash
# 1. install
npm i -g freellmapi@0.5.0   # or npx freellmapi@latest --help

# 2. set your key (from .env)
export FREELLMAPI_API_KEY=sk-freellm-xxxx
export ANTHROPIC_AUTH_TOKEN=freellmapi-xxxx   # Claude Code uses this var name
# or: copy .env.example -> .env and `set -a; source .env; set +a`

# 3. wire every client (installer does this automatically)
npx freellmapi setup-claude   --url http://127.0.0.1:31415
npx freellmapi setup-codex    --url http://127.0.0.1:31415
npx freellmapi setup-opencode --url http://127.0.0.1:31415
npx freellmapi setup-qwen     --url http://127.0.0.1:31415

# 4. run / check
curl http://127.0.0.1:31415/v1/models -H "Authorization: Bearer $FREELLMAPI_API_KEY" | head
freellmapi --help
```

If `freellmapi` runs as a daemon:

```bash
npx freellmapi serve --port 31415    # or: freellmapi start
# logs: wherever you started it (pm2, systemd, or foreground)
```

## How each client is wired

| Client | File | Key |
|--------|------|-----|
| Claude Code | `~/.claude/settings.json` → `env.ANTHROPIC_BASE_URL=http://127.0.0.1:31415`, `ANTHROPIC_AUTH_TOKEN` | `ANTHROPIC_AUTH_TOKEN` |
| Codex | `~/.codex/config.toml` → `[model_providers.freellmapi] base_url="http://127.0.0.1:31415/v1"` | `FREELLMAPI_API_KEY` |
| Opencode | `~/.config/opencode/opencode.json` → `provider.freellmapi.options.baseURL="http://127.0.0.1:31415/v1"` | `{env:FREELLMAPI_API_KEY}` |
| Qwen | `~/.qwen/settings.json` or `.env` | varies |

## Troubleshooting

```bash
curl -v http://127.0.0.1:31415/v1/models -H "Authorization: Bearer $FREELLMAPI_API_KEY"
# 401 -> key wrong; 502/ECONNREFUSED -> server not running
netstat -ano | grep 31415   # or: ss -tulpn | grep 31415  (Linux)  /  lsof -i :31415 (macOS)
ps aux | grep freellmapi
npx freellmapi --version
```

## Keys

Your real keys are on the Desktop as `freellmapi-keys.{json,csv}` on the source machine — **never commit them**. This repo ships only redacted examples: `freellmapi/keys.{json,csv}.example` (all secrets replaced with `${REDACTED}`).

Set them via `.env`:

```bash
FREELLMAPI_API_KEY=...
ANTHROPIC_AUTH_TOKEN=freellmapi-...
```
