# Lab 04 — Clickjacking Attack Lab: Reset Script (PowerShell)
Write-Host "[Lab 04] Clickjacking Attack Lab — Reset" -ForegroundColor White
$confirm = Read-Host "Type 'yes' to proceed"
if ($confirm -ne "yes") { Write-Host "Cancelled." -ForegroundColor Yellow; exit 0 }
docker compose down -v
docker compose up -d --build
Write-Host "Lab 04 reset complete." -ForegroundColor Green
Write-Host "  Target:   http://localhost:10084"
Write-Host "  Attacker: http://localhost:10085"
