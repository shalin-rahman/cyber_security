# =============================================================================
# SEED Web Security Docker — System Diagnostic Tool (PowerShell)
# Usage: .\scripts\doctor.ps1
# =============================================================================

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "==========================================================" -ForegroundColor White
Write-Host "     Cyber Security Environment Doctor & System Check     " -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor White
Write-Host ""

$Errors = 0
$Warnings = 0

# 1. Check Docker CLI
Write-Host "Checking Docker CLI..." -NoNewline
if (Get-Command docker -ErrorAction SilentlyContinue) {
    $ver = (docker --version) -replace "Docker version ", ""
    Write-Host " [PASS] Installed ($ver)" -ForegroundColor Green
} else {
    Write-Host " [FAIL] Docker CLI not found." -ForegroundColor Red
    $Errors++
}

# 2. Check Docker Daemon
Write-Host "Checking Docker Daemon..." -NoNewline
try {
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " [PASS] Daemon active" -ForegroundColor Green
    } else {
        Write-Host " [FAIL] Daemon not responding. Open Docker Desktop." -ForegroundColor Red
        $Errors++
    }
} catch {
    Write-Host " [FAIL] Daemon not responding." -ForegroundColor Red
    $Errors++
}

# 3. Check Docker Compose
Write-Host "Checking Docker Compose..." -NoNewline
if (docker compose version 2>$null) {
    $composeVer = (docker compose version) -replace "Docker Compose version ", ""
    Write-Host " [PASS] Available ($composeVer)" -ForegroundColor Green
} else {
    Write-Host " [FAIL] Docker Compose not found." -ForegroundColor Red
    $Errors++
}

# 4. Check Port Availability (10080 - 10086)
Write-Host "Checking Lab Ports (10080-10086)..." -NoNewline
$ports = 10080..10086
$busyPorts = @()
foreach ($port in $ports) {
    $conn = New-Object System.Net.Sockets.TcpClient
    try {
        $conn.Connect("127.0.0.1", $port)
        $busyPorts += $port
        $conn.Close()
    } catch {
        # Port is free
    }
}
if ($busyPorts.Count -eq 0) {
    Write-Host " [PASS] All ports free" -ForegroundColor Green
} else {
    $busyStr = $busyPorts -join ', '
    Write-Host " [WARN] Busy ports: $busyStr" -ForegroundColor Yellow
    $Warnings++
}

# 5. Check Disk Space
Write-Host "Checking Free Disk Space..." -NoNewline
$drive = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeGB = [math]::Round($drive.FreeSpace / 1GB, 1)
if ($freeGB -ge 20) {
    Write-Host " [PASS] $freeGB GB available (20 GB recommended)" -ForegroundColor Green
} elseif ($freeGB -ge 10) {
    Write-Host " [WARN] $freeGB GB available (10 GB minimum)" -ForegroundColor Yellow
    $Warnings++
} else {
    Write-Host " [FAIL] Only $freeGB GB available. Free up disk space." -ForegroundColor Red
    $Errors++
}

# 6. Check System RAM
Write-Host "Checking Total Memory..." -NoNewline
$ram = Get-WmiObject Win32_ComputerSystem
$ramGB = [math]::Round($ram.TotalPhysicalMemory / 1GB, 1)
if ($ramGB -ge 15) {
    Write-Host " [INFO] $ramGB GB RAM (Recommended profile)" -ForegroundColor Cyan
} elseif ($ramGB -ge 7) {
    Write-Host " [INFO] $ramGB GB RAM (Minimum profile: run one lab at a time)" -ForegroundColor Yellow
} else {
    Write-Host " [WARN] $ramGB GB RAM detected. Performance may be constrained." -ForegroundColor Yellow
    $Warnings++
}

Write-Host ""
Write-Host "-- Doctor Summary -----------------------------------------" -ForegroundColor White
if ($Errors -eq 0 -and $Warnings -eq 0) {
    Write-Host "  [PASS] System environment is fully operational." -ForegroundColor Green
} elseif ($Errors -eq 0) {
    Write-Host "  [WARN] System ready with $Warnings warning(s). Review above." -ForegroundColor Yellow
} else {
    Write-Host "  [FAIL] Environment NOT ready. Resolve $Errors error(s) before starting." -ForegroundColor Red
}
Write-Host ""
