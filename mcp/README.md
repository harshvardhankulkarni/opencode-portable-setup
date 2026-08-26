# MCP Servers Inventory

This repo captures **two MCP manifests** that co-existed on the source machine:

| File | Purpose | Active |
|------|---------|--------|
| `config/opencode.json` → `mcp` key | **Live** opencode MCP config (8 servers) | ✅ primary |
| `config/mcp-legacy.json` (original `mcp.json`) | Standalone MCP servers (14 servers, `mcpServers` key) | legacy - merged below |

## Live config (from opencode.json)

Extracted `mcp` block (verbatim, paths are Windows-specific):

- **codebase-memory-mcp** — `C:/Users/PilzIndia/.local/bin/codebase-memory-mcp.exe` (local binary, 273 MB Rust)
- **firecrawl** — remote `https://mcp.firecrawl.dev/v2/mcp` (env FIRECRAWL_API_KEY)
- **filesystem** — `npx @modelcontextprotocol/server-filesystem C:/Users/PilzIndia` (needs path update per OS)
- **github** — `npx @modelcontextprotocol/server-github` (env GITHUB_PERSONAL_ACCESS_TOKEN -> GITHUB_TOKEN)
- **officecli** — `C:/Users/PilzIndia/bin/officecli.exe mcp` (Windows binary, 33 MB)
- **playwright** — `npx @playwright/mcp`
- **twos-io** — `npx @2sio/mcp` (env TWOS_TRIAL=1)
- **correctover** — `npx correctover-mcp-server`

## Legacy mcp.json (mcpServers)

Additional servers not in live config but available:

- context7 — `npx -y @upstash/context7-mcp`
- vercel — `npx -y @vercel/mcp-server` (VERCEL_TOKEN)
- linear — `npx -y @linear/mcp-server` (LINEAR_API_KEY)
- sentry — `npx -y @sentry/mcp-server` (SENTRY_AUTH_TOKEN)
- sequential-thinking — `npx -y @modelcontextprotocol/server-sequential-thinking`
- e2b — `npx -y @e2b/mcp-server` (E2B_API_KEY)
- supabase — `npx -y @supabase/mcp-server` (SUPABASE_ACCESS_TOKEN)
- browser — `npx -y @browsermcp/mcp@latest`
- skyvern — `npx -y @skyvern/mcp-server` (SKYVERN_API_KEY)
- browserbase — `npx -y @browserbase/mcp-server` (BROWSERBASE_API_KEY + PROJECT_ID)
- stagehand — `npx -y @browserbase/stagehand-mcp`

Unified manifest is in `mcp/manifest.unified.json` (merge of both).

## Path portability

On Linux/macOS, update:

- `codebase-memory-mcp.command[0]` → `~/.local/bin/codebase-memory-mcp` or `codebase-memory-mcp`
- `filesystem.command[2]` → `$HOME` or desired allowed dir
- `officecli.command[0]` → `~/.local/bin/officecli` or `officecli`

The installer (`install.sh` / `install.ps1`) does this automatically.

