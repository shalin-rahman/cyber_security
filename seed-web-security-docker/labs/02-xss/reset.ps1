# Lab 02 — XSS Attack Lab: Reset Script (Windows PowerShell)
Write-Host "[Lab 02] XSS Attack Lab — Reset" -ForegroundColor White
Write-Host "WARNING: All injected profile data will be wiped." -ForegroundColor Red
$confirm = Read-Host "Type 'yes' to proceed"
if ($confirm -ne "yes") { Write-Host "Cancelled." -ForegroundColor Yellow; exit 0 }
docker compose down -v
docker compose up -d --build
Write-Host "Lab 02 reset complete. Access: http://localhost:10081" -ForegroundColor Green
