# =============================================================================
# SEED Web Security Docker — Status Script (PowerShell)
# Usage: .\scripts\status.ps1
# =============================================================================

Write-Host ""
Write-Host '==========================================================' -ForegroundColor White
Write-Host '         SEED Web Security Docker — Lab Status            ' -ForegroundColor White
Write-Host '==========================================================' -ForegroundColor White
Write-Host ""

Write-Host '-- All Docker Containers --------------------------------------' -ForegroundColor Cyan
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>&1
Write-Host ""

Write-Host '-- Docker Networks (SEED Labs) --------------------------------' -ForegroundColor Cyan
docker network ls --filter "name=net-10.9.0.0" --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" 2>&1
Write-Host ""

Write-Host '-- Disk Usage -------------------------------------------------' -ForegroundColor Cyan
docker system df 2>&1
Write-Host ""

Write-Host '-- Quick Lab URLs ---------------------------------------------' -ForegroundColor Cyan
Write-Host '  Lab 01 SQL Injection  -> http://www.seed-server.com        (port 10080)' -ForegroundColor Green
Write-Host '  Lab 02 XSS            -> http://www.seed-server.com        (port 10081)' -ForegroundColor Green
Write-Host '  Lab 03 CSRF           -> http://www.seed-server.com        (port 10082)' -ForegroundColor Green
Write-Host '  Lab 03 CSRF Attacker  -> http://www.attacker32.com         (port 10083)' -ForegroundColor Green
Write-Host '  Lab 04 Clickjacking   -> http://www.cjlab.com              (port 10084)' -ForegroundColor Green
Write-Host '  Lab 05 Shellshock     -> http://localhost:10086/cgi-bin/vul.cgi (port 10086)' -ForegroundColor Green
Write-Host ""
Write-Host 'Note: Hostnames require entries in C:\Windows\System32\drivers\etc\hosts' -ForegroundColor Yellow
Write-Host '      See each lab README for the exact entries needed.' -ForegroundColor Yellow
Write-Host ""
