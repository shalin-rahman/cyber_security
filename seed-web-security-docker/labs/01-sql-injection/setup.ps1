# SQL Injection Lab — Setup Script (PowerShell)
# Run as Administrator to modify hosts file
param()
Write-Host "[Lab 01] SQL Injection — Setup" -ForegroundColor White

$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$entry = "10.9.0.5   www.seed-server.com"

if (Select-String -Path $hostsFile -Pattern "www.seed-server.com" -Quiet 2>$null) {
    Write-Host "✓ hosts file already contains www.seed-server.com" -ForegroundColor Green
} else {
    try {
        Add-Content -Path $hostsFile -Value $entry
        Write-Host "✓ Added to hosts: $entry" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Could not write to hosts file. Run PowerShell as Administrator." -ForegroundColor Red
        Write-Host "Manually add: $entry" -ForegroundColor Yellow
        Write-Host "To file: $hostsFile" -ForegroundColor Yellow
    }
}

Write-Host "`nPulling lab images (first run may take several minutes)..." -ForegroundColor Yellow
docker compose pull
Write-Host "✓ Setup complete. Run .\start.ps1 to launch the lab." -ForegroundColor Green
