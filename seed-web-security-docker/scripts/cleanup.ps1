# =============================================================================
# SEED Web Security Docker — Cleanup Script (PowerShell)
# Usage: .\scripts\cleanup.ps1 [-All]
# =============================================================================

param([switch]$All)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor White
Write-Host "║         SEED Web Security Docker — Cleanup               ║" -ForegroundColor White
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor White
Write-Host ""

$ScriptDir = $PSScriptRoot
$LabsDir   = Join-Path $ScriptDir "..\labs"
$Labs      = @("01-sql-injection","02-xss","03-csrf","04-clickjacking","05-shellshock")

# ── Step 1: Stop all lab containers ──────────────────────────────────────────
Write-Host "Step 1: Stopping all lab containers..." -ForegroundColor Yellow
foreach ($lab in $Labs) {
    $composeFile = Join-Path $LabsDir "$lab\docker-compose.yml"
    if (Test-Path $composeFile) {
        Write-Host "  Stopping $lab..." -ForegroundColor Gray
        Push-Location (Join-Path $LabsDir $lab)
        docker compose down 2>&1 | Out-Null
        Write-Host "  ✓ $lab stopped" -ForegroundColor Green
        Pop-Location
    }
}
Write-Host ""

# ── Step 2: Remove SEED networks ─────────────────────────────────────────────
Write-Host "Step 2: Removing SEED lab networks..." -ForegroundColor Yellow
$seedNetworks = docker network ls --filter "name=net-10.9.0.0" -q 2>&1
if ($seedNetworks) {
    $seedNetworks | ForEach-Object { docker network rm $_ 2>&1 | Out-Null }
    Write-Host "  ✓ SEED networks removed" -ForegroundColor Green
} else {
    Write-Host "  No SEED networks found" -ForegroundColor Gray
}
Write-Host ""

# ── Step 3 (optional): Remove images ─────────────────────────────────────────
if ($All) {
    Write-Host "Step 3: Removing SEED Docker images..." -ForegroundColor Red
    Write-Host "  WARNING: This will require re-downloading images (~5-10 GB) next time." -ForegroundColor Red
    $confirm = Read-Host "  Continue? [y/N]"
    if ($confirm -ieq "y") {
        $seedImages = docker image ls --filter "reference=handsonsecurity/*" -q 2>&1
        if ($seedImages) {
            $seedImages | ForEach-Object { docker image rm $_ 2>&1 | Out-Null }
            Write-Host "  ✓ SEED images removed" -ForegroundColor Green
        } else {
            Write-Host "  No SEED images found" -ForegroundColor Gray
        }
        Write-Host "  Removing build cache..." -ForegroundColor Yellow
        docker builder prune -f 2>&1 | Out-Null
        Write-Host "  ✓ Build cache cleared" -ForegroundColor Green
    } else {
        Write-Host "  Skipped image removal." -ForegroundColor Gray
    }
    Write-Host ""
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host "── Cleanup complete ─────────────────────────────────────────" -ForegroundColor White
Write-Host "  Current Docker disk usage:" -ForegroundColor Gray
docker system df 2>&1
Write-Host ""
Write-Host "  To remove images as well: .\scripts\cleanup.ps1 -All" -ForegroundColor Yellow
Write-Host "  To start a fresh lab:     cd labs\<lab>; docker compose up -d" -ForegroundColor Green
Write-Host ""
