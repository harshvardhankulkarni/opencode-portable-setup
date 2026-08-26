# verify.ps1 — health check for opencode + claude + codex + omniroute + freellmapi
param([switch]$Quick,[switch]$Verbose)
$pass=0;$fail=0;$warn=0
function Ok($m){ Write-Host " ✔ $m" -ForegroundColor Green; $script:pass++ }
function Bad($m){ Write-Host " ✘ $m" -ForegroundColor Red; $script:fail++ }
function Wrn($m){ Write-Host " ⚠ $m" -ForegroundColor Yellow; $script:warn++ }
function Info($m){ Write-Host " ℹ $m" -ForegroundColor Cyan }
Write-Host "────────────────────────────────────────"; Write-Host " Portable Setup — Verify (Windows)"
Write-Host "────────────────────────────────────────"
Write-Host "`n## Versions"
foreach($cmd in @('node','npm','bun','git','gh')){
  $c=Get-Command $cmd -ErrorAction SilentlyContinue
  if($c){ Ok "$cmd $((& $cmd --version 2>&1 | Select-Object -First 1))" } else { Bad "$cmd missing" }
}
foreach($cmd in @('opencode','claude','codex','omniroute','vercel','ruflo','openclaw','agent-browser','freellmapi')){
  $c=Get-Command $cmd -ErrorAction SilentlyContinue
  if($c){ try{ $v=(& $cmd --version 2>&1 | Select-Object -First 1); if(-not $v){$v=(& $cmd -v 2>&1 | Select-Object -First 1)} }catch{$v="ok"}; Ok "$cmd $v" }
  else {
    if($cmd -in @('opencode','claude')){ Bad "$cmd missing (npm i -g $cmd)" } else { Wrn "$cmd missing (optional)" }
  }
}
if(-not (Get-Command freellmapi -ErrorAction SilentlyContinue)){
  try{ $v=npx freellmapi --version 2>&1 | Select-Object -First 1; if($v){ Ok "freellmapi via npx $v"} else { Wrn "freellmapi not found — npx freellmapi@0.4.0 will be used"} }catch{ Wrn "freellmapi not found"}
}

Write-Host "`n## Opencode"
$oc="$env:USERPROFILE\.config\opencode"
foreach($f in @('opencode.json','cli.json','tui.json','AGENTS.md','package.json')){
  if(Test-Path "$oc\$f"){ Ok "opencode/$f" } else { Bad "opencode/$f missing" }
}
$cnt=(Get-ChildItem "$oc\agents" -File -ErrorAction SilentlyContinue | Measure-Object).Count; if($cnt -ge 200){ Ok "opencode agents: $cnt"} else { Bad "opencode agents low: $cnt (expected 236)"}
$cnt2=(Get-ChildItem "$oc\skills" -ErrorAction SilentlyContinue | Measure-Object).Count; if($cnt2 -ge 14){ Ok "opencode skills: $cnt2 entries"} else { Bad "opencode skills low: $cnt2"}
$cnt3=(Get-ChildItem "$env:USERPROFILE\.agents\skills" -ErrorAction SilentlyContinue | Measure-Object).Count; if($cnt3 -ge 80){ Ok "~/.agents/skills: $cnt3"} else { Wrn "~/.agents/skills low: $cnt3 (expected 91)"}
$sym=(Get-ChildItem "$oc\skills" -Attributes ReparsePoint -ErrorAction SilentlyContinue | Measure-Object).Count; if($sym -ge 20){ Ok "firecrawl symlinks: $sym"} else { Wrn "firecrawl symlinks: $sym (expected 33)"}
if(Select-String -Path "$oc\opencode.json" -Pattern "PilzIndia" -Quiet -ErrorAction SilentlyContinue){ Bad "opencode.json still has Windows PilzIndia paths"} else { Ok "opencode.json paths look ok"}

Write-Host "`n## Claude Code"
$cc="$env:USERPROFILE\.claude"
if(Test-Path "$cc\settings.json"){ Ok "claude/settings.json" } else { Bad "claude/settings.json missing"}
if(Test-Path "$cc\.mcp.json"){ Ok "claude/.mcp.json" } else { Wrn "claude/.mcp.json missing"}
$cnt=(Get-ChildItem "$cc\agents" -File -ErrorAction SilentlyContinue | Measure-Object).Count; if($cnt -ge 100){ Ok "claude agents: $cnt"} else { Wrn "claude agents low: $cnt (expected 274)"}
$cnt=(Get-ChildItem "$cc\skills" -Directory -ErrorAction SilentlyContinue | Measure-Object).Count; if($cnt -ge 100){ Ok "claude skills: $cnt dirs"} else { Wrn "claude skills low: $cnt"}
if(Test-Path "$cc\hooks"){ Ok "claude hooks"} else { Wrn "claude hooks missing"}
if(Test-Path "$cc\commands"){ Ok "claude commands"} else { Wrn "claude commands missing"}
if(Select-String -Path "$cc\settings.json" -Pattern "31415" -Quiet -ErrorAction SilentlyContinue){ Ok "claude ANTHROPIC_BASE_URL -> freellmapi :31415"} else { Wrn "claude not wired to freellmapi"}

Write-Host "`n## Codex"
$cx="$env:USERPROFILE\.codex"
if(Test-Path "$cx\config.toml"){ Ok "codex/config.toml"} else { Wrn "codex/config.toml missing"}
if(Select-String -Path "$cx\config.toml" -Pattern "freellmapi" -Quiet -ErrorAction SilentlyContinue){ Ok "codex wired to freellmapi"} else { Wrn "codex not wired to freellmapi"}

Write-Host "`n## OmniRoute (port 20128)"
if(Test-Path "$env:USERPROFILE\.omniroute\.env"){ Ok "~/.omniroute/.env exists"} else { Wrn "~/.omniroute/.env missing — copy from omniroute/.env.example"}
if(Get-Command omniroute -ErrorAction SilentlyContinue){ Ok "omniroute binary"} else { Wrn "omniroute not in PATH — npm i -g omniroute@3.8.49"}
try{ $r=Invoke-WebRequest -Uri http://127.0.0.1:20128/v1/models -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop; Ok "omniroute :20128 reachable"}catch{ try{ Invoke-WebRequest -Uri http://localhost:20128/v1/models -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop | Out-Null; Ok "omniroute :20128 reachable"}catch{ Wrn "omniroute :20128 not reachable (run 'omniroute' or 'omniroute start')"} }

Write-Host "`n## FreeLLMAPI (port 31415)"
try{ Invoke-WebRequest -Uri http://127.0.0.1:31415/v1/models -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop | Out-Null; Ok "freellmapi :31415 reachable"}catch{ Wrn "freellmapi :31415 not reachable — npx freellmapi serve  (check FREELLMAPI_API_KEY)"}

Write-Host "`n## Environment (.env)"
$envFile="$PSScriptRoot\..\.env"; if(-not (Test-Path $envFile)){ $envFile="$env:USERPROFILE\opencode-portable-setup\.env"}
if(Test-Path ".env" -or Test-Path $envFile){ Ok ".env present"} else { Wrn ".env missing — copy from .env.example"}
foreach($var in @('GITHUB_TOKEN','FIRECRAWL_API_KEY','FREELLMAPI_API_KEY','ANTHROPIC_AUTH_TOKEN','OMNIROUTE_API_KEY')){
  $val=[Environment]::GetEnvironmentVariable($var)
  if($val){ Ok "env $var set"} else { if($var -in @('GITHUB_TOKEN','FIRECRAWL_API_KEY')){ Wrn "$var not set (MCP github/firecrawl will fail)"} else { Info "$var not set (optional)"} }
}

Write-Host "`n────────────────────────────────────────"; Write-Host " Summary: $pass passed, $warn warnings, $fail failed"; Write-Host "────────────────────────────────────────"
if($fail -gt 0){ Write-Host "Status: NEEDS WORK" -ForegroundColor Red; exit 1 } elseif($warn -gt 5){ Write-Host "Status: WARNINGS — mostly usable" -ForegroundColor Yellow; exit 0 } else { Write-Host "Status: HEALTHY" -ForegroundColor Green; exit 0 }
