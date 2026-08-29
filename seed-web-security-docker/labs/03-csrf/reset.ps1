# Lab 03 — CSRF Attack Lab: Reset Script (PowerShell)
Write-Host "[Lab 03] CSRF Attack Lab — Reset" -ForegroundColor White
Write-Host "WARNING: All database changes will be wiped." -ForegroundColor Red
$confirm = Read-Host "Type 'yes' to proceed"
if ($confirm -ne "yes") { Write-Host "Cancelled." -ForegroundColor Yellow; exit 0 }
docker compose down -v
docker compose up -d --build
Write-Host "Lab 03 reset complete." -ForegroundColor Green
Write-Host "  Target site:   http://localhost:10082"
Write-Host "  Attacker site: http://localhost:10083"
