Write-Host "⚠️  This will destroy all database changes and restore original lab data." -ForegroundColor Red
$confirm = Read-Host "Proceed? [y/N]"
if ($confirm -ine "y") { Write-Host "Reset cancelled."; exit 0 }
docker compose down -v
docker compose up -d
Write-Host "✓ Lab reset to original state." -ForegroundColor Green
