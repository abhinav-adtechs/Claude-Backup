#Requires -Version 5.1
<#
.SYNOPSIS
    Install Claude-Backup on Windows.

.PARAMETER VaultPath
    Path to the backup vault. Defaults to $HOME\Documents\ClaudeVault

.PARAMETER Uninstall
    Remove the installed files (does not delete your vault data).

.PARAMETER Check
    Verify whether Claude-Backup is installed.

.EXAMPLE
    .\install.ps1
    .\install.ps1 -VaultPath "C:\Users\you\Dropbox\ClaudeVault"
    .\install.ps1 -Check
    .\install.ps1 -Uninstall
#>

param(
    [string]$VaultPath = "",
    [switch]$Uninstall,
    [switch]$Check
)

# Stop on the first error (e.g. a missing source file) instead of
# carrying on and writing empty skill files (see issue #3).
$ErrorActionPreference = 'Stop'

# Resolve source paths relative to this script, not the current
# directory, so the installer works from any directory.
$ResumeSkillSource    = Join-Path (Join-Path $PSScriptRoot "skill") "SKILL.md"
$ScheduledSkillSource = Join-Path (Join-Path $PSScriptRoot "scheduled-task") "SKILL.md"
$GitignoreTemplate    = Join-Path $PSScriptRoot "vault-gitignore.template"

$ClaudeDir    = Join-Path $env:USERPROFILE ".claude"
$SkillDir     = Join-Path $ClaudeDir "vault-resume"
$ScheduledDir = Join-Path $env:USERPROFILE "Documents\Claude\Scheduled\session-backup"
$DefaultVault = Join-Path $env:USERPROFILE "Documents\ClaudeVault"

if ($VaultPath -eq "") {
    $VaultPath = $DefaultVault
}

# --Check: verify existing installation
if ($Check) {
    Write-Host "Checking Claude-Backup installation..."
    $skillFile     = Join-Path $SkillDir "SKILL.md"
    $scheduledFile = Join-Path $ScheduledDir "SKILL.md"

    if (Test-Path $skillFile) {
        Write-Host "  Resume skill:     installed ($skillFile)"
    } else {
        Write-Host "  Resume skill:     NOT FOUND ($skillFile)"
    }
    if (Test-Path $scheduledFile) {
        Write-Host "  Scheduled backup: installed ($scheduledFile)"
    } else {
        Write-Host "  Scheduled backup: NOT FOUND ($scheduledFile)"
    }
    exit 0
}

# --Uninstall: remove installed files
if ($Uninstall) {
    Write-Host "Uninstalling Claude-Backup..."
    if (Test-Path $SkillDir)     { Remove-Item -Recurse -Force $SkillDir;     Write-Host "  Removed: $SkillDir" }
    if (Test-Path $ScheduledDir) { Remove-Item -Recurse -Force $ScheduledDir; Write-Host "  Removed: $ScheduledDir" }
    Write-Host "Done. Your vault data at the backup destination was NOT removed."
    exit 0
}

Write-Host "Installing Claude-Backup..."
Write-Host "  Vault location: $VaultPath"
Write-Host ""

# Warn if reinstalling
$existingSkill = Join-Path $SkillDir "SKILL.md"
if (Test-Path $existingSkill) {
    Write-Host "  Existing installation found - updating..."
}

# Helper: substitute vault path placeholder and write file
function Install-SkillFile {
    param([string]$SourcePath, [string]$DestPath)
    $destDir = Split-Path $DestPath -Parent
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    $content = Get-Content $SourcePath -Raw -Encoding UTF8
    # Normalise to forward slashes for cross-platform consistency inside the skill
    $vaultFwd = $VaultPath -replace '\\', '/'
    $content = $content -replace [regex]::Escape("~/Documents/ClaudeVault/"), "$vaultFwd/"
    Set-Content -Path $DestPath -Value $content -Encoding UTF8 -NoNewline
}

# Fail fast if a skill source is missing, before creating any folders
# or writing (possibly empty) skill files.
foreach ($src in @($ResumeSkillSource, $ScheduledSkillSource)) {
    if (-not (Test-Path $src)) {
        Write-Error "Missing source file: $src"
        exit 1
    }
}

# Install the resume skill
Install-SkillFile -SourcePath $ResumeSkillSource -DestPath (Join-Path $SkillDir "SKILL.md")
Write-Host "  Resume skill installed to: $SkillDir"

# Install the scheduled backup task
Install-SkillFile -SourcePath $ScheduledSkillSource -DestPath (Join-Path $ScheduledDir "SKILL.md")
Write-Host "  Scheduled task installed to: $ScheduledDir"

# Install .gitignore template to vault directory (only on first install)
$vaultGitignore = Join-Path $VaultPath ".gitignore"
if (-not (Test-Path $vaultGitignore)) {
    if (-not (Test-Path $GitignoreTemplate)) {
        Write-Error "Missing source file: $GitignoreTemplate"
        exit 1
    }
    New-Item -ItemType Directory -Force -Path $VaultPath | Out-Null
    Copy-Item $GitignoreTemplate $vaultGitignore
    Write-Host "  Security: .gitignore installed to $VaultPath"
}

# Verify both files were written
$skillFile     = Join-Path $SkillDir "SKILL.md"
$scheduledFile = Join-Path $ScheduledDir "SKILL.md"

if (-not (Test-Path $skillFile)) {
    Write-Error "Resume skill install failed - $skillFile not found"
    exit 1
}
if (-not (Test-Path $scheduledFile)) {
    Write-Error "Scheduled task install failed - $scheduledFile not found"
    exit 1
}

Write-Host ""
Write-Host "Done! Next steps:"
Write-Host "  1. Open Claude Desktop (Cowork mode)"
Write-Host "  2. Go to Scheduled tasks in the sidebar"
Write-Host "  3. Click 'Run now' on 'session-backup' to do your first backup"
Write-Host "  4. The backup will run automatically every 6 hours after that"
Write-Host ""
Write-Host "To resume any project, say 'pick up where I left off' in any new session."
Write-Host ""
Write-Host "Other commands:"
Write-Host "  .\install.ps1 -Check              Verify installation"
Write-Host "  .\install.ps1 -Uninstall          Remove installed files"
Write-Host "  .\install.ps1 -VaultPath C:\path  Install with custom vault location"
