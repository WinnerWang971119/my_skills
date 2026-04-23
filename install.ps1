# Installs skills into ~/.claude/skills/ and ~/.codex/skills/
# Usage: iwr -useb https://raw.githubusercontent.com/<YOUR_USER>/<YOUR_REPO>/main/install.ps1 | iex
# Override via env: $env:REPO="user/repo"; $env:BRANCH="main"; iwr ... | iex

$ErrorActionPreference = 'Stop'
$ProgressPreference   = 'SilentlyContinue'  # speeds up Invoke-WebRequest dramatically
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Repo   = if ($env:REPO)   { $env:REPO }   else { '<YOUR_USER>/<YOUR_REPO>' }
$Branch = if ($env:BRANCH) { $env:BRANCH } else { 'main' }

$ClaudeDir = Join-Path $HOME '.claude\skills'
$CodexDir  = Join-Path $HOME '.codex\skills'

Write-Host "==> Installing skills from $Repo@$Branch"
Write-Host "    Claude Code -> $ClaudeDir"
Write-Host "    Codex       -> $CodexDir"

New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
New-Item -ItemType Directory -Force -Path $CodexDir  | Out-Null

$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("skills-" + [guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $Tmp | Out-Null

try {
  $ZipUrl  = "https://codeload.github.com/$Repo/zip/refs/heads/$Branch"
  $ZipPath = Join-Path $Tmp 'repo.zip'

  Write-Host '==> Downloading zip...'
  Invoke-WebRequest -UseBasicParsing -Uri $ZipUrl -OutFile $ZipPath
  Expand-Archive -Path $ZipPath -DestinationPath $Tmp -Force

  $RepoName    = ($Repo -split '/')[-1]
  $ExpectedDir = Join-Path $Tmp "$RepoName-$($Branch -replace '/', '-')"
  if (Test-Path $ExpectedDir) {
    $Src = Get-Item $ExpectedDir
  } else {
    $Src = Get-ChildItem -Path $Tmp -Directory | Sort-Object Name | Select-Object -First 1
  }
  if (-not $Src) { throw 'Could not find extracted repo root.' }

  $skip = @('node_modules')
  $count = 0
  Get-ChildItem -Path $Src.FullName -Directory | ForEach-Object {
    if ($_.Name.StartsWith('.')) { return }
    if ($skip -contains $_.Name) { return }
    if (-not (Test-Path (Join-Path $_.FullName 'SKILL.md'))) { return }

    Write-Host "  - $($_.Name)"
    $claudeTarget = Join-Path $ClaudeDir $_.Name
    $codexTarget  = Join-Path $CodexDir  $_.Name
    if (Test-Path $claudeTarget) { Remove-Item -Recurse -Force $claudeTarget }
    if (Test-Path $codexTarget)  { Remove-Item -Recurse -Force $codexTarget }
    Copy-Item -Recurse -Path $_.FullName -Destination $claudeTarget
    Copy-Item -Recurse -Path $_.FullName -Destination $codexTarget
    $count++
  }

  Write-Host "==> Installed $count skill(s)."
}
finally {
  Remove-Item -Recurse -Force $Tmp -ErrorAction SilentlyContinue
}
