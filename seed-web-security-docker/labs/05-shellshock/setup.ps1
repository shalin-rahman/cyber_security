# Shellshock Lab — Setup Script (PowerShell)
param()
Write-Host "[Lab 05] Shellshock Vulnerability Lab — Setup" -ForegroundColor White
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$entry = "10.9.0.80   www.seedlab-shellshock.com"

if (Select-String -Path $hostsFile -Pattern "www.seedlab-shellshock.com" -Quiet 2>$null) {
    Write-Host "✓ hosts contains www.seedlab-shellshock.com" -ForegroundColor Green
} else {
    try { Add-Content -Path $hostsFile -Value $entry; Write-Host "✓ Added: $entry" -ForegroundColor Green }
    catch { Write-Host "ERROR: Run PowerShell as Administrator. Add: $entry to $hostsFile" -ForegroundColor Red }
}

docker compose pull
Write-Host "✓ Setup complete. Run .\start.ps1" -ForegroundColor Green
