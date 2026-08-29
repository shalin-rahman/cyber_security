# =============================================================================
# SEED Web Security Docker — Environment Validation Script (PowerShell)
# Usage: .\scripts\check-environment.ps1
# Requires: PowerShell 5.1+ or PowerShell 7+
# =============================================================================

$ErrorActionPreference = "Continue"

$PASS    = "[PASS]   "
$WARN    = "[WARNING]"
$FAIL    = "[ERROR]  "
$Errors  = 0
$Warnings = 0

function Write-Pass  { param($msg) Write-Host "$PASS $msg" -ForegroundColor Green  }
function Write-Warn  { param($msg) Write-Host "$WARN $msg" -ForegroundColor Yellow; $script:Warnings++ }
function Write-Fail  { param($msg) Write-Host "$FAIL $msg" -ForegroundColor Red;    $script:Errors++   }
function Write-Section { param($title) Write-Host "`n-- $title ----------------------------------------" -ForegroundColor Cyan }

Write-Host ""
Write-Host "==========================================================" -ForegroundColor White
Write-Host "     SEED Web Security Docker -- Environment Check        " -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor White
Write-Host ""

# ── 1. Operating System ───────────────────────────────────────────────────────
Write-Section "Operating System"
$osInfo = [System.Environment]::OSVersion
$osVer  = $osInfo.VersionString
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    $winCaption = (Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption
    Write-Pass "Operating system: $winCaption"
    Write-Host "         Docker Desktop with WSL2 backend is required on Windows." -ForegroundColor Gray
} elseif ($IsLinux) {
    Write-Pass "Operating system: Linux"
} elseif ($IsMacOS) {
    Write-Pass "Operating system: macOS"
} else {
    Write-Warn "Operating system: $osVer (compatibility unknown)"
}

# ── 2. Docker Installation ────────────────────────────────────────────────────
Write-Section "Docker"
$dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
if ($dockerCmd) {
    $dockerVer = (docker --version 2>&1)
    Write-Pass "Docker installed: $dockerVer"
} else {
    Write-Fail "Docker is not installed."
    Write-Host "         Install from: https://docs.docker.com/desktop/install/windows-install/" -ForegroundColor Gray
}

# ── 3. Docker Daemon ──────────────────────────────────────────────────────────
if ($dockerCmd) {
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Pass "Docker daemon is running"
    } else {
        Write-Fail "Docker daemon is NOT running. Start Docker Desktop."
    }
}

# ── 4. Docker Compose ─────────────────────────────────────────────────────────
Write-Section "Docker Compose"
$composeV2 = docker compose version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Pass "Docker Compose (plugin): $composeV2"
} else {
    $composeLegacy = Get-Command docker-compose -ErrorAction SilentlyContinue
    if ($composeLegacy) {
        $legacyVer = (docker-compose --version 2>&1)
        Write-Warn "Legacy docker-compose found: $legacyVer. Recommend upgrading to Compose v2."
    } else {
        Write-Fail "Docker Compose is not available. Install Docker Desktop (includes Compose v2)."
    }
}

# ── 5. RAM ────────────────────────────────────────────────────────────────────
Write-Section "System Resources"
$MIN_RAM_GB = 8
$REC_RAM_GB = 16

try {
    $ramKB  = (Get-WmiObject Win32_ComputerSystem -ErrorAction Stop).TotalPhysicalMemory
    $ramGB  = [math]::Round($ramKB / 1GB, 1)
} catch {
    $ramGB = 0
}

if ($ramGB -ge $REC_RAM_GB) {
    Write-Pass "RAM: ${ramGB} GB (recommended: ${REC_RAM_GB} GB)"
} elseif ($ramGB -ge $MIN_RAM_GB) {
    Write-Warn "RAM: ${ramGB} GB — minimum met; recommended ${REC_RAM_GB} GB for full lab set"
} else {
    Write-Fail "RAM: ${ramGB} GB — minimum ${MIN_RAM_GB} GB required."
}

# ── 6. Disk Space ─────────────────────────────────────────────────────────────
$MIN_DISK_GB = 20
$REC_DISK_GB = 40

try {
    $drive = Split-Path -Qualifier (Get-Location).Path
    $disk  = Get-PSDrive ($drive -replace ':','') -ErrorAction Stop
    $diskGB = [math]::Round($disk.Free / 1GB, 1)
} catch {
    $diskGB = 0
}

if ($diskGB -ge $REC_DISK_GB) {
    Write-Pass "Free disk: ${diskGB} GB (recommended: ${REC_DISK_GB} GB)"
} elseif ($diskGB -ge $MIN_DISK_GB) {
    Write-Warn "Free disk: ${diskGB} GB — minimum met; recommended ${REC_DISK_GB} GB"
} else {
    Write-Fail "Free disk: ${diskGB} GB — minimum ${MIN_DISK_GB} GB required."
}

# ── 7. CPU Cores ──────────────────────────────────────────────────────────────
$MIN_CPU = 4
try {
    $cpuCount = (Get-WmiObject Win32_ComputerSystem -ErrorAction Stop).NumberOfLogicalProcessors
} catch {
    $cpuCount = 0
}

if ($cpuCount -ge $MIN_CPU) {
    Write-Pass "CPU logical cores: $cpuCount (minimum: $MIN_CPU)"
} else {
    Write-Warn "CPU logical cores: $cpuCount — minimum $MIN_CPU recommended"
}

# ── 8. Docker Desktop Memory Allocation ───────────────────────────────────────
$wslConfigPath = "$env:USERPROFILE\.wslconfig"
if (Test-Path $wslConfigPath) {
    $wslConfig = Get-Content $wslConfigPath -Raw
    Write-Pass ".wslconfig found — custom WSL2 memory allocation detected"
    Write-Host "         Review: $wslConfigPath" -ForegroundColor Gray
} else {
    Write-Warn ".wslconfig not found. Consider creating it to allocate more RAM to WSL2/Docker."
    Write-Host "         Example: docs/01-prerequisites.md" -ForegroundColor Gray
}

# ── 9. Internet Connectivity ──────────────────────────────────────────────────
Write-Section "Internet Connectivity"
try {
    $response = Invoke-WebRequest -Uri "https://hub.docker.com" -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
    Write-Pass "Docker Hub reachable (https://hub.docker.com)"
} catch {
    try {
        $response = Invoke-WebRequest -Uri "https://www.google.com" -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        Write-Warn "Internet available but Docker Hub may be restricted"
    } catch {
        Write-Fail "No internet connectivity — required for pulling Docker images"
    }
}

# ── 10. Required Tools ────────────────────────────────────────────────────────
Write-Section "Optional Tools"
foreach ($tool in @("curl", "git", "wsl")) {
    $cmd = Get-Command $tool -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Pass "${tool}: $($cmd.Source)"
    } else {
        Write-Host "$WARN $tool not found (optional)" -ForegroundColor Yellow
        $script:Warnings++
    }
}

# ── WSL2 Check ────────────────────────────────────────────────────────────────
Write-Section "WSL2 (Windows Only)"
$wslCmd = Get-Command wsl -ErrorAction SilentlyContinue
if ($wslCmd) {
    $wslVersion = (wsl --status 2>&1 | Select-String "Default Version" | ForEach-Object { $_.ToString().Trim() })
    if ($wslVersion -match "2") {
        Write-Pass "WSL2 is the default version"
    } else {
        Write-Warn "WSL may not be running in version 2 mode."
        Write-Host "         Run: wsl --set-default-version 2" -ForegroundColor Gray
    }
} else {
    Write-Warn "WSL not found. Docker Desktop on Windows requires WSL2."
    Write-Host "         Run in elevated PowerShell: wsl --install" -ForegroundColor Gray
}

# -- Summary -------------------------------------------------------------------
Write-Host "`n-- Summary --------------------------------------------------" -ForegroundColor Cyan
if ($Errors -eq 0 -and $Warnings -eq 0) {
    Write-Host "[PASS] Environment is ready. All checks passed." -ForegroundColor Green
} elseif ($Errors -eq 0) {
    Write-Host "[WARN] Environment ready with $Warnings warning(s). Review above." -ForegroundColor Yellow
} else {
    Write-Host "[FAIL] Environment NOT ready. $Errors error(s) must be fixed." -ForegroundColor Red
    Write-Host "    See docs\01-prerequisites.md for installation instructions." -ForegroundColor Gray
}
Write-Host ""
