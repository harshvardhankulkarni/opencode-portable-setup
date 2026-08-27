#!/usr/bin/env bash
set -euo pipefail

# opencode-portable-setup — Linux/macOS installer (FULL STACK)
# opencode + Claude Code + Codex + OmniRoute + FreeLLMAPI + gemini/qwen stubs
# Idempotent, backs up existing configs, patches Windows paths -> portable.
# Usage:
#   ./scripts/install.sh [--force] [--no-backup] [--latest] [--skip-globals] [--verbose] [--help]

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORCE=false
NO_BACKUP=false
LATEST=false
SKIP_GLOBALS=false
VERBOSE=false
SKIP_MCP_BIN=false

for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=true ;;
    --no-backup) NO_BACKUP=true ;;
    --latest) LATEST=true ;;
    --skip-globals) SKIP_GLOBALS=true ;;
    --skip-mcp-bin) SKIP_MCP_BIN=true ;;
    --verbose|-v) VERBOSE=true ;;
    --help|-h)
      echo "Usage: $0 [--force] [--no-backup] [--latest] [--skip-globals] [--skip-mcp-bin] [--verbose]"
      echo "  --force         overwrite without prompting"
      echo "  --no-backup     do not backup existing dirs"
      echo "  --latest        ignore pinned versions, install latest"
      echo "  --skip-globals  skip npm i -g globals"
      echo "  --skip-mcp-bin  skip local binary checks"
      echo "  --verbose       extra logging"
      exit 0
      ;;
    *) echo "Unknown arg: $arg (try --help)"; exit 1 ;;
  esac
done

# --- helpers ---
log()  { echo -e "\033[1;34m[install]\033[0m $*"; }
ok()   { echo -e "\033[1;32m[  ok  ]\033[0m $*"; }
warn() { echo -e "\033[1;33m[ warn ]\033[0m $*"; }
err()  { echo -e "\033[1;31m[ fail ]\033[0m $*" >&2; }

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Missing required command: $1"
    return 1
  fi
  $VERBOSE && ok "found $1: $(command -v "$1")"
  return 0
}

backup_dir() {
  local src="$1"
  if [[ ! -e "$src" ]]; then return 0; fi
  if $NO_BACKUP; then
    warn "Skipping backup for $src (--no-backup)"
    return 0
  fi
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  local dst="${src}.backup-${ts}"
  log "Backing up $src -> $dst"
  cp -a "$src" "$dst"
  ok "Backup: $dst"
}

ensure_dir() { mkdir -p "$1"; }

# --- banner ---
cat <<'BANNER'
┌──────────────────────────────────────────────┐
│  opencode-portable-setup  •  Linux/macOS      │
│  opencode 236 + claude 274 + codex + omni    │
│  :20128 + freellmapi :31415 — full portable  │
└──────────────────────────────────────────────┘
BANNER
log "Repo: $REPO_DIR"
log "Flags: force=$FORCE no_backup=$NO_BACKUP latest=$LATEST skip_globals=$SKIP_GLOBALS verbose=$VERBOSE"

HOME_DIR="${HOME}"
CONFIG_DIR="${HOME}/.config/opencode"
AGENTS_SKILLS_DIR="${HOME}/.agents/skills"
OHMY_DIR="${CONFIG_DIR}/.oh-my-opencode-slim"
CLAUDE_DIR="${HOME}/.claude"
CODEX_DIR="${HOME}/.codex"
OMNI_DIR="${HOME}/.omniroute"

# --- 1. prereqs ---
log "1/13 Prerequisites"
need node || { err "Install Node.js >=20: https://nodejs.org or via nvm/brew"; exit 1; }
need npm  || { err "npm missing (comes with Node)"; exit 1; }
need git  || { err "git missing: https://git-scm.com"; exit 1; }
NODE_V="$(node --version | sed 's/v//')"
NODE_MAJOR="${NODE_V%%.*}"
if (( NODE_MAJOR < 20 )); then
  warn "Node $NODE_V < 20 — opencode needs Node 20+. Please upgrade (nvm install 22 / brew upgrade node)."
  if ! $FORCE; then
    read -rp "Continue anyway? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 1
  fi
else
  ok "Node $NODE_V"
fi
ok "npm $(npm --version)"

if command -v bun >/dev/null 2>&1; then
  ok "bun $(bun --version)"
else
  warn "bun not found — recommended (some skills install via bun). Install: curl -fsSL https://bun.sh/install | bash  OR  npm i -g bun"
fi
if command -v gh >/dev/null 2>&1; then
  ok "gh $(gh --version | head -n1)"
else
  warn "gh CLI not found — needed for github MCP + repo creation. Install: https://cli.github.com"
fi
if command -v pnpm >/dev/null 2>&1; then ok "pnpm $(pnpm --version)"; fi
if command -v vercel >/dev/null 2>&1; then ok "vercel $(vercel --version 2>&1 | head -n1)"; fi

# --- 2. backups ---
log "2/13 Backups"
backup_dir "$CONFIG_DIR"
backup_dir "$AGENTS_SKILLS_DIR"
backup_dir "$CLAUDE_DIR"
backup_dir "$CODEX_DIR"
backup_dir "$OMNI_DIR"
backup_dir "${CONFIG_DIR}/.oh-my-opencode-slim"

# --- 3. global npm packages (pinned) ---
if $SKIP_GLOBALS; then
  warn "Skipping global npm packages (--skip-globals)"
else
  log "3/13 Global npm packages (pinned versions in tools/global-npm-packages.txt)"
  GLOBALS_FILE="${REPO_DIR}/tools/global-npm-packages.txt"
  if [[ -f "$GLOBALS_FILE" ]]; then
    declare -A PINNED=(
      ["opencode-ai"]="1.18.23"
      ["@opencode-ai/cli"]="0.0.0-beta-18155"
      ["vercel"]="54.18.5"
      ["@anthropic-ai/claude-code"]="2.1.241"
      ["openclaw"]="2026.6.9"
      ["firecrawl-cli"]="1.20.0"
      ["agent-browser"]="0.29.1"
      ["ruflo"]="3.10.46"
      ["omniroute"]="3.8.49"
      ["freellmapi"]="0.5.0"
      ["bun"]="1.3.14"
      ["sass"]="1.101.0"
      ["pnpm"]="11.20.0"
      ["@kilocode/cli"]="7.3.45"
      ["bobshell"]="1.0.4"
      ["zoho-extension-toolkit"]="1.0.28"
      ["zcatalyst-cli"]="1.25.3"
    )
    for pkg in "${!PINNED[@]}"; do
      ver="${PINNED[$pkg]}"
      spec="$pkg@$ver"
      if $LATEST; then
        spec="$pkg@latest"
        log "  -> $spec (latest, --latest)"
      else
        log "  -> $spec (pinned)"
      fi
      if npm list -g "$pkg" --depth=0 2>/dev/null | grep -q "$ver" && ! $LATEST; then
        ok "  already installed: $spec"
        continue
      fi
      if $FORCE; then
        log "  installing $spec ..."
        npm i -g "$spec" || warn "Failed to install $spec — try manually: npm i -g $spec"
      fi
    done
    if ! $FORCE; then
      echo ""
      warn "About to run npm i -g for pinned globals above. This may take 2-5 min."
      read -rp "Install/update global packages now? [Y/n] " ans
      if [[ ! "$ans" =~ ^[Nn]$ ]]; then
        for pkg in "${!PINNED[@]}"; do
          ver="${PINNED[$pkg]}"
          spec="$pkg@$ver"
          $LATEST && spec="$pkg@latest"
          log "  npm i -g $spec"
          npm i -g "$spec" || warn "Failed: $spec"
        done
        ok "Globals installed"
      else
        warn "Skipped global installs — run manually or re-run with --force"
        cat <<'MANUAL'
  npm i -g opencode-ai@1.18.23 @opencode-ai/cli@0.0.0-beta-18155 vercel@54.18.5 \
    @anthropic-ai/claude-code@2.1.241 openclaw@2026.6.9 firecrawl-cli@1.20.0 \
    agent-browser@0.29.1 ruflo@3.10.46 omniroute@3.8.49 freellmapi@0.5.0 bun@1.3.14 sass@1.101.0
MANUAL
      fi
    fi
  else
    warn "tools/global-npm-packages.txt not found — skipping globals"
  fi
fi

# --- 4. ensure dirs ---
log "4/13 Create directories"
ensure_dir "$CONFIG_DIR"
ensure_dir "$CONFIG_DIR/agents"
ensure_dir "$CONFIG_DIR/skills"
ensure_dir "$OHMY_DIR"
ensure_dir "$AGENTS_SKILLS_DIR"
ensure_dir "$CLAUDE_DIR"
ensure_dir "$CLAUDE_DIR/agents"
ensure_dir "$CLAUDE_DIR/skills"
ensure_dir "$CLAUDE_DIR/commands"
ensure_dir "$CLAUDE_DIR/hooks"
ensure_dir "$CODEX_DIR"
ensure_dir "$OMNI_DIR"
ensure_dir "${HOME}/.local/bin"
ok "dirs ready"

# --- 5. opencode configs (with path patching) ---
log "5/13 Opencode configs -> $CONFIG_DIR"
PATCHER="${REPO_DIR}/scripts/lib/patch-config.mjs"
if [[ -f "$PATCHER" ]]; then
  log "  patching opencode.json (Windows paths -> $HOME_DIR)"
  node "$PATCHER" --src "${REPO_DIR}/config/opencode.json" --dst "${CONFIG_DIR}/opencode.json" --home "$HOME_DIR" --os "$(uname -s | tr '[:upper:]' '[:lower:]' | sed 's/linux/linux/;s/darwin/darwin/;s/ming.*/win32/')"
  ok "  opencode.json patched"
else
  warn "patcher not found — copying raw opencode.json (you may need to edit Windows paths)"
  cp "${REPO_DIR}/config/opencode.json" "${CONFIG_DIR}/opencode.json"
fi

for f in cli.json tui.json AGENTS.md; do
  if [[ -f "${REPO_DIR}/config/${f}" ]]; then
    cp "${REPO_DIR}/config/${f}" "${CONFIG_DIR}/${f}"
    ok "  $f"
  fi
done
cp "${REPO_DIR}/config/package.json" "${CONFIG_DIR}/package.json"
if [[ -f "${REPO_DIR}/config/package-lock.json" ]]; then
  cp "${REPO_DIR}/config/package-lock.json" "${CONFIG_DIR}/package-lock.json"
fi
ok "  package.json"
cp "${REPO_DIR}/config/.ponytail-active" "${CONFIG_DIR}/.ponytail-active" 2>/dev/null || true
cp "${REPO_DIR}/config/mcp-legacy.json" "${CONFIG_DIR}/mcp-legacy.json" 2>/dev/null || true
cp "${REPO_DIR}/config/supabase-mcp-config.json.example" "${CONFIG_DIR}/supabase-mcp-config.json.example" 2>/dev/null || true
cp "${REPO_DIR}/config/service.json.example" "${CONFIG_DIR}/service.json.example" 2>/dev/null || true
cp "${REPO_DIR}/config/service.json.example" "${CONFIG_DIR}/service.json" 2>/dev/null || true

if [[ -f "${REPO_DIR}/config/skills-manifest.json" ]]; then
  ensure_dir "$OHMY_DIR"
  cp "${REPO_DIR}/config/skills-manifest.json" "${OHMY_DIR}/skills-manifest.json"
  cp "${REPO_DIR}/config/skills-manifest.json" "${CONFIG_DIR}/skills-manifest.json" 2>/dev/null || true
  ok "  skills-manifest.json"
fi
if [[ -f "${REPO_DIR}/config/skill-lock.json" ]]; then
  ensure_dir "$(dirname "$AGENTS_SKILLS_DIR")"
  ensure_dir "$AGENTS_SKILLS_DIR"
  if [[ -f "${HOME}/.agents/.skill-lock.json" ]] && ! $FORCE; then
    warn "  ~/.agents/.skill-lock.json exists — keeping existing (use --force to overwrite)"
  else
    mkdir -p "${HOME}/.agents"
    cp "${REPO_DIR}/config/skill-lock.json" "${HOME}/.agents/.skill-lock.json"
    ok "  skill-lock.json -> ~/.agents/.skill-lock.json"
  fi
fi

# --- 6. npm install in config dir (ponytail + plugin) ---
log "6/13 npm install in $CONFIG_DIR (ponytail + @opencode-ai/plugin)"
pushd "$CONFIG_DIR" >/dev/null
if [[ -f package.json ]]; then
  if $VERBOSE; then
    npm install || { warn "npm install failed — check $CONFIG_DIR/package.json"; }
  else
    npm install --silent || { warn "npm install failed — run manually: cd $CONFIG_DIR && npm install"; }
  fi
  ok "  npm install done"
else
  warn "  no package.json"
fi
popd >/dev/null

# --- 7. opencode agents (236) ---
log "7/13 Opencode agents (236) -> $CONFIG_DIR/agents"
if [[ -d "${REPO_DIR}/agents" ]]; then
  if $FORCE; then
    rm -rf "${CONFIG_DIR}/agents"
    mkdir -p "${CONFIG_DIR}/agents"
  fi
  cp -a "${REPO_DIR}/agents/"* "${CONFIG_DIR}/agents/" 2>/dev/null || cp -r "${REPO_DIR}/agents/"* "${CONFIG_DIR}/agents/"
  count="$(ls -1 "${CONFIG_DIR}/agents" 2>/dev/null | wc -l | tr -d ' ')"
  ok "  agents: $count"
  if [[ "$count" != "236" && "$count" != "237" ]]; then
    warn "  expected 236 agents, got $count — check repo"
  fi
else
  err "  repo agents/ missing"
fi

# --- 8. opencode skills ---
log "8/13 Opencode skills"

if [[ -d "${REPO_DIR}/skills/opencode-managed" ]]; then
  for link in "${CONFIG_DIR}/skills"/firecrawl*; do
    [[ -L "$link" ]] && rm -f "$link" || true
  done
  mkdir -p "${CONFIG_DIR}/skills"
  if $FORCE; then
    for d in "${REPO_DIR}/skills/opencode-managed"/*; do
      bn="$(basename "$d")"
      rm -rf "${CONFIG_DIR}/skills/$bn"
    done
  fi
  cp -a "${REPO_DIR}/skills/opencode-managed/"* "${CONFIG_DIR}/skills/" 2>/dev/null || cp -r "${REPO_DIR}/skills/opencode-managed/"* "${CONFIG_DIR}/skills/"
  cnt_managed="$(ls -1 "${CONFIG_DIR}/skills" 2>/dev/null | wc -l | tr -d ' ')"
  ok "  opencode-managed -> ${CONFIG_DIR}/skills/ ($cnt_managed entries, expected ~14 + symlinks)"
else
  warn "  opencode-managed missing"
fi

if [[ -d "${REPO_DIR}/skills/external-full" ]]; then
  mkdir -p "$AGENTS_SKILLS_DIR"
  if command -v rsync >/dev/null 2>&1; then
    if $FORCE; then
      rsync -a --delete "${REPO_DIR}/skills/external-full/" "${AGENTS_SKILLS_DIR}/" 2>&1 | head -n 20 || true
    else
      rsync -a "${REPO_DIR}/skills/external-full/" "${AGENTS_SKILLS_DIR}/" >/dev/null 2>&1 || true
    fi
  else
    cp -a "${REPO_DIR}/skills/external-full/"* "${AGENTS_SKILLS_DIR}/" 2>/dev/null || cp -R "${REPO_DIR}/skills/external-full/"* "${AGENTS_SKILLS_DIR}/"
  fi
  cnt_ext="$(ls -1 "$AGENTS_SKILLS_DIR" 2>/dev/null | wc -l | tr -d ' ')"
  ok "  external -> ${AGENTS_SKILLS_DIR}/ ($cnt_ext entries, expected ~91)"
  if [[ "$cnt_ext" -lt 80 ]]; then
    warn "  low count — expected ~91"
  fi
else
  warn "  external-full missing"
fi

log "  Symlinks (33 firecrawl* -> ~/.agents/skills)"
symlink_count=0
for skill in "${AGENTS_SKILLS_DIR}"/firecrawl*; do
  [[ -e "$skill" ]] || continue
  bn="$(basename "$skill")"
  target="${AGENTS_SKILLS_DIR}/${bn}"
  link="${CONFIG_DIR}/skills/${bn}"
  if [[ -e "$link" ]] || [[ -L "$link" ]]; then
    rm -rf "$link"
  fi
  ln -sf "$target" "$link" && ((symlink_count++)) || warn "  symlink failed: $link -> $target"
  $VERBOSE && ok "  $bn -> $target"
done
ok "  symlinks: $symlink_count (expected 33)"
if (( symlink_count != 33 )) && (( symlink_count != 0 )); then
  warn "  symlink count mismatch — check ~/.agents/skills for firecrawl*"
fi

# --- 9. Claude Code ---
log "9/13 Claude Code ($CLAUDE_DIR)"
CLAUDE_SETTINGS_SRC="${REPO_DIR}/claude/settings.json"
if [[ -f "$CLAUDE_SETTINGS_SRC" ]]; then
  cp "$CLAUDE_SETTINGS_SRC" "$CLAUDE_DIR/settings.json"
  ok "  settings.json"
fi
CLAUDE_MCP_SRC="${REPO_DIR}/claude/mcp.json"
if [[ -f "$CLAUDE_MCP_SRC" ]]; then
  # patch any remaining Windows path if needed (replace PilzIndia with HOME)
  sed "s|C:/Users/PilzIndia|${HOME_DIR}|g; s|C:\\\\Users\\\\PilzIndia|${HOME_DIR}|g" "$CLAUDE_MCP_SRC" > "$CLAUDE_DIR/.mcp.json"
  ok "  .mcp.json"
fi
if [[ -f "${REPO_DIR}/claude/CLAUDE.md" ]]; then
  cp "${REPO_DIR}/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
  ok "  CLAUDE.md"
fi
for sub in agents skills commands hooks; do
  src="${REPO_DIR}/claude/${sub}"
  dst="$CLAUDE_DIR/${sub}"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    if $FORCE && [[ "$sub" == "agents" || "$sub" == "skills" ]]; then
      rm -rf "${dst:?}"/* 2>/dev/null || true
    fi
    if command -v rsync >/dev/null 2>&1; then
      rsync -a "${src}/" "${dst}/" >/dev/null 2>&1 || cp -a "${src}/"* "${dst}/" 2>/dev/null || cp -r "${src}/"* "${dst}/"
    else
      cp -a "${src}/"* "${dst}/" 2>/dev/null || cp -r "${src}/"* "${dst}/"
    fi
    cnt=$(find "$dst" -type f 2>/dev/null | wc -l | tr -d ' ')
    ok "  $sub -> $dst ($cnt files)"
  fi
done
if [[ -d "${REPO_DIR}/claude/plugins" ]]; then
  mkdir -p "$CLAUDE_DIR/plugins"
  for f in "${REPO_DIR}/claude/plugins"/*; do
    [[ -f "$f" ]] && cp "$f" "$CLAUDE_DIR/plugins/" 2>/dev/null || true
  done
  ok "  plugins inventories"
fi
HOME_MCP_SRC="${REPO_DIR}/claude/home-mcp.json.example"
HOME_MCP_DST="${HOME}/.mcp.json"
if [[ -f "$HOME_MCP_SRC" ]]; then
  if [[ -f "$HOME_MCP_DST" ]] && ! $FORCE; then
    warn "  ~/.mcp.json exists — keeping (use --force to overwrite)"
  else
    cp "$HOME_MCP_SRC" "$HOME_MCP_DST"
    ok "  ~/.mcp.json (claude-flow ruflo)"
  fi
fi

# --- 10. Codex ---
log "10/13 Codex ($CODEX_DIR)"
CODEX_SRC="${REPO_DIR}/codex/config.toml"
if [[ -f "$CODEX_SRC" ]]; then
  sed "s|C:/Users/PilzIndia|${HOME_DIR}|g" "$CODEX_SRC" > "$CODEX_DIR/config.toml"
  ok "  config.toml"
fi
if [[ -d "${REPO_DIR}/codex/skills" ]]; then
  mkdir -p "$CODEX_DIR/skills"
  cp -a "${REPO_DIR}/codex/skills/"* "$CODEX_DIR/skills/" 2>/dev/null || cp -r "${REPO_DIR}/codex/skills/"* "$CODEX_DIR/skills/"
  cnt=$(find "$CODEX_DIR/skills" -type f 2>/dev/null | wc -l | tr -d ' ')
  ok "  skills -> $CODEX_DIR/skills ($cnt files)"
fi

# --- 11. OmniRoute ---
log "11/13 OmniRoute ($OMNI_DIR :20128)"
mkdir -p "$OMNI_DIR"
OMNI_SRC="${REPO_DIR}/omniroute/.env.example"
OMNI_DST="$OMNI_DIR/.env"
if [[ ! -f "$OMNI_DST" ]] && [[ -f "$OMNI_SRC" ]]; then
  cp "$OMNI_SRC" "$OMNI_DST"
  warn "  Created $OMNI_DST from template — FILL STORAGE_ENCRYPTION_KEY / JWT_SECRET / API_KEY_SECRET / INITIAL_PASSWORD"
  echo "   Generate: openssl rand -hex 32 ; openssl rand -base64 48"
elif [[ -f "$OMNI_DST" ]]; then
  ok "  ~/.omniroute/.env exists"
else
  warn "  omniroute/.env.example missing in repo"
fi

# --- 11b. freellmapi-keys.json bundle (21 providers) ---
log "11b/13 freellmapi-keys.json (21 providers)"
KEYS_FOUND=""
for cand in "./freellmapi-keys.json" "./freellmapi/keys.json" "$HOME/freellmapi-keys.json" "$HOME/Desktop/freellmapi-keys.json" "$HOME/.freellmapi/keys.json" "$REPO_DIR/freellmapi-keys.json" "$REPO_DIR/freellmapi/keys.json"; do
  if [[ -f "$cand" ]]; then KEYS_FOUND="$cand"; break; fi
done
if [[ -n "$KEYS_FOUND" ]]; then
  ok "  found $KEYS_FOUND"
  if command -v node >/dev/null 2>&1; then
    if [[ -f "$REPO_DIR/scripts/lib/import-freellmapi-keys.mjs" ]]; then
      node "$REPO_DIR/scripts/lib/import-freellmapi-keys.mjs" --check "$KEYS_FOUND" 2>&1 | sed "s/^/  /" || warn "  keys check warnings"
    fi
  fi
  if [[ "$KEYS_FOUND" != "$REPO_DIR/freellmapi-keys.json" && "$KEYS_FOUND" != "$REPO_DIR/freellmapi/keys.json" ]]; then
    mkdir -p "$REPO_DIR/freellmapi" 2>/dev/null || true
    cp "$KEYS_FOUND" "$REPO_DIR/freellmapi/keys.json" 2>/dev/null || true
    if [[ ! -f "$REPO_DIR/freellmapi-keys.json" ]]; then cp "$KEYS_FOUND" "$REPO_DIR/freellmapi-keys.json" 2>/dev/null || true; fi
    ok "  copied to ./freellmapi-keys.json (gitignored)"
  fi
else
  warn "  freellmapi-keys.json not found — upload your 21-provider bundle to use all 70+ models"
  echo "   cp ~/Downloads/freellmapi-keys.json ./freellmapi-keys.json   # or ./freellmapi/keys.json (both gitignored)"
  echo "   node scripts/lib/import-freellmapi-keys.mjs --check          # validates 21 keys (masked)"
  echo "   Docs: docs/FREELLMAPI_KEYS.md — per-provider where-to-get (21 rows)"
  echo "   Template: freellmapi/keys.json.example (redacted)"
fi


# --- 11c. Qwen / KiloCode / Gemini ---
log "11c/13 Qwen / KiloCode / Gemini"
if [[ -d "$REPO_DIR/qwen/skills" ]]; then
  mkdir -p "$HOME/.qwen"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$REPO_DIR/qwen/skills/" "$HOME/.qwen/skills/" 2>&1 | head -n 5 || true
  else
    mkdir -p "$HOME/.qwen/skills"
    cp -a "$REPO_DIR/qwen/skills/"* "$HOME/.qwen/skills/" 2>/dev/null || cp -r "$REPO_DIR/qwen/skills/"* "$HOME/.qwen/skills/" 2>/dev/null || true
  fi
  cnt=$(find "$HOME/.qwen/skills" -type f 2>/dev/null | wc -l | tr -d " ")
  ok "  qwen skills -> $HOME/.qwen/skills ($cnt files)"
  if [[ -f "$REPO_DIR/qwen/settings.json.example" ]]; then
    if [[ ! -f "$HOME/.qwen/settings.json" ]] || $FORCE; then
      mkdir -p "$HOME/.qwen"
      cp "$REPO_DIR/qwen/settings.json.example" "$HOME/.qwen/settings.json" 2>/dev/null || true
      ok "  qwen settings.json"
    fi
  fi
fi
if [[ -d "$REPO_DIR/kilocode/skills" ]]; then
  mkdir -p "$HOME/.kilocode"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$REPO_DIR/kilocode/skills/" "$HOME/.kilocode/skills/" 2>&1 | head -n 5 || true
  else
    mkdir -p "$HOME/.kilocode/skills"
    cp -a "$REPO_DIR/kilocode/skills/"* "$HOME/.kilocode/skills/" 2>/dev/null || cp -r "$REPO_DIR/kilocode/skills/"* "$HOME/.kilocode/skills/" 2>/dev/null || true
  fi
  ok "  kilocode skills -> $HOME/.kilocode/skills ($(find "$HOME/.kilocode/skills" -type f 2>/dev/null | wc -l | tr -d " ") files)"
fi
if [[ -d "$REPO_DIR/kilocode/rules" ]]; then
  mkdir -p "$HOME/.kilocode/rules"
  cp -a "$REPO_DIR/kilocode/rules/"* "$HOME/.kilocode/rules/" 2>/dev/null || cp -r "$REPO_DIR/kilocode/rules/"* "$HOME/.kilocode/rules/" 2>/dev/null || true
  ok "  kilocode rules -> $HOME/.kilocode/rules"
fi
if [[ -d "$REPO_DIR/gemini/config" ]]; then
  mkdir -p "$HOME/.gemini/config"
  cp -a "$REPO_DIR/gemini/config/"* "$HOME/.gemini/config/" 2>/dev/null || cp -r "$REPO_DIR/gemini/config/"* "$HOME/.gemini/config/" 2>/dev/null || true
  ok "  gemini config -> $HOME/.gemini/config"
fi
if [[ -f "$REPO_DIR/gemini/GEMINI.md" && -s "$REPO_DIR/gemini/GEMINI.md" ]]; then
  mkdir -p "$HOME/.gemini"
  cp "$REPO_DIR/gemini/GEMINI.md" "$HOME/.gemini/GEMINI.md" 2>/dev/null || true
fi
# --- 12. FreeLLMAPI wiring ---
log "12/13 FreeLLMAPI wiring (:31415) — runs npx freellmapi setup-* if installed"
FREELLM_OK=false
if command -v freellmapi >/dev/null 2>&1; then FREELLM_OK=true
elif npx freellmapi --version >/dev/null 2>&1; then FREELLM_OK=true; fi

if $FREELLM_OK; then
  for target in claude codex opencode qwen; do
    log "  npx freellmapi setup-$target --url http://127.0.0.1:31415"
    npx freellmapi "setup-$target" --url http://127.0.0.1:31415 2>&1 | head -n 20 || warn "  setup-$target failed"
  done
  ok "  freellmapi wiring attempted"
else
  warn "  freellmapi not found — install first: npm i -g freellmapi@0.5.0"
  warn "  Then run manually:"
  echo "   npx freellmapi setup-claude --url http://127.0.0.1:31415"
  echo "   npx freellmapi setup-codex --url http://127.0.0.1:31415"
  echo "   npx freellmapi setup-opencode --url http://127.0.0.1:31415"
fi

# --- 13. env file ---
log "13/13 Environment file"
REPO_ENV="${REPO_DIR}/.env"
EXAMPLE_ENV="${REPO_DIR}/.env.example"
if [[ ! -f "$REPO_ENV" ]] && [[ -f "$EXAMPLE_ENV" ]]; then
  cp "$EXAMPLE_ENV" "$REPO_ENV"
  ok "  Created $REPO_ENV from .env.example"
  cat <<ENVMSG
  ┌─ Next: fill your API keys ──────────────────────┐
  │  nano $REPO_ENV                              │
  │  Required: GITHUB_TOKEN, FIRECRAWL_API_KEY    │
  │  Gateways: FREELLMAPI_API_KEY, ANTHROPIC_AUTH_TOKEN, OMNIROUTE_API_KEY │
  │  OmniRoute: edit ~/.omniroute/.env            │
  │  Never commit .env (gitignored).              │
  └───────────────────────────────────────────────┘
ENVMSG
  if [[ -f "$HOME/.zshrc" ]]; then
    warn "  Tip: add 'set -a; source $REPO_ENV; set +a' to ~/.zshrc to auto-load, or export manually"
  elif [[ -f "$HOME/.bashrc" ]]; then
    warn "  Tip: add 'set -a; source $REPO_ENV; set +a' to ~/.bashrc to auto-load"
  fi
else
  ok "  .env exists: $REPO_ENV"
  for var in GITHUB_TOKEN FIRECRAWL_API_KEY; do
    if grep -q "^${var}=" "$REPO_ENV" 2>/dev/null && ! grep -q "^${var}=.*xxxx" "$REPO_ENV"; then
      ok "  $var looks set in .env"
    else
      warn "  $var missing or placeholder in .env — set it for full MCP functionality"
    fi
  done
fi

cat > "${REPO_DIR}/.env.loader.sh" <<LOADER
# Source this to load .env into current shell: source .env.loader.sh
if [[ -f "${REPO_ENV}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${REPO_ENV}"
  set +a
  echo "[env] Loaded ${REPO_ENV}"
else
  echo "[env] No .env at ${REPO_ENV} — copy from .env.example"
fi
LOADER

# --- local binaries notice ---
if ! $SKIP_MCP_BIN; then
  echo ""
  log "Local binaries (platform-specific)"
  for bin in codebase-memory-mcp graphify officecli; do
    if command -v "$bin" >/dev/null 2>&1; then
      ok "  $bin: $(command -v "$bin")"
    else
      warn "  $bin not found in PATH — related MCP will be disabled until installed."
      case "$bin" in
        codebase-memory-mcp) echo "      Install: download appropriate binary for $(uname -m) from releases or build via cargo" ;;
        graphify) echo "      Install: see tools/local-binaries/README.md" ;;
        officecli) echo "      Install: https://github.com/.../officecli — or npm i -g officecli" ;;
      esac
    fi
  done
  echo "  See tools/local-binaries/README.md and mcp/manifest.unified.json for per-OS paths."
  if grep -q "PilzIndia" "${CONFIG_DIR}/opencode.json" 2>/dev/null; then
    warn "  opencode.json still contains Windows paths (PilzIndia) — patch-config may have failed. Run:"
    echo "    node ${REPO_DIR}/scripts/lib/patch-config.mjs --src ${CONFIG_DIR}/opencode.json --home $HOME_DIR"
  fi
fi

# --- done ---
echo ""
cat <<DONE
┌──────────────────────────────────────────────┐
│  Install complete!  Next steps:              │
└──────────────────────────────────────────────┘
  1) Fill ${REPO_ENV}  (nano .env)  +  ~/.omniroute/.env
     source .env.loader.sh  # load into current shell
     # or: export GITHUB_TOKEN=ghp_... etc.

  2) Verify:
     ./scripts/verify.sh           # full health check
     opencode --version            # should be >= 1.18
     claude --version ; codex --version

  3) Start gateways (separate terminals):
     omniroute                     # :20128 dashboard
     npx freellmapi serve --port 31415  # :31415

  4) Launch:
     opencode                      # TUI at http://127.0.0.1:3000
     claude                        # Claude Code -> FreeLLMAPI auto
     codex                         # Codex -> FreeLLMAPI auto

  Docs: README.md · docs/INVENTORY.md · docs/INSTALL.md
        mcp/README.md · docs/ENV_VARS.md · docs/MCP.md

  To update later: git pull && ./scripts/install.sh
DONE

if [[ -x "${REPO_DIR}/scripts/verify.sh" ]]; then
  echo ""
  log "Running quick verify..."
  bash "${REPO_DIR}/scripts/verify.sh" --quick || warn "verify reported issues — see output above"
fi
