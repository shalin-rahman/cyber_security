# ==============================================================================
# Lab 01 — SQL Injection Attack Lab: Setup Script (Windows PowerShell)
#
# What this script does:
#   1. Checks that Docker Desktop is installed and the daemon is running.
#   2. Adds a hostname entry to C:\Windows\System32\drivers\etc\hosts so
#      that 'www.seed-server.com' resolves to 10.9.0.5 (the web container).
#   3. Builds Docker images locally from image_www/ and image_mysql/.
#
# Usage (run PowerShell as Administrator):
#   .\setup.ps1
# ==============================================================================

Write-Host "[Lab 01] SQL Injection Attack Lab — Setup" -ForegroundColor White
Write-Host "----------------------------------------------"

# Step 1: Check Docker is installed and running
# Docker Desktop must be open before running this script.
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker not found. Install Docker Desktop from https://docker.com" -ForegroundColor Red
    exit 1
}

try {
    docker info | Out-Null
} catch {
    Write-Host "ERROR: Docker daemon is not running. Open Docker Desktop first." -ForegroundColor Red
    exit 1
}

Write-Host "Docker is running." -ForegroundColor Green
Write-Host ""

# Step 2: Add hostname entry to Windows hosts file
#
# Windows uses C:\Windows\System32\drivers\etc\hosts for local DNS overrides.
# This maps 'www.seed-server.com' -> 10.9.0.5 (the container's static IP).
# Requires running PowerShell as Administrator.
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$entry     = "10.9.0.5   www.seed-server.com"

if (Select-String -Path $hostsFile -Pattern "www.seed-server.com" -Quiet 2>$null) {
    Write-Host "hosts file already contains 'www.seed-server.com' — no change needed." -ForegroundColor Green
} else {
    try {
        Add-Content -Path $hostsFile -Value $entry
        Write-Host "Added to hosts file: $entry" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Could not write hosts file. Run PowerShell as Administrator." -ForegroundColor Red
        Write-Host "Manually add this line to $hostsFile :" -ForegroundColor Yellow
        Write-Host "  $entry" -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 3: Build Docker images from local Dockerfiles
#
# 'docker compose build' reads docker-compose.yml and builds:
#   image_www/Dockerfile   -> Apache + PHP + vulnerable app source code
#   image_mysql/Dockerfile -> MySQL 8.0 + pre-loaded sqllab_users database
Write-Host "Building lab container images from local Dockerfiles..." -ForegroundColor Yellow
Write-Host "(First build may take several minutes — downloading base images)"
docker compose build --no-cache

Write-Host ""
Write-Host "Setup complete." -ForegroundColor Green
Write-Host "  Run:   .\start.ps1    to start the lab"
Write-Host "  Run:   .\stop.ps1     to stop the lab"
Write-Host "  Run:   .\reset.ps1    to wipe data and restart from scratch"
