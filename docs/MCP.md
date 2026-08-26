# MCP Servers — Deep Dive

> Source 2026-08-26: 8 live servers in `~/.config/opencode/opencode.json:mcp` + 14 legacy in `mcp.json` (merged to 19 in `mcp/manifest.unified.json`). This doc is the per-server reference.

## Live — opencode.json

| Server | Command | Type | Notes |
|--------|---------|------|-------|
| **codebase-memory-mcp** | `~/.local/bin/codebase-memory-mcp` (was `C:/Users/PilzIndia/.local/bin/codebase-memory-mcp.exe` 273 MB Rust) | local binary | Knowledge graph: `search_graph`, `trace_path`, `get_code_snippet`, `query_graph`. Requires building per OS or download. Path patched by installer. |
| **firecrawl** | `https://mcp.firecrawl.dev/v2/mcp` (remote) or `npx firecrawl-mcp@latest` | remote http | Needs `FIRECRAWL_API_KEY`. Also used by Claude (`~/.claude/.mcp.json`) and Codex (`~/.codex/config.toml`). |
| **filesystem** | `npx @modelcontextprotocol/server-filesystem $HOME` (was `C:/Users/PilzIndia`) | local npx | Allowed directory = your home. Installer patches Windows user path → `$HOME`. Edit `opencode.json` to restrict. |
| **github** | `npx @modelcontextprotocol/server-github` env `GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_TOKEN}` | local npx | Needs `GITHUB_TOKEN` scopes `repo workflow read:org gist`. Installer runs `gh auth login` fallback. |
| **officecli** | `officecli mcp` (was `C:/Users/PilzIndia/bin/officecli.exe` 33 MB) | local binary | Office docs MCP. Install from https://github.com/.../officecli or `npm i -g officecli`. Path patched. |
| **playwright** | `npx @playwright/mcp` (or `@playwright/mcp@latest`) | local npx | Browser automation. No token. `npx playwright install` for browsers. |
| **twos-io** | `npx @2sio/mcp` env `TWOS_TRIAL=1` | local npx | |
| **correctover** | `npx correctover-mcp-server` | local npx | |

## Legacy — mcp-legacy.json (14, all `npx -y`)

These are available but not enabled in live `opencode.json:mcp`. The installer does **not** auto-enable them — copy the block you want into `opencode.json:mcp` or `~/.claude/.mcp.json`:

- `context7` — `npx -y @upstash/context7-mcp` (Upstash Context7)
- `vercel` — `npx -y @vercel/mcp-server` env `VERCEL_TOKEN`
- `linear` — `npx -y @linear/mcp-server` env `LINEAR_API_KEY`
- `sentry` — `npx -y @sentry/mcp-server` env `SENTRY_AUTH_TOKEN`
- `sequential-thinking` — `npx -y @modelcontextprotocol/server-sequential-thinking`
- `e2b` — `npx -y @e2b/mcp-server` env `E2B_API_KEY`
- `supabase` — `npx -y @supabase/mcp-server` env `SUPABASE_ACCESS_TOKEN`
- `browser` — `npx -y @browsermcp/mcp@latest`
- `skyvern` — `npx -y @skyvern/mcp-server` env `SKYVERN_API_KEY`
- `browserbase` — `npx -y @browserbase/mcp-server` env `BROWSERBASE_API_KEY` + `BROWSERBASE_PROJECT_ID`
- `stagehand` — `npx -y @browserbase/stagehand-mcp` (same env)
- `firecrawl` (duplicate), `github`, `playwright` already in live.
- `claude-flow` — `ruflo` (in `~/.mcp.json` / `home-mcp.json.example`): `npx -y ruflo@latest mcp start` env `CLAUDE_FLOW_MODE=v3 ...` (Claude Code flow).

## Claude Code MCP — ~/.claude/.mcp.json

Separate from Opencode. Source:

```json
{
  "mcpServers": {
    "codebase-memory-mcp": { "command": "~/.local/bin/codebase-memory-mcp" },
    "firecrawl": { "type": "http", "url": "https://mcp.firecrawl.dev/v2/mcp", "env": { "FIRECRAWL_API_KEY": "${FIRECRAWL_API_KEY}" } }
  }
}
```

Plus `~/.mcp.json` (home) has `claude-flow`:

```json
{
  "mcpServers": {
    "claude-flow": {
      "command": "cmd",
      "args": ["/c","npx","-y","ruflo@latest","mcp","start"],
      "env": { "CLAUDE_FLOW_MODE":"v3", "CLAUDE_FLOW_HOOKS_ENABLED":"true", "CLAUDE_FLOW_TOPOLOGY":"hierarchical-mesh", "CLAUDE_FLOW_MAX_AGENTS":"15" },
      "autoStart": false
    }
  }
}
```

## Codex MCP — ~/.codex/config.toml

```toml
[mcp_servers.codebase-memory-mcp]
command = "~/.local/bin/codebase-memory-mcp"

[mcp_servers.firecrawl]
type = "http"
url = "https://mcp.firecrawl.dev/v2/mcp"
[mcp_servers.firecrawl.env]
FIRECRAWL_API_KEY = "${FIRECRAWL_API_KEY}"
```

## Enabling/disabling

Edit the JSON and restart the client:

```bash
# opencode
nano ~/.config/opencode/opencode.json   # edit mcp.*
opencode                                # restart logs: "mcp: connected X/Y"

# claude
nano ~/.claude/.mcp.json
nano ~/.claude/settings.json  # also check enabledPlugins if using plugin-provided MCP
claude --mcp-debug            # see connection logs

# codex
nano ~/.codex/config.toml     # [mcp_servers.*]
codex --help
```

## Path portability checklist

On Linux/macOS after install:

- `codebase-memory-mcp.command[0]` must be `~/.local/bin/codebase-memory-mcp` (no `.exe`)
- `officecli.command[0]` must be `officecli` or `~/.local/bin/officecli`
- `filesystem.command[2]` must be `$HOME` (not `C:/Users/PilzIndia`)
- All `npx` servers: ensure `node` in `PATH` (installer patches via `patch-config.mjs`)

Verify:

```bash
cat ~/.config/opencode/opencode.json | grep -A2 '"command"'
cat ~/.claude/.mcp.json
cat ~/.codex/config.toml | grep -A3 mcp
```
