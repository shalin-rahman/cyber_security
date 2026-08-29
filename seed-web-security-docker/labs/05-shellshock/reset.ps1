# Lab 05 — Shellshock Vulnerability Lab: Reset Script (PowerShell)
Write-Host "[Lab 05] Shellshock Vulnerability Lab — Reset" -ForegroundColor White
$confirm = Read-Host "Rebuild container from scratch? Type 'yes' to proceed"
if ($confirm -ne "yes") { Write-Host "Cancelled." -ForegroundColor Yellow; exit 0 }
docker compose down -v
docker compose up -d --build
Write-Host "Lab 05 reset complete." -ForegroundColor Green
Write-Host "Access: http://localhost:10086/cgi-bin/vul.cgi"
