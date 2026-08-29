# ==============================================================================
# Lab 03 — CSRF Attack Lab: Setup Script (Windows PowerShell)
#
# Adds two hostname entries (target site + attacker site) and builds images.
# Run as Administrator to write to the hosts file.
# ==============================================================================

Write-Host "[Lab 03] CSRF Attack Lab — Setup" -ForegroundColor White
Write-Host "---------------------------------------"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker not found." -ForegroundColor Red; exit 1
}
try { docker info | Out-Null } catch {
    Write-Host "ERROR: Docker not running. Open Docker Desktop." -ForegroundColor Red; exit 1
}
Write-Host "Docker is running." -ForegroundColor Green; Write-Host ""

$hostsFile = "C:\Windows\System32\drivers\etc\hosts"

# Two hostnames are required for the cross-origin CSRF scenario:
#   www.seed-server.com -> the legitimate trusted Elgg social network
#   www.attacker32.com  -> the malicious site Alice visits that triggers CSRF
$entries = @(
    "10.9.0.5     www.seed-server.com",
    "10.9.0.105   www.attacker32.com"
)

foreach ($entry in $entries) {
    $host = ($entry -split '\s+')[1]
    if (Select-String -Path $hostsFile -Pattern $host -Quiet 2>$null) {
        Write-Host "hosts already contains '$host' — skipped." -ForegroundColor Green
    } else {
        try {
            Add-Content -Path $hostsFile -Value $entry
            Write-Host "Added: $entry" -ForegroundColor Green
        } catch {
            Write-Host "ERROR: Run as Administrator. Manually add to ${hostsFile}: $entry" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "Building lab container images..." -ForegroundColor Yellow
docker compose build --no-cache
Write-Host ""
Write-Host "Setup complete. Run .\start.ps1 to launch the lab." -ForegroundColor Green
