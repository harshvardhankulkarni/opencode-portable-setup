# install.ps1 — Windows installer for opencode-portable-setup (full stack)
# Idempotent, backs up existing configs, patches paths, wires FreeLLMAPI + OmniRoute
# Usage: .\scripts\install.ps1 [-Force] [-NoBackup] [-Latest] [-SkipGlobals] [-SkipMcpBin] [-Verbose]

param(
  [switch]$Force,
  [switch]$NoBackup,
  [switch]$Latest,
  [switch]$SkipGlobals,
  [switch]$SkipMcpBin,
  [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$RepoDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$HomeDir = $env:USERPROFILE
$ConfigDir = Join-Path $HomeDir ".config\opencode"
$AgentsSkillsDir = Join-Path $HomeDir ".agents\skills"
$OhMyDir = Join-Path $ConfigDir ".oh-my-opencode-slim"
$ClaudeDir = Join-Path $HomeDir ".claude"
$CodexDir = Join-Path $HomeDir ".codex"
$OmniDir = Join-Path $HomeDir ".omniroute"

function Log($m){ Write-Host "[install] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[  ok  ] $m" -ForegroundColor Green }
function Wrn($m){ Write-Host "[ warn ] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ fail ] $m" -ForegroundColor Red }

Write-Host "┌──────────────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "│  opencode-portable-setup  •  Windows         │" -ForegroundColor Cyan
Write-Host "│  236 agents · 105 skills · 274 claude agts  │" -ForegroundColor Cyan
Write-Host "│  codex + omniroute :20128 + freellmapi :31415 │" -ForegroundColor Cyan
Write-Host "└──────────────────────────────────────────────┘"
Log "Repo: $RepoDir"
Log "Flags: Force=$Force NoBackup=$NoBackup Latest=$Latest SkipGlobals=$SkipGlobals Verbose=$Verbose"

function Need($cmd){
  $c = Get-Command $cmd -ErrorAction SilentlyContinue
  if(-not $c){ Err "Missing required command: $cmd"; return $false }
  if($Verbose){ Ok "found $cmd : $($c.Source)" }
  return $true
}
function BackupDir($src){
  if(-not (Test-Path $src)){ return }
  if($NoBackup){ Wrn "Skipping backup for $src (-NoBackup)"; return }
  $ts = Get-Date -Format "yyyyMMdd-HHmmss"
  $dst = "$src.backup-$ts"
  Log "Backing up $src -> $dst"
  Copy-Item -Path $src -Destination $dst -Recurse -Force
  Ok "Backup: $dst"
}
function EnsureDir($p){ if(-not (Test-Path $p)){ New-Item -ItemType Directory -Force -Path $p | Out-Null } }

# 1. Prereqs
Log "1/12 Prerequisites"
if(-not (Need "node")){ Err "Install Node.js >=20: https://nodejs.org or winget install OpenJS.NodeJS"; exit 1 }
if(-not (Need "npm")){ Err "npm missing"; exit 1 }
if(-not (Need "git")){ Err "git missing: https://git-scm.com"; exit 1 }
$nodeV = (node --version).Trim().TrimStart('v')
$major = [int]($nodeV.Split('.')[0])
if($major -lt 20){
  Wrn "Node $nodeV < 20 — opencode needs 20+. Upgrade: winget install OpenJS.NodeJS"
  if(-not $Force){ $ans = Read-Host "Continue anyway? [y/N]"; if($ans -notmatch '^[Yy]'){ exit 1 } }
} else { Ok "Node $nodeV" }
Ok "npm $(npm --version)"
foreach($c in @('bun','gh','pnpm','vercel')){
  $cmd = Get-Command $c -ErrorAction SilentlyContinue
  if($cmd){ Ok "$c $((& $c --version 2>&1 | Select-Object -First 1))" } else { Wrn "$c not found — optional but recommended" }
}

# 2. Backups
Log "2/12 Backups"
BackupDir $ConfigDir
BackupDir $AgentsSkillsDir
BackupDir $ClaudeDir
BackupDir $CodexDir
BackupDir $OmniDir
BackupDir (Join-Path $ConfigDir ".oh-my-opencode-slim")

# 3. Global npm packages (pinned)
if($SkipGlobals){
  Wrn "Skipping global npm packages (-SkipGlobals)"
} else {
  Log "3/12 Global npm packages (pinned)"
  $pinned = @{
    "opencode-ai" = "1.18.23"
    "@opencode-ai/cli" = "0.0.0-beta-18155"
    "vercel" = "54.18.5"
    "@anthropic-ai/claude-code" = "2.1.241"
    "openclaw" = "2026.6.9"
    "firecrawl-cli" = "1.20.0"
    "agent-browser" = "0.29.1"
    "ruflo" = "3.10.46"
    "omniroute" = "3.8.49"
    "freellmapi" = "0.5.0"
    "bun" = "1.3.14"
    "sass" = "1.101.0"
    "pnpm" = "11.20.0"
    "@kilocode/cli" = "7.3.45"
    "bobshell" = "1.0.4"
    "zoho-extension-toolkit" = "1.0.28"
    "zcatalyst-cli" = "1.25.3"
  }
  foreach($pkg in $pinned.Keys){
    $ver = $pinned[$pkg]
    $spec = if($Latest){ "$pkg@latest" } else { "$pkg@$ver" }
    Log "  -> $spec"
    # check installed
    try{
      $installed = npm list -g $pkg --depth=0 2>&1 | Out-String
      if($installed -match [regex]::Escape($ver) -and -not $Latest){ Ok "  already installed: $spec"; continue }
    } catch {}
    if($Force){
      Log "  installing $spec ..."
      try{ npm i -g $spec 2>&1 | Out-String | Write-Host; Ok "  installed $spec" } catch{ Wrn "Failed: $spec — try manually: npm i -g $spec" }
    }
  }
  if(-not $Force){
    Wrn "About to npm i -g for pinned globals (2-5 min). Run again with -Force to auto-install."
    $ans = Read-Host "Install/update globals now? [Y/n]"
    if($ans -notmatch '^[Nn]'){
      foreach($pkg in $pinned.Keys){
        $ver = $pinned[$pkg]; $spec = if($Latest){ "$pkg@latest" } else { "$pkg@$ver" }
        Log "  npm i -g $spec"
        try{ npm i -g $spec 2>&1 | Out-String | Write-Host } catch{ Wrn "Failed: $spec" }
      }
      Ok "Globals installed"
    } else {
      Wrn "Skipped — run manually or with -Force"
    }
  }
}

# 4. Ensure dirs
Log "4/12 Create directories"
EnsureDir $ConfigDir; EnsureDir (Join-Path $ConfigDir "agents"); EnsureDir (Join-Path $ConfigDir "skills"); EnsureDir $OhMyDir
EnsureDir $AgentsSkillsDir; EnsureDir $ClaudeDir; EnsureDir (Join-Path $ClaudeDir "agents"); EnsureDir (Join-Path $ClaudeDir "skills"); EnsureDir (Join-Path $ClaudeDir "commands"); EnsureDir (Join-Path $ClaudeDir "hooks")
EnsureDir $CodexDir; EnsureDir $OmniDir
EnsureDir (Join-Path $HomeDir ".local\bin"); EnsureDir (Join-Path $HomeDir "bin")
Ok "dirs ready"

# 5. Opencode configs (patch Windows -> portable)
Log "5/12 Opencode configs -> $ConfigDir"
$patcher = Join-Path $RepoDir "scripts\lib\patch-config.mjs"
if(Test-Path $patcher){
  Log "  patching opencode.json (Windows -> $HomeDir)"
  node $patcher --src (Join-Path $RepoDir "config\opencode.json") --dst (Join-Path $ConfigDir "opencode.json") --home $HomeDir --os win32
  Ok "  opencode.json patched"
} else {
  Copy-Item (Join-Path $RepoDir "config\opencode.json") (Join-Path $ConfigDir "opencode.json") -Force
}
foreach($f in @('cli.json','tui.json','AGENTS.md')){
  $src = Join-Path $RepoDir "config\$f"
  if(Test-Path $src){ Copy-Item $src (Join-Path $ConfigDir $f) -Force; Ok "  $f" }
}
Copy-Item (Join-Path $RepoDir "config\package.json") (Join-Path $ConfigDir "package.json") -Force
if(Test-Path (Join-Path $RepoDir "config\package-lock.json")){ Copy-Item (Join-Path $RepoDir "config\package-lock.json") (Join-Path $ConfigDir "package-lock.json") -Force }
Copy-Item (Join-Path $RepoDir "config\.ponytail-active") (Join-Path $ConfigDir ".ponytail-active") -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $RepoDir "config\mcp-legacy.json") (Join-Path $ConfigDir "mcp-legacy.json") -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $RepoDir "config\supabase-mcp-config.json.example") (Join-Path $ConfigDir "supabase-mcp-config.json.example") -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $RepoDir "config\service.json.example") (Join-Path $ConfigDir "service.json.example") -Force -ErrorAction SilentlyContinue
if(-not (Test-Path (Join-Path $ConfigDir "service.json"))){ Copy-Item (Join-Path $RepoDir "config\service.json.example") (Join-Path $ConfigDir "service.json") -Force -ErrorAction SilentlyContinue }

if(Test-Path (Join-Path $RepoDir "config\skills-manifest.json")){
  EnsureDir $OhMyDir
  Copy-Item (Join-Path $RepoDir "config\skills-manifest.json") (Join-Path $OhMyDir "skills-manifest.json") -Force
  Copy-Item (Join-Path $RepoDir "config\skills-manifest.json") (Join-Path $ConfigDir "skills-manifest.json") -Force -ErrorAction SilentlyContinue
  Ok "  skills-manifest.json"
}
$skillLockSrc = Join-Path $RepoDir "config\skill-lock.json"
if(Test-Path $skillLockSrc){
  $dst = Join-Path $HomeDir ".agents\.skill-lock.json"
  EnsureDir (Split-Path $dst)
  if((Test-Path $dst) -and -not $Force){ Wrn "  ~/.agents/.skill-lock.json exists — keeping (use -Force to overwrite)" }
  else { Copy-Item $skillLockSrc $dst -Force; Ok "  skill-lock.json -> ~/.agents/.skill-lock.json" }
}

# 6. npm install in config dir
Log "6/12 npm install in $ConfigDir (ponytail + plugin)"
Push-Location $ConfigDir
try{
  if(Test-Path "package.json"){
    if($Verbose){ npm install } else { npm install --silent 2>&1 | Out-Null }
    Ok "  npm install done"
  }
} catch{ Wrn "npm install failed — run manually: cd $ConfigDir; npm install" }
Pop-Location

# 7. Opencode agents + skills
Log "7/12 Opencode agents (236) -> $ConfigDir\agents"
$repoAgents = Join-Path $RepoDir "agents"
if(Test-Path $repoAgents){
  if($Force){ Remove-Item (Join-Path $ConfigDir "agents") -Recurse -Force -ErrorAction SilentlyContinue; EnsureDir (Join-Path $ConfigDir "agents") }
  Copy-Item -Path "$repoAgents\*" -Destination (Join-Path $ConfigDir "agents") -Recurse -Force
  $cnt = (Get-ChildItem (Join-Path $ConfigDir "agents") -File -ErrorAction SilentlyContinue | Measure-Object).Count
  Ok "  agents: $cnt"
} else { Err "repo agents/ missing" }

Log "8/12 Opencode skills"
$managed = Join-Path $RepoDir "skills\opencode-managed"
if(Test-Path $managed){
  # clean firecrawl symlinks
  Get-ChildItem (Join-Path $ConfigDir "skills") -Filter "firecrawl*" -Attributes ReparsePoint -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
  EnsureDir (Join-Path $ConfigDir "skills")
  if($Force){ Get-ChildItem $managed | ForEach-Object { Remove-Item (Join-Path $ConfigDir "skills\$($_.Name)") -Recurse -Force -ErrorAction SilentlyContinue } }
  Copy-Item -Path "$managed\*" -Destination (Join-Path $ConfigDir "skills") -Recurse -Force
  $cnt = (Get-ChildItem (Join-Path $ConfigDir "skills") -ErrorAction SilentlyContinue | Measure-Object).Count
  Ok "  opencode-managed -> $ConfigDir\skills ($cnt entries)"
}
$extFull = Join-Path $RepoDir "skills\external-full"
if(Test-Path $extFull){
  EnsureDir $AgentsSkillsDir
  Copy-Item -Path "$extFull\*" -Destination $AgentsSkillsDir -Recurse -Force
  $cnt = (Get-ChildItem $AgentsSkillsDir -ErrorAction SilentlyContinue | Measure-Object).Count
  Ok "  external -> $AgentsSkillsDir ($cnt)"
}
# symlinks
Log "  Symlinks (33 firecrawl*)"
$symCount = 0
Get-ChildItem $AgentsSkillsDir -Filter "firecrawl*" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
  $bn = $_.Name; $target = $_.FullName; $link = Join-Path $ConfigDir "skills\$bn"
  if(Test-Path $link){ Remove-Item $link -Recurse -Force -ErrorAction SilentlyContinue }
  $ok = $false
  try{
    New-Item -ItemType SymbolicLink -Path $link -Target $target -Force -ErrorAction Stop | Out-Null
    $ok = $true
  } catch {
    # fallback: junction or copy
    try{ New-Item -ItemType Junction -Path $link -Target $target -Force -ErrorAction Stop | Out-Null; $ok=$true } catch{
      try{ Copy-Item -Path $target -Destination $link -Recurse -Force; $ok=$true } catch{}
    }
  }
  if($ok){ $symCount++; if($Verbose){ Ok "  $bn" } }
}
Ok "  symlinks: $symCount (expected 33)"

# 9. Claude Code — settings/mcp/agents/skills/commands/hooks
Log "9/12 Claude Code ($ClaudeDir)"
$claudeSettingsSrc = Join-Path $RepoDir "claude\settings.json"
if(Test-Path $claudeSettingsSrc){
  # patch: ensure ANTHROPIC env stays template-friendly; copy verbatim (already sanitized to ${VAR})
  Copy-Item $claudeSettingsSrc (Join-Path $ClaudeDir "settings.json") -Force
  Ok "  settings.json"
}
$claudeMcpSrc = Join-Path $RepoDir "claude\mcp.json"
if(Test-Path $claudeMcpSrc){
  # patch Windows hardcoded C:/Users/PilzIndia -> HOME if any remaining
  $raw = Get-Content $claudeMcpSrc -Raw
  $patched = $raw -replace 'C:/Users/PilzIndia', $HomeDir.Replace('\','/') -replace 'C:\\\\Users\\\\PilzIndia', $HomeDir.Replace('\','\\')
  Set-Content -Path (Join-Path $ClaudeDir ".mcp.json") -Value $patched -Force
  Ok "  .mcp.json"
}
$claudeClaudeMd = Join-Path $RepoDir "claude\CLAUDE.md"
if(Test-Path $claudeClaudeMd){ Copy-Item $claudeClaudeMd (Join-Path $ClaudeDir "CLAUDE.md") -Force; Ok "  CLAUDE.md" }
# agents/skills/commands/hooks
foreach($sub in @('agents','skills','commands','hooks')){
  $src = Join-Path $RepoDir "claude\$sub"
  $dst = Join-Path $ClaudeDir $sub
  if(Test-Path $src){
    EnsureDir $dst
    if($Force -and $sub -in @('agents','skills')){ Remove-Item "$dst\*" -Recurse -Force -ErrorAction SilentlyContinue }
    Copy-Item -Path "$src\*" -Destination $dst -Recurse -Force -ErrorAction SilentlyContinue
    $cnt = (Get-ChildItem $dst -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
    Ok "  $sub -> $dst ($cnt files)"
  }
}
# plugins inventory — don't overwrite full plugins dir, just copy manifests
$claudePluginsSrc = Join-Path $RepoDir "claude\plugins"
if(Test-Path $claudePluginsSrc){
  EnsureDir (Join-Path $ClaudeDir "plugins")
  Get-ChildItem $claudePluginsSrc -File | ForEach-Object { Copy-Item $_.FullName (Join-Path $ClaudeDir "plugins\$($_.Name)") -Force -ErrorAction SilentlyContinue }
  Ok "  plugins inventories"
}
# Home-level .mcp.json (ruflo claude-flow)
$homeMcpSrc = Join-Path $RepoDir "claude\home-mcp.json.example"
if(Test-Path $homeMcpSrc){
  $dstHomeMcp = Join-Path $HomeDir ".mcp.json"
  if(-not (Test-Path $dstHomeMcp) -or $Force){ Copy-Item $homeMcpSrc $dstHomeMcp -Force; Ok "  ~/.mcp.json (claude-flow ruflo)" }
  else { Wrn "  ~/.mcp.json exists — skipping (use -Force to overwrite)" }
}

# 10. Codex
Log "10/12 Codex ($CodexDir)"
$codexSrc = Join-Path $RepoDir "codex\config.toml"
if(Test-Path $codexSrc){
  $raw = Get-Content $codexSrc -Raw
  $patched = $raw -replace 'C:/Users/PilzIndia', $HomeDir.Replace('\','/')
  Set-Content -Path (Join-Path $CodexDir "config.toml") -Value $patched -Force
  Ok "  config.toml"
}
# codex skills
$codexSkillsSrc = Join-Path $RepoDir "codex\skills"
if(Test-Path $codexSkillsSrc){
  EnsureDir (Join-Path $CodexDir "skills")
  Copy-Item -Path "$codexSkillsSrc\*" -Destination (Join-Path $CodexDir "skills") -Recurse -Force -ErrorAction SilentlyContinue
  Ok "  skills -> $CodexDir\skills"
}

# 11. OmniRoute
Log "11/12 OmniRoute ($OmniDir :20128)"
EnsureDir $OmniDir
$omniEnvSrc = Join-Path $RepoDir "omniroute\.env.example"
$omniEnvDst = Join-Path $OmniDir ".env"
if(-not (Test-Path $omniEnvDst) -and (Test-Path $omniEnvSrc)){
  Copy-Item $omniEnvSrc $omniEnvDst -Force
  Wrn "  Created $omniEnvDst from template — FILL STORAGE_ENCRYPTION_KEY / JWT_SECRET / API_KEY_SECRET / INITIAL_PASSWORD"
  Write-Host "   Generate: openssl rand -hex 32 ; openssl rand -base64 48" -ForegroundColor Yellow
} elseif(Test-Path $omniEnvDst){ Ok "  ~/.omniroute/.env exists" }
else { Wrn "  omniroute/.env.example missing in repo" }

# 12. FreeLLMAPI wiring
Log "12/12 FreeLLMAPI wiring (:31415) — runs npx freellmapi setup-* if freellmapi installed"
$freellmInPath = Get-Command freellmapi -ErrorAction SilentlyContinue
$hasNpxCache = Test-Path (Join-Path $env:LOCALAPPDATA "npm-cache\_npx\*\node_modules\freellmapi\package.json")
if($freellmInPath -or $hasNpxCache){
  foreach($target in @('claude','codex','opencode','qwen')){
    Log "  npx freellmapi setup-$target --url http://127.0.0.1:31415"
    try{ npx freellmapi "setup-$target" --url http://127.0.0.1:31415 2>&1 | Out-String | Write-Host } catch{ Wrn "  setup-$target failed (is freellmapi installed? npm i -g freellmapi@0.5.0)" }
  }
  Ok "  freellmapi wiring attempted"
} else {
  Wrn "  freellmapi not found — install first: npm i -g freellmapi@0.5.0"
  Wrn "  Then run manually:"
  Write-Host "   npx freellmapi setup-claude --url http://127.0.0.1:31415" -ForegroundColor Yellow
  Write-Host "   npx freellmapi setup-codex --url http://127.0.0.1:31415" -ForegroundColor Yellow
  Write-Host "   npx freellmapi setup-opencode --url http://127.0.0.1:31415" -ForegroundColor Yellow
}

# 13. Env file at repo
Log "13/13 Environment file"
$repoEnv = Join-Path $RepoDir ".env"
$exampleEnv = Join-Path $RepoDir ".env.example"
if(-not (Test-Path $repoEnv) -and (Test-Path $exampleEnv)){
  Copy-Item $exampleEnv $repoEnv -Force
  Ok "  Created $repoEnv — FILL GITHUB_TOKEN / FIRECRAWL_API_KEY / FREELLMAPI_API_KEY / ANTHROPIC_AUTH_TOKEN"
} else { Ok "  .env exists: $repoEnv" }

# Binaries notice
if(-not $SkipMcpBin){
  Write-Host ""
  Log "Local binaries (platform-specific)"
  foreach($bin in @('codebase-memory-mcp','graphify','officecli')){
    $c = Get-Command $bin -ErrorAction SilentlyContinue
    if($c){ Ok "  $bin : $($c.Source)" } else { Wrn "  $bin not found — MCP $bin will be disabled until installed. See tools/local-binaries/README.md" }
  }
  if(Select-String -Path (Join-Path $ConfigDir "opencode.json") -Pattern "PilzIndia" -Quiet -ErrorAction SilentlyContinue){
    Wrn "  opencode.json still has PilzIndia paths — run: node scripts\lib\patch-config.mjs --src $ConfigDir\opencode.json --home $HomeDir"
  }
}

Write-Host ""
Write-Host "┌──────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│  Install complete!  Next steps:              │" -ForegroundColor Green
Write-Host "└──────────────────────────────────────────────┘"
Write-Host "  1) Fill $repoEnv (notepad .env)"
Write-Host "     also: $OmniDir\.env for OmniRoute server secrets"
Write-Host "  2) Fill GITHUB_TOKEN / FIRECRAWL_API_KEY / FREELLMAPI_API_KEY / ANTHROPIC_AUTH_TOKEN / OMNIROUTE_API_KEY"
Write-Host "  3) Verify:  .\scripts\verify.ps1"
Write-Host "     opencode --version ; claude --version ; codex --version"
Write-Host "  4) Start gateways in separate terminals:"
Write-Host "     omniroute          # :20128 dashboard"
Write-Host "     npx freellmapi serve --port 31415  # :31415"
Write-Host "  5) Launch:"
Write-Host "     opencode ; claude ; codex"
Write-Host ""
Write-Host "  Docs: README.md docs/INVENTORY.md docs/INSTALL.md mcp/README.md"
Write-Host "  To update later: git pull ; .\scripts\install.ps1"

if(Test-Path (Join-Path $RepoDir "scripts\verify.ps1")){
  Write-Host ""
  Log "Running quick verify..."
  & (Join-Path $RepoDir "scripts\verify.ps1") -Quick 2>&1 | Out-String | Write-Host
}
