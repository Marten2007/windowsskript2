Import-Module ActiveDirectory

# Kasutajate fail
$users = Get-Content "C:\Temp\users.txt"

# CSV väljundfail
$outputFile = "C:\Temp\kasutajanimi.csv"

# Kui fail eksisteerib, kustuta (et ei lisaks vana sisu otsa)
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

# --- Parooli genereerimise funktsioon ---
function Generate-Password {
    param (
        [int]$length = 10
    )

    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%"
    -join ((1..$length) | ForEach-Object { $chars | Get-Random })
}

# OU / konteiner (kontrolli oma AD järgi!)
$ouPath = "CN=Users,DC=sv-kool,DC=local"

foreach ($user in $users) {

    # Kontroll: kas kasutaja juba olemas
    $existingUser = Get-ADUser -Filter "SamAccountName -eq '$user'" -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Host "INFO: Kasutaja '$user' on juba olemas. Lisamist ei teostata." -ForegroundColor Yellow
        continue
    }

    Write-Host "INFO: Loon kasutaja '$user'..." -ForegroundColor Cyan

    # Genereeri parool
    $plainPassword = Generate-Password
    $securePassword = ConvertTo-SecureString $plainPassword -AsPlainText -Force

    # Ees- ja perekonnanimi
    $parts = $user.Split(".")
    $givenName = $parts[0]
    $surname = if ($parts.Count -gt 1) { $parts[1] } else { "" }

    try {
        New-ADUser `
            -SamAccountName $user `
            -UserPrincipalName "$user@sv-kool.local" `
            -Name $user `
            -GivenName $givenName `
            -Surname $surname `
            -Enabled $true `
            -AccountPassword $securePassword `
            -Path $ouPath `
            -ErrorAction Stop

        if ($?) {
            Write-Host "SUCCESS: Kasutaja '$user' loodud." -ForegroundColor Green

            # Salvesta CSV faili
            [PSCustomObject]@{
                Kasutajanimi = $user
                Parool       = $plainPassword
            } | Export-Csv -Path $outputFile -Append -NoTypeInformation -Encoding UTF8
        }
        else {
            Write-Host "ERROR: Kasutaja '$user' loomine ebaõnnestus." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "ERROR: Kasutaja '$user' loomisel tekkis viga: $($_.Exception.Message)" -ForegroundColor Red
    }
}