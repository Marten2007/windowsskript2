Import-Module ActiveDirectory

$backupPath = "C:\Backup"

if (-not (Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath
}

$date = Get-Date -Format "dd.MM.yyyy"

$users = Get-ADUser -Filter *

foreach ($user in $users) {

    $username = $user.SamAccountName

    # Proovi AD HomeDirectory
    $homeDir = (Get-ADUser $username -Properties HomeDirectory).HomeDirectory

    # Kui puudub → kasuta lokaalne profiil
    if (-not $homeDir) {
        $homeDir = "C:\Users\$username"
    }

    # Kontroll: kas kaust eksisteerib
    if (-not (Test-Path $homeDir)) {
        Write-Host "INFO: Kodukataloog puudub või ei eksisteeri: $homeDir (kasutaja: $username)" -ForegroundColor Yellow
        continue
    }

    $zipFile = "$backupPath\$username-$date.zip"

    Write-Host "INFO: Varundan '$username' ($homeDir)..." -ForegroundColor Cyan

    try {
        Compress-Archive -Path "$homeDir\*" -DestinationPath $zipFile -Force -ErrorAction Stop

        if ($?) {
            Write-Host "SUCCESS: Varundus loodud -> $zipFile" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "ERROR: $username varundamine ebaõnnestus: $($_.Exception.Message)" -ForegroundColor Red
    }
}