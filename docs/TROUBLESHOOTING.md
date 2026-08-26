# Troubleshooting

## Install / prerequisites

| Symptom | Fix |
|---------|-----|
| `node` not found | Install Node 20+ — https://nodejs.org, `winget install OpenJS.NodeJS`, `brew install node`, or `nvm install 22` |
| `opencode: command not found` after install | `npm i -g opencode-ai@1.18.23 @opencode-ai/cli@0.0.0-beta-18155` then reopen terminal. Check `npm config get prefix` is in `PATH`. On Windows: `%APPDATA%\npm` |
| `opencode.json still has PilzIndia paths` | Run `node scripts/lib/patch-config.mjs --src ~/.config/opencode/opencode.json --home $HOME`. Then restart `opencode`. |
| `npm install` fails in `~/.config/opencode` | `cd ~/.config/opencode && npm install --verbose`. Check `node --version` >=20. Delete `node_modules` + `package-lock.json` if corrupted. |
| `bun` missing | `npm i -g bun@1.3.14` or `curl -fsSL https://bun.sh/install \| bash` |
| `gh auth` fail | `gh auth login` — choose HTTPS + paste `GITHUB_TOKEN`. Or `export GITHUB_TOKEN=ghp_...` |
| Symlinks on Windows fail (`firecrawl*`) | Enable Developer Mode: Settings → System → For Developers → Developer Mode ON. Or run PowerShell as Admin. Installer falls back to `Copy-Item` junction/copy if symlink creation fails. |
| `freellmapi: command not found` | `npm i -g freellmapi@0.5.0` or `npx freellmapi@0.5.0 --version`. The installer also runs `npx freellmapi setup-*` which will fetch it. |

## Gateways (OmniRoute :20128, FreeLLMAPI :31415)

| Symptom | Fix |
|---------|-----|
| `curl :20128/v1/models` → connection refused | OmniRoute not running. Run `omniroute` or `omniroute start` in a terminal/tmux. Check `~/.omniroute/.env` has `STORAGE_ENCRYPTION_KEY` etc. — copy from `omniroute/.env.example`. Check `netstat -ano \| grep 20128` or `lsof -i :20128`. |
| `cursor :31415/v1/models` → 401 | `FREELLMAPI_API_KEY` or `ANTHROPIC_AUTH_TOKEN` wrong. `echo $FREELLMAPI_API_KEY`, `grep FREELLMAPI .env`. Re-run `npx freellmapi setup-claude --url http://127.0.0.1:31415` after fixing `.env`. |
| `cursor :31415/v1/models` → ECONNREFUSED | FreeLLMAPI not running. `npx freellmapi serve --port 31415` or `freellmapi start` (check that package is installed). |
| Claude still hits Anthropic directly (ignores FreeLLMAPI) | `cat ~/.claude/settings.json \| grep ANTHROPIC_BASE_URL` must be `http://127.0.0.1:31415`. If not, `npx freellmapi setup-claude --url http://127.0.0.1:31415` and restart `claude`. Also `export ANTHROPIC_BASE_URL=http://127.0.0.1:31415`. |
| Opencode provider `freellmapi` auth fail | `cat ~/.config/opencode/opencode.json \| grep -A5 freellmapi` — `apiKey` should be `{env:FREELLMAPI_API_KEY}` and env exported. Try `curl http://127.0.0.1:31415/v1/models -H "Authorization: Bearer $FREELLMAPI_API_KEY"`. |

## MCP servers

| Symptom | Fix |
|---------|-----|
| `codebase-memory-mcp` not found / Exit 127 | Binary is platform-specific. Source was `C:/Users/PilzIndia/.local/bin/codebase-memory-mcp.exe` (273 MB Rust). On Linux/macOS: build from source or download the matching binary to `~/.local/bin/codebase-memory-mcp` + `chmod +x`. Or temporarily disable: remove `mcp.codebase-memory-mcp` block from `opencode.json` / `.claude/.mcp.json` / `codex/config.toml`. |
| `officecli` MCP fail | Windows binary `C:/Users/PilzIndia/bin/officecli.exe`. On new OS: `npm i -g officecli` or download from releases. Else disable that `mcp.officecli` block. |
| `filesystem` MCP permission denied | Edit `opencode.json` `mcp.filesystem.command[2]` to a real allowed dir, e.g. `$HOME` or `/workspace`. Restart. |
| `github` MCP 401 | `GITHUB_TOKEN` not set or missing scopes `repo workflow read:org gist`. `gh auth status`, `echo $GITHUB_TOKEN`, re-`gh auth login`, then restart opencode/claude. |
| `firecrawl` MCP 401 | `FIRECRAWL_API_KEY` not set — `echo $FIRECRAWL_API_KEY`, `grep FIRECRAWL .env`, https://firecrawl.dev → API keys, restart. |
| `playwright` browsers missing | `npx playwright install` or `npx playwright install chromium` |
| MCP not showing in `opencode` | `opencode --help` → check `--mcp-debug` or logs. Verify JSON syntax: `cat ~/.config/opencode/opencode.json \| python3 -m json.tool` must parse. |

## Agents / skills

| Symptom | Fix |
|---------|-----|
| `agents` count low (expected 236 / 274) | Re-run installer with `--force`: `./scripts/install.sh --force`. Check `ls ~/.config/opencode/agents \| wc -l` and `ls ~/.claude/agents \| wc -l`. The repo `agents/` + `claude/agents/` should be 236 + 274 files. |
| `skills` missing `firecrawl*` symlinks | `ls -l ~/.config/opencode/skills` — should have 33 symlinks `firecrawl* -> ~/.agents/skills/firecrawl*`. Recreate: `for d in ~/.agents/skills/firecrawl*; do ln -sf "$d" ~/.config/opencode/skills/$(basename "$d"); done` (WSL/Git Bash) or PowerShell `New-Item -ItemType SymbolicLink`. Installer does this in step 8c. |
| Claude skills `gstack` binaries missing (`dist/*.exe`) | Expected — they were excluded for repo size (509 MB). Run `cd ~/.claude/skills/gstack && npm install && npm run build` or `claude plugin update gstack`. See `claude/skills/gstack/BINARIES_EXCLUDED.md`. |
| `opencode` theme/keybindings wrong | `cat ~/.config/opencode/cli.json` (theme `github`) and `tui.json` (leader `ctrl+space`, etc.). Re-copy from `config/cli.json` + `config/tui.json`. |
| Permissions prompts too strict/loose | Edit `~/.config/opencode/opencode.json` → `permission` (read allow, write/edit/bash ask, etc.) or `~/.claude/settings.json` → permissions. |

## Repo / git

| Symptom | Fix |
|---------|-----|
| `gh repo create` permission denied | `gh auth login`, verify `gh auth status` shows `repo` scope, then `gh repo create <name> --public --source=. --push` again. |
| Repo too large to push (>100 MB) | The pruned repo is ~74 MB (was 575 MB before gstack prune). If still large: `git lfs track "*.exe"` or ensure `claude/skills/gstack/{make-pdf,design,browse}/dist` is gitignored (the installer already pruned them). Check `git count-objects -vH`. |
| `.env` got committed | Immediately rotate all keys (GitHub, Firecrawl, FreeLLMAPI, OmniRoute secrets). Then `git rm --cached .env && git commit -m "remove .env" && git push --force`. Ensure `.gitignore` has `.env`. |

## General

- **First stop after any failure**: `./scripts/verify.sh` (or `.ps1`) — it prints exactly which counts/env/ports are off.
- **Logs**: `opencode` → check terminal + `~/.config/opencode/*.log`. `claude --mcp-debug`. `omniroute` → `~/.omniroute/logs/`. `freellmapi` → foreground terminal where you ran `npx freellmapi serve`.
- **Clean reinstall**: `./scripts/install.sh --force` (backs up previous to `*.backup-<ts>`). To nuke and start over: `rm -rf ~/.config/opencode ~/.claude ~/.codex ~/.agents/skills` then install again — but back up `~/.claude/.credentials.json` style auth if needed (not included in repo for security).
