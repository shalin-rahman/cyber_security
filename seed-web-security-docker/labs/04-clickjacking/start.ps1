# Lab 04 — Clickjacking Attack Lab: Start Script (Windows PowerShell)
Write-Host "[Lab 04] Clickjacking Attack Lab — Starting Containers" -ForegroundColor White
docker compose up -d
Write-Host ""
docker compose ps
Write-Host ""
Write-Host "Lab 04 is running." -ForegroundColor Green
Write-Host "  Target site:   http://www.cjlab.com          OR  http://localhost:10084"
Write-Host "  Attacker site: http://www.cjlab-attacker.com OR  http://localhost:10085"
