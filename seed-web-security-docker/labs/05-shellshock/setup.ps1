# ==============================================================================
# Lab 05 — Shellshock Vulnerability Lab: Setup Script (Windows PowerShell)
# ==============================================================================

Write-Host "[Lab 05] Shellshock Vulnerability Lab — Setup" -ForegroundColor White
Write-Host "----------------------------------------------"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker not found." -ForegroundColor Red; exit 1
}
try { docker info | Out-Null } catch {
    Write-Host "ERROR: Docker not running. Open Docker Desktop." -ForegroundColor Red; exit 1
}
Write-Host "Docker is running." -ForegroundColor Green; Write-Host ""

# No hosts file modification needed for Lab 05
Write-Host "No hostname configuration required for this lab." -ForegroundColor Yellow
Write-Host "The server will be accessible at http://localhost:10086"
Write-Host ""

Write-Host "Building lab container image..." -ForegroundColor Yellow
docker compose build --no-cache
Write-Host ""
Write-Host "Setup complete. Run .\start.ps1 to launch the lab." -ForegroundColor Green
