# Claude Code — Cloned Config (268 agents, 222 skills, 161 commands, 21 hooks, 177 plugins)

> This folder `claude/` is a full clone of `~/.claude` on Harsh workstation (2026-08-26). Installer (`scripts/install.sh` / `.ps1`) copies it to `~/.claude` on the new machine.

## What's inside

```
claude/
├── settings.json             # SANITIZED — ANTHROPIC_AUTH_TOKEN=${...} etc. (real token was freellmapi-269b... on :31415)
├── settings.json.example     # same
├── settings.local.json.example
├── mcp.json                  # SANITIZED — firecrawl key ${FIRECRAWL_API_KEY}
├── home-mcp.json.example     # ~/.mcp.json — claude-flow (ruflo v3)
├── CLAUDE.md                 # ruflo + graphify global instructions
├── agents/          268      # academic-*, engineering-*, marketing-*, gsd-*, security-*, finance-*, etc.
├── skills/          222 dirs # agentdb-*, gstack (pruned binaries!), firecrawl/*, gsd-*, vercel-*, huggingface-*, deploy-to-vercel ...
├── commands/        161      # agents/*, analysis/*, automation/*, github/*, swarm/*, sparc/*, etc.
├── hooks/           21       # cbm-code-discovery-gate, cbm-session-reminder, gsd-*.js/*.sh, managed-hooks-registry.cjs
└── plugins/                 # inventories only — enbledPlugins.json, installed_plugins.json (91 KB), known_marketplaces.json
```

## Key details

- **Gateway**: `settings.json:env.ANTHROPIC_BASE_URL = http://127.0.0.1:31415` (FreeLLMAPI). `ANTHROPIC_AUTH_TOKEN=${ANTHROPIC_AUTH_TOKEN}` (template). Set in `.env`.
- **MCP**: `claude/mcp.json` has 2 servers: `codebase-memory-mcp` (binary `~/.local/bin/codebase-memory-mcp`) + `firecrawl` http. Secrets sanitized to `${FIRECRAWL_API_KEY}`.
- **Home MCP** (`~/.mcp.json`): `claude-flow` via `ruflo@latest mcp start` (`CLAUDE_FLOW_MODE=v3`, `TOPOLOGY=hierarchical-mesh`, `MAX_AGENTS=15`).
- **Plugins**: 177 enabled (Claude Plugins Official + ecc + thedotmack). List in `claude/plugins/enabledPlugins.json`. Full catalog cached in `installed_plugins.json` (91852 bytes) — not the full plugin binaries, just the registry. Plugins rehydrate on first `claude` launch or `claude plugin install/update`.
- **Hooks**: `PreToolUse Grep|Glob -> cbm-code-discovery-gate`, `SessionStart -> cbm-session-reminder`, `SubagentStart -> cbm-subagent-reminder` + 15 GSD hooks.

## After install, verify

```bash
cat ~/.claude/settings.json | grep ANTHROPIC_BASE_URL
cat ~/.claude/.mcp.json
ls ~/.claude/agents | wc -l   # should be ~268
ls ~/.claude/skills | wc -l   # ~222 dirs
claude --version
```
