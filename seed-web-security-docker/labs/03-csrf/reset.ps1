Write-Host "⚠️  This resets CSRF lab database state." -ForegroundColor Red
$confirm = Read-Host "Proceed? [y/N]"
if ($confirm -ine "y") { Write-Host "Cancelled."; exit 0 }
docker compose down -v; docker compose up -d
Write-Host "✓ CSRF lab reset." -ForegroundColor Green
