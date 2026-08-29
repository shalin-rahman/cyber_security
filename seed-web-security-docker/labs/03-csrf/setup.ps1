# CSRF Lab — Setup Script (PowerShell)
param()
Write-Host "[Lab 03] CSRF Attack Lab — Setup" -ForegroundColor White
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"

foreach ($entry in @("10.9.0.5    www.seed-server.com", "10.9.0.105  www.attacker32.com")) {
    $domain = ($entry -split '\s+')[1]
    if (Select-String -Path $hostsFile -Pattern $domain -Quiet 2>$null) {
        Write-Host "✓ hosts contains $domain" -ForegroundColor Green
    } else {
        try { Add-Content -Path $hostsFile -Value $entry; Write-Host "✓ Added: $entry" -ForegroundColor Green }
        catch { Write-Host "ERROR: Run PowerShell as Administrator. Add: $entry to $hostsFile" -ForegroundColor Red }
    }
}

docker compose pull
Write-Host "✓ Setup complete. Run .\start.ps1" -ForegroundColor Green
