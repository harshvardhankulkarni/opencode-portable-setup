# freellmapi-keys.json — 21 Provider Keys Guide

> On your source machine `freellmapi-keys.json` (21 keys, `v1`, exported `2026-08-27T05:59:17.867Z`) is the **single secrets bundle** for FreeLLMAPI gateway. You will **upload this same file on the new machine** — it turns on all 70+ models at once.

```
freellmapi-keys.json (private, never commit)
    │
    ├─ 21 upstream provider keys (agnes, aion, bai, cerebras, cloudflare, github, google, groq, huggingface, llm7, nvidia, ollama, opencode, openrouter, orcarouter, pollinations, reka, requesty, routeway, siliconflow, zhipu)
    │
    ▼
FreeLLMAPI gateway :31415  ──►  Claude Code / Codex / Opencode / Qwen (via setup-*)
```

- **Real file:** `freellmapi-keys.json` or `freellmapi/keys.json` (your private bundle) — **gitignored**
- **Template in repo:** `freellmapi/keys.json.example` + `freellmapi/keys.csv.example` (redacted `${REDACTED}`)
- **Where you put it on new machine (any of these):**
  ```
  ./freellmapi-keys.json          # repo root (after you cp your real file there — gitignored)
  ./freellmapi/keys.json          # inside freellmapi folder
  ~/freellmapi-keys.json          # home
  ~/Desktop/freellmapi-keys.json  # Windows Desktop (where it lived on source)
  ~/.freellmapi/keys.json         # if your FreeLLMAPI stores it there
  ```
  The installer (`scripts/install.sh` / `.ps1`) checks all these locations, validates the JSON, warns if any key is placeholder, and copies it to `./freellmapi/keys.json` for convenience. It never prints the keys.

## Quick start on a new machine

```bash
# 1. after cloning the repo, copy your REAL bundle (from USB, cloud drive, password manager)
cp ~/Downloads/freellmapi-keys.json ./freellmapi-keys.json
# or: cp ~/Downloads/freellmapi-keys.json ./freellmapi/keys.json

# 2. verify it (no keys printed)
node scripts/lib/import-freellmapi-keys.mjs --check
# or:
./scripts/verify.sh   # checks keys count + platforms

# 3. optionally export to .env for tools that read env (installer can do this)
node scripts/lib/import-freellmapi-keys.mjs --export-env >> .env
# or: node scripts/lib/import-freellmapi-keys.mjs --print-env  # dry-run
```

**Import into FreeLLMAPI dashboard (if you use the desktop app):**

- FreeLLMAPI tray → *Settings / Keys* → **Import** → select `freellmapi-keys.json`
- Or FreeLLMAPI web dashboard `http://localhost:31415` or `http://127.0.0.1:31415` → *Providers* → *Import JSON*

If you run FreeLLMAPI headless (no UI), setting `FREELLMAPI_API_KEY` in `.env` is enough — the gateway still forwards to upstream providers using the keys in `freellmapi-keys.json` via the dashboard import, **or** via env per provider (see mapping below). The helper script can also print `export PROVIDER_API_KEY=...` lines if you prefer env-based auth.

## All 21 providers — what each key is and where to get it

> Key names are `platform` values inside `freellmapi-keys.json`. The installer preserves them 1:1. Get one, paste its `key` string.

| # | `platform` in JSON | Key prefix you have | Where to get / rotate | Used for (model family) |
|---|-------------------|---------------------|-----------------------|--------------------------|
| 1 | **agnes** | `sk-ARM...` | https://agnes.ai or `https://api.agnes.com` → API Keys (if self-hosted, create in dashboard) | `agnes-*` models via FreeLLMAPI |
| 2 | **aion** | `alv2_kg9y...` | Aion dashboard → https://aion... (Lepton/Anyscale fork) → API Keys → create `alv2_...` | `aion-*`, `aion-rp-*` |
| 3 | **bai** | `sk-3q4mo...` | `https://api.bai...` or BaiChuan API → console → API Keys (`sk-...`) | BaiChuan models |
| 4 | **cerebras** | `csk-jfrj...` | https://cloud.cerebras.ai → *API Keys* → Create (`csk-...`) | `cerebras-*`, Llama 3.1 70B large, `llama-3.3-70b` etc. |
| 5 | **cloudflare** | `7dddfe37...:cfat_...` | Cloudflare Dashboard → *Workers AI* / *AI Gateway* → API Token → copy `cfat_...` + Account ID prefix | Workers AI, `llama-*` via CF |
| 6 | **github** | `github_pat_11AZM...` | https://github.com/settings/tokens?type=beta → *Fine-grained PAT* → repo access (`github_pat_...`) | `gpt-oss-*` via GitHub Models, `github`-hosted |
| 7 | **google** | `AQ.Ab8RN6J...` | https://aistudio.google.com/apikey (Gemini API) → *Create API key* (`AIza...` or `AQ....` for new) | `gemini-2.5-flash`, `gemma-4-*` |
| 8 | **groq** | `gsk_3g7D...` | https://console.groq.com/keys → *Create API Key* (`gsk_...`) | `llama-3.3-70b`, `mixture` fast |
| 9 | **huggingface** | `hf_jnOq...` | https://huggingface.co/settings/tokens → *New token* (`hf_...` fine-grained) | `hf` models, Inference Providers |
| 10 | **llm7** | `axl4vlg...` | https://llm7.io or `https://api.llm7.com` → Dashboard → API Keys (`axl...` long JWT) | `llm7` aggregated models |
| 11 | **nvidia** | `nvapi-Y52s...` | https://build.nvidia.com → *API Keys* → Generate (`nvapi-...`) | `nemotron-*`, `llama-3.x-70b` via NIM |
| 12 | **ollama** | `e0a13c19...C_u_pNz-...` | Ollama Cloud https://ollama.com/settings/keys or local Ollama `C_u_pNz-...` (if self-hosted Ollama at `http://localhost:11434`) | `ollama` local models |
| 13 | **opencode** | `sk-4b4Hp...` | Your Opencode provider API key (could be OpenAI-compatible self-host) — reissue from your provider dashboard | `opencode` models |
| 14 | **openrouter** | `sk-or-v1-2f1df...` | https://openrouter.ai/keys → *Create Key* (`sk-or-v1-...`) | `openrouter` unified — 300+ models |
| 15 | **orcarouter** | `sk-orca-OuS4...` | `https://orcarouter...` dashboard → API Keys (`sk-orca-...`) | `orcarouter` |
| 16 | **pollinations** | `sk_6PfAJ...` | https://pollinations.ai or `https://enter.pollinations.ai` → API Keys (`sk_...`) | `pollinations` image/text |
| 17 | **reka** | `f813e239...` | https://platform.reka.ai → *API Keys* → New (`f8...` hex) | `reka-flash`, `reka-edge` |
| 18 | **requesty** | `rqsty-sk-sdb6...` | https://requesty.ai → Dashboard → API Keys (`rqsty-sk-...`) | `requesty` router |
| 19 | **routeway** | `sk--TIPUB...` | `https://routeway...` or `https://app.routeway...` → API Keys (`sk--...`) | `routeway` |
| 20 | **siliconflow** | `sk-lgzig...` | https://cloud.siliconflow.cn → *API Keys* (`sk-...`) | `siliconflow`, `qwen3-...` CN |
| 21 | **zhipu** | `7eb7720a...o10hYP...` | https://open.bigmodel.cn → *API Keys* → Create (`<id>.<secret>`) | `glm-4.7`, `glm-5.2` (Zhipu BigModel) |

Also separate from this file:

| Extra secret | Where | Purpose |
|-------------|-------|---------|
| `FREELLMAPI_API_KEY` | `.env` → gateway auth for Opencode provider (`{env:FREELLMAPI_API_KEY}`) + `npx freellmapi setup-* --api-key` | Authenticates Claude/Codex/Opencode to FreeLLMAPI itself (not per provider) |
| `ANTHROPIC_AUTH_TOKEN` | `.env` + `~/.claude/settings.json:env` | Same gateway token under Anthropic name (written by `setup-claude`) — often identical to `FREELLMAPI_API_KEY` with `freellmapi-` prefix |
| `FREELLMAPI_URL` | `.env` optional | Override gateway base URL (default `http://127.0.0.1:31415`) |

### Minimum to boot

FreeLLMAPI will start even with **zero** provider keys — but you will get `401/404 No model` until at least one provider key above is valid. For your exact 70+ model list (fusion, kimi-k2.7-code, minimax-m3, glm-5.2, etc.), you need the **majority** of the 21. At a minimum, to reproduce your current `opencode.json` 73-model catalog on a new box, keep at least:

- `openrouter` + `zhipu` + `cerebras` + `groq` + `siliconflow` + `google` + `reka` + `nvidia`

The installer does not enforce this — `verify.sh` just counts keys and warns if `< 10`.

### How to rotate / re-export

On the **source** machine (where FreeLLMAPI is already working):

```bash
# FreeLLMAPI tray → Export → freellmapi-keys.json
# or if you stored keys manually, just copy the file:
cp ~/Desktop/freellmapi-keys.json ./freellmapi/keys.json
# or: cp ~/.freellmapi/keys.json ./freellmapi/keys.json
```

Sanitize before committing (the repo never commits the real file):

```bash
# This creates the redacted template committed as freellmapi/keys.json.example:
node scripts/lib/capture-full.mjs   # auto-redacts to ${REDACTED}
# or manually:
node scripts/lib/import-freellmapi-keys.mjs --redact freellmapi/keys.json > freellmapi/keys.json.example
```

On the **new** machine, **import** (pick one):

```bash
# A) File drop — most reliable (installer checks these paths):
cp /path/to/your-real-freellmapi-keys.json ./freellmapi-keys.json
cp /path/to/your-real-freellmapi-keys.json ./freellmapi/keys.json  # either works
node scripts/lib/import-freellmapi-keys.mjs --check   # validates JSON shape + 21 platforms + no placeholder

# B) Via dashboard UI (if FreeLLMAPI has a dashboard):
# Open http://127.0.0.1:31415 → Providers → Import → select freellmapi-keys.json

# C) Env export (if you run gateway headless without dashboard import):
node scripts/lib/import-freellmapi-keys.mjs --export-env >> .env
# then: set -a; source .env; set +a
```

### Troubleshooting

| Symptom | Check |
|---------|-------|
| `npx freellmapi setup-claude` → `no api key` | Ensure `FREELLMAPI_API_KEY` or `ANTHROPIC_AUTH_TOKEN` is in `.env` + exported, or pass `--api-key` explicitly |
| `claude` → `401` despite `freellmapi-keys.json` present | `freellmapi-keys.json` is for **upstream providers**, not for gateway auth. Set `FREELLMAPI_API_KEY` / `ANTHROPIC_AUTH_TOKEN` in `.env`. Then `npx freellmapi doctor claude` |
| `verify.sh` → `freellmapi keys: 0` | File not at any checked path. `ls ./freellmapi/keys.json ./freellmapi-keys.json ~/freellmapi-keys.json ~/Desktop/freellmapi-keys.json` |
| Model `glm-5.2` → `model not found` | `zhipu` key missing/expired — reissue at https://open.bigmodel.cn |
| `reka-flash`/`reka-edge` fail | `reka` key missing — https://platform.reka.ai |
| `nvapi-` models fail | `nvidia` key — https://build.nvidia.com → regenerate |
| Want to add/remove a provider | Edit `freellmapi-keys.json` → add `{"platform":"new","key":"...","label":""}` → re-import / re-run `--export-env` |

For a full env matrix beyond this file, see `docs/ENV_VARS.md`.
