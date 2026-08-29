# ==============================================================================
# Lab 01 — SQL Injection Attack Lab: Reset Script (Windows PowerShell)
#
# Completely destroys all containers, networks, and database volumes,
# then rebuilds and restarts with original database data from sqllab_users.sql.
#
# WARNING: All injected changes to the database will be permanently lost.
# ==============================================================================

Write-Host "[Lab 01] SQL Injection Attack Lab — Reset" -ForegroundColor White
Write-Host "WARNING: This will destroy all database changes." -ForegroundColor Red
Write-Host ""
$confirm = Read-Host "Type 'yes' to proceed"

if ($confirm -ne "yes") {
    Write-Host "Reset cancelled. No changes made." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Stopping containers and removing database volumes..." -ForegroundColor Yellow

# '-v' removes named Docker volumes (MySQL data directory).
# MySQL will re-run sqllab_users.sql on next startup, restoring original data.
docker compose down -v

Write-Host "Rebuilding images and starting fresh containers..." -ForegroundColor Yellow

# '--build' forces image rebuild from Dockerfiles before starting.
docker compose up -d --build

Write-Host ""
Write-Host "Lab 01 reset complete. Original database has been restored." -ForegroundColor Green
Write-Host "Access: http://localhost:10080"
