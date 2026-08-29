Write-Host "[Lab 02] XSS Attack Lab — Setup" -ForegroundColor White
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$entry = "10.9.0.5   www.seed-server.com"
if (Select-String -Path $hostsFile -Pattern "www.seed-server.com" -Quiet 2>$null) {
    Write-Host "✓ hosts already contains www.seed-server.com" -ForegroundColor Green
} else {
    try { Add-Content -Path $hostsFile -Value $entry; Write-Host "✓ Added: $entry" -ForegroundColor Green }
    catch { Write-Host "ERROR: Run as Administrator. Add manually: $entry to $hostsFile" -ForegroundColor Red }
}
docker compose pull
Write-Host "✓ Setup complete. Run .\start.ps1" -ForegroundColor Green
