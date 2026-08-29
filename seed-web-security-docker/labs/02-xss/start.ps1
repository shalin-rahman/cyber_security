# ==============================================================================
# Lab 02 — XSS Attack Lab: Start Script (Windows PowerShell)
# ==============================================================================

Write-Host "[Lab 02] XSS Attack Lab — Starting Containers" -ForegroundColor White
Write-Host "-----------------------------------------------"

docker compose up -d

Write-Host ""
docker compose ps

Write-Host ""
Write-Host "Lab 02 is running." -ForegroundColor Green
Write-Host ""
Write-Host "  Browser access:"
Write-Host "    http://www.seed-server.com     (if hosts file configured)"
Write-Host "    http://localhost:10081         (direct port mapping)"
Write-Host ""
Write-Host "  Container shell access:"
Write-Host "    docker exec -it elgg-10.9.0.5 bash"
