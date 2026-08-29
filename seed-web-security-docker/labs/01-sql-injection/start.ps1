# ==============================================================================
# Lab 01 — SQL Injection Attack Lab: Start Script (Windows PowerShell)
# ==============================================================================

Write-Host "[Lab 01] SQL Injection Attack Lab — Starting Containers" -ForegroundColor White
Write-Host "--------------------------------------------------------"

# Start both containers in detached mode (-d).
# Docker Compose reads docker-compose.yml and starts:
#   www-10.9.0.5    -> Apache + vulnerable PHP app (mapped to localhost:10080)
#   mysql-10.9.0.6  -> MySQL 8.0 with pre-loaded employee credential database
docker compose up -d

Write-Host ""
docker compose ps

Write-Host ""
Write-Host "Lab 01 is running." -ForegroundColor Green
Write-Host ""
Write-Host "  Browser access:"
Write-Host "    http://www.seed-server.com     (if hosts file configured)"
Write-Host "    http://localhost:10080         (direct — always works)"
Write-Host ""
Write-Host "  Container shell access (Linux inspection):"
Write-Host "    docker exec -it www-10.9.0.5 bash"
Write-Host "    docker exec -it mysql-10.9.0.6 bash"
Write-Host ""
Write-Host "  MySQL direct access:"
Write-Host "    docker exec -it mysql-10.9.0.6 mysql -u root -pdees sqllab_users"
