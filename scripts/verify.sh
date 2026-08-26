#!/usr/bin/env bash
set -uo pipefail
# verify.sh — health check for opencode + claude + codex + omniroute + freellmapi
# Usage: ./scripts/verify.sh [--quick] [--verbose]

QUICK=false; VERBOSE=false
for a in "$@"; do case "$a" in --quick) QUICK=true;; --verbose|-v) VERBOSE=true;; --help) echo "Usage: $0 [--quick] [--verbose]"; exit 0;; esac; done

pass=0; fail=0; warn=0
ok()   { echo -e "\033[1;32m ✔ $*\033[0m"; pass=$((pass+1)); }
bad()  { echo -e "\033[1;31m ✘ $*\033[0m"; fail=$((fail+1)); }
info() { echo -e "\033[1;34m ℹ $*\033[0m"; }
wrn()  { echo -e "\033[1;33m ⚠ $*\033[0m"; warn=$((warn+1)); }

echo "────────────────────────────────────────"
echo " Portable Setup — Verify"
echo "────────────────────────────────────────"

# --- versions ---
echo ""; echo "## Versions"
for cmd in node npm bun git gh; do
  if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd $($cmd --version 2>&1 | head -n1)"; else bad "$cmd missing"; fi
done
for cmd in opencode claude codex omniroute vercel ruflo openclaw agent-browser freellmapi; do
  if command -v "$cmd" >/dev/null 2>&1; then
    ver=$("$cmd" --version 2>&1 | head -n1 || "$cmd" -v 2>&1 | head -n1 || echo "ok")
    ok "$cmd $ver"
  else
    if [[ "$cmd" == "opencode" || "$cmd" == "claude" ]]; then bad "$cmd missing (npm i -g $cmd)"; else wrn "$cmd missing (optional)"; fi
  fi
done
if command -v freellmapi >/dev/null 2>&1; then ok "freellmapi $(freellmapi --version 2>&1 | head -n1)"; else
  if npx freellmapi --version >/dev/null 2>&1; then ok "freellmapi via npx $(npx freellmapi --version 2>&1 | head -n1)"; else wrn "freellmapi not found — npx freellmapi@0.4.0 will be used"; fi
fi

# --- opencode ---
echo ""; echo "## Opencode"
HOME_DIR="${HOME}"
OC_DIR="$HOME/.config/opencode"
for f in opencode.json cli.json tui.json AGENTS.md package.json; do
  [[ -f "$OC_DIR/$f" ]] && ok "opencode/$f" || bad "opencode/$f missing"
done
cnt=$(ls -1 "$OC_DIR/agents" 2>/dev/null | wc -l | tr -d ' '); [[ "$cnt" -ge 200 ]] && ok "opencode agents: $cnt" || bad "opencode agents low: $cnt (expected 236)"
cnt2=$(ls -1 "$OC_DIR/skills" 2>/dev/null | wc -l | tr -d ' '); [[ "$cnt2" -ge 14 ]] && ok "opencode skills dir: $cnt2 entries" || bad "opencode skills low: $cnt2"
cnt3=$(ls -1 "$HOME/.agents/skills" 2>/dev/null | wc -l | tr -d ' '); [[ "$cnt3" -ge 80 ]] && ok "~/.agents/skills: $cnt3" || wrn "~/.agents/skills low: $cnt3 (expected 91)"
# check symlinks
sym=$(find "$OC_DIR/skills" -type l 2>/dev/null | wc -l | tr -d ' '); [[ "$sym" -ge 20 ]] && ok "firecrawl symlinks: $sym" || wrn "firecrawl symlinks: $sym (expected 33)"
# check mcp + providers
if grep -q "PilzIndia" "$OC_DIR/opencode.json" 2>/dev/null; then bad "opencode.json still has Windows PilzIndia paths — run patch-config.mjs"; else ok "opencode.json paths look portable"; fi
if grep -q "omniroute" "$OC_DIR/opencode.json" 2>/dev/null; then ok "provider omniroute present"; else wrn "provider omniroute missing"; fi
if grep -q "freellmapi" "$OC_DIR/opencode.json" 2>/dev/null; then ok "provider freellmapi present"; else wrn "provider freellmapi missing"; fi

# --- claude ---
echo ""; echo "## Claude Code"
CC_DIR="$HOME/.claude"
[[ -f "$CC_DIR/settings.json" ]] && ok "claude/settings.json" || bad "claude/settings.json missing"
[[ -f "$CC_DIR/.mcp.json" ]] && ok "claude/.mcp.json" || wrn "claude/.mcp.json missing"
cnt=$(ls -1 "$CC_DIR/agents" 2>/dev/null | wc -l | tr -d ' '); [[ "$cnt" -ge 100 ]] && ok "claude agents: $cnt" || wrn "claude agents low: $cnt (expected 274)"
cnt=$(ls -1 "$CC_DIR/skills" 2>/dev/null | wc -l | tr -d ' '); if [[ "$cnt" -ge 180 ]]; then ok "claude skills: $cnt dirs (expected 222)"; elif [[ "$cnt" -ge 100 ]]; then wrn "claude skills low: $cnt (expected 222, gstack pruned?)"; else wrn "claude skills low: $cnt (expected 222)"; fi
[[ -d "$CC_DIR/hooks" ]] && ok "claude hooks" || wrn "claude hooks missing"
[[ -d "$CC_DIR/commands" ]] && ok "claude commands" || wrn "claude commands missing"
if grep -q "ANTHROPIC_BASE_URL.*31415" "$CC_DIR/settings.json" 2>/dev/null; then ok "claude ANTHROPIC_BASE_URL -> freellmapi :31415"; else wrn "claude not wired to freellmapi (check settings.json env)"; fi
if command -v claude >/dev/null 2>&1; then
  # quick plugin check via settings
  plugins=$(python3 -c "import json; d=json.load(open('$CC_DIR/settings.json')); print(len(d.get('enabledPlugins',{})))" 2>/dev/null || echo "?")
  ok "claude enabledPlugins: $plugins"
fi

# --- codex ---
echo ""; echo "## Codex"
CX_DIR="$HOME/.codex"
[[ -f "$CX_DIR/config.toml" ]] && ok "codex/config.toml" || wrn "codex/config.toml missing"
if grep -q "freellmapi" "$CX_DIR/config.toml" 2>/dev/null; then ok "codex wired to freellmapi"; else wrn "codex not wired to freellmapi"; fi
cnt=$(find "$CX_DIR/skills" -type f 2>/dev/null | wc -l | tr -d ' '); [[ "$cnt" -gt 0 ]] && ok "codex skills: $cnt files" || info "codex skills: $cnt"

# --- omniroute ---
echo ""; echo "## OmniRoute (port 20128)"
if [[ -f "$HOME/.omniroute/.env" ]]; then ok "~/.omniroute/.env exists"; else wrn "~/.omniroute/.env missing — copy from omniroute/.env.example + set STORAGE_ENCRYPTION_KEY etc."; fi
if command -v omniroute >/dev/null 2>&1; then ok "omniroute binary"; else wrn "omniroute not in PATH — npm i -g omniroute@3.8.49"; fi
if curl -sf http://127.0.0.1:20128/v1/models >/dev/null 2>&1 || curl -sf http://localhost:20128/v1/models >/dev/null 2>&1; then ok "omniroute :20128 reachable"; else wrn "omniroute :20128 not reachable (is it running? 'omniroute' or 'omniroute start')"; fi

# --- freellmapi ---
echo ""; echo "## FreeLLMAPI (port 31415)"
if curl -sf http://127.0.0.1:31415/v1/models >/dev/null 2>&1 || curl -sf http://localhost:31415/v1/models >/dev/null 2>&1; then ok "freellmapi :31415 reachable"; else wrn "freellmapi :31415 not reachable — run: npx freellmapi serve  OR  freellmapi start (& check FREELLMAPI_API_KEY / ANTHROPIC_AUTH_TOKEN)"; fi
if grep -q "ANTHROPIC_AUTH_TOKEN" "$CC_DIR/settings.json" 2>/dev/null; then ok "ANTHROPIC_AUTH_TOKEN in claude settings"; else wrn "ANTHROPIC_AUTH_TOKEN missing"; fi
if grep -q "FREELLMAPI_API_KEY" "$OC_DIR/opencode.json" 2>/dev/null || grep -q "FREELLMAPI_API_KEY" "$HOME/.codex/config.toml" 2>/dev/null; then ok "FREELLMAPI_API_KEY referenced in configs"; else info "FREELLMAPI_API_KEY — check .env"; fi

# --- env ---
echo ""; echo "## Environment (.env)"
if [[ -f ".env" ]] || [[ -f "$HOME/opencode-portable-setup/.env" ]] || [[ -f "./.env" ]]; then ok ".env present"; else wrn ".env missing — copy from .env.example and fill tokens"; fi
for var in GITHUB_TOKEN FIRECRAWL_API_KEY FREELLMAPI_API_KEY ANTHROPIC_AUTH_TOKEN OMNIROUTE_API_KEY; do
  if printenv "$var" | grep -q .; then ok "env $var set"; elif grep -q "^${var}=" ".env" 2>/dev/null | grep -v "xxxx" | grep -q .; then ok ".env $var looks set"; else
    if [[ "$var" == "GITHUB_TOKEN" || "$var" == "FIRECRAWL_API_KEY" ]]; then wrn "$var not set (MCP github/firecrawl will fail)"; else info "$var not set (optional)"; fi
  fi
done

# --- summary ---
echo ""; echo "────────────────────────────────────────"
echo " Summary: $pass passed, $warn warnings, $fail failed"
echo "────────────────────────────────────────"
if (( fail > 0 )); then echo "Status: NEEDS WORK — fix ✘ above"; exit 1; elif (( warn > 5 )); then echo "Status: WARNINGS — mostly usable, check ⚠"; exit 0; else echo "Status: HEALTHY"; exit 0; fi
