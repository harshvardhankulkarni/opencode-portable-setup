# bootstrap.ps1 — irm|iex one-liner for Windows
# Usage: irm https://raw.githubusercontent.com/harshvardhankulkarni/opencode-portable-setup/main/scripts/bootstrap.ps1 | iex
param([string]$RepoUrl = "undefined", [string]$Dest = "$env:USERPROFILE\opencode-portable-setup")
Write-Host "[bootstrap] cloning $RepoUrl -> $Dest"
if(Test-Path "$Dest\.git"){ git -C $Dest pull --ff-only; if($LASTEXITCODE -ne 0){ git -C $Dest pull } } else { git clone $RepoUrl $Dest }
Set-Location $Dest
& "$Dest\scripts\install.ps1" @args
