# ==============================================================================
# Lab 03 — CSRF Attack Lab: Start Script (Windows PowerShell)
# ==============================================================================

Write-Host "[Lab 03] CSRF Attack Lab — Starting Containers" -ForegroundColor White
Write-Host "------------------------------------------------"
docker compose up -d
Write-Host ""
docker compose ps
Write-Host ""
Write-Host "Lab 03 is running." -ForegroundColor Green
Write-Host ""
Write-Host "  Legitimate target site (log in as Alice here first):"
Write-Host "    http://www.seed-server.com     OR   http://localhost:10082"
Write-Host ""
Write-Host "  Malicious attacker site (visit after logging in as Alice):"
Write-Host "    http://www.attacker32.com      OR   http://localhost:10083"
