# ==============================================================================
# Lab 01 — SQL Injection Attack Lab: Stop Script (Windows PowerShell)
#
# Stops containers but PRESERVES database volumes (your changes persist).
# Use reset.ps1 to completely wipe all data.
# ==============================================================================

Write-Host "[Lab 01] SQL Injection Attack Lab — Stopping containers..." -ForegroundColor Yellow

# Stops containers and removes the Docker network.
# Named volumes (database data) are NOT removed.
docker compose down

Write-Host "Lab 01 stopped. Database data is preserved." -ForegroundColor Green
Write-Host "Run .\start.ps1 to resume, or .\reset.ps1 to wipe and start fresh."
