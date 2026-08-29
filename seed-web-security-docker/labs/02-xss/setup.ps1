# ==============================================================================
# Lab 02 — XSS Attack Lab: Setup Script (Windows PowerShell)
#
# Adds hostname entries and builds Docker images for the XSS lab.
# Run as Administrator to write to the hosts file.
# ==============================================================================

Write-Host "[Lab 02] XSS Attack Lab — Setup" -ForegroundColor White
Write-Host "---------------------------------------"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker not found." -ForegroundColor Red; exit 1
}
try { docker info | Out-Null } catch {
    Write-Host "ERROR: Docker daemon not running. Open Docker Desktop." -ForegroundColor Red; exit 1
}
Write-Host "Docker is running." -ForegroundColor Green
Write-Host ""

$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$entry = "10.9.0.5   www.seed-server.com"

if (Select-String -Path $hostsFile -Pattern "www.seed-server.com" -Quiet 2>$null) {
    Write-Host "hosts already contains 'www.seed-server.com' — skipped." -ForegroundColor Green
} else {
    try {
        Add-Content -Path $hostsFile -Value $entry
        Write-Host "Added: $entry" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Run as Administrator to modify hosts file." -ForegroundColor Red
        Write-Host "Manually add to ${hostsFile}: $entry" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Building lab container images..." -ForegroundColor Yellow
docker compose build --no-cache

Write-Host ""
Write-Host "Setup complete. Run .\start.ps1 to launch the lab." -ForegroundColor Green
