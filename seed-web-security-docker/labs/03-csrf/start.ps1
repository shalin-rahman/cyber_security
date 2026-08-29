docker compose up -d; docker compose ps
Write-Host "✓ CSRF Lab running:" -ForegroundColor Green
Write-Host "  Legitimate site: http://www.seed-server.com  (Port 10082)" -ForegroundColor Green
Write-Host "  Attacker site:   http://www.attacker32.com   (Port 10083)" -ForegroundColor Green
