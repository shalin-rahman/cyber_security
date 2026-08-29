docker compose up -d; docker compose ps
Write-Host "✓ Clickjacking Lab running:" -ForegroundColor Green
Write-Host "  Target site:   http://www.cjlab.com          (Port 10084)" -ForegroundColor Green
Write-Host "  Attacker site: http://www.cjlab-attacker.com (Port 10085)" -ForegroundColor Green
