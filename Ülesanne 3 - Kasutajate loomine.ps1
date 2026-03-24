Import-Module ActiveDirectory

# Kasutajate fail
$users = Get-Content "C:\Temp\users.txt"

# Vaikimisi parool
$defaultPassword = ConvertTo-SecureString "Parool1!" -AsPlainText -Force

# OU / konteiner (PARANDA vastavalt oma AD-le!)
$ouPath = "CN=Users,DC=sv-kool,DC=local"

foreach ($user in $users) {

    # Kontroll: kas kasutaja juba olemas
    $existingUser = Get-ADUser -Filter "SamAccountName -eq '$user'" -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Host "INFO: Kasutaja '$user' on juba olemas. Lisamist ei teostata." -ForegroundColor Yellow
        continue
    }

    Write-Host "INFO: Kasutajat '$user' ei leitud. Alustan loomist..." -ForegroundColor Cyan

    # Ees- ja perekonnanimi turvaliselt
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
            -AccountPassword $defaultPassword `
            -Path $ouPath `
            -ErrorAction Stop

        # Kontroll: kas käsk õnnestus
        if ($?) {
            Write-Host "SUCCESS: Kasutaja '$user' loomine õnnestus." -ForegroundColor Green
        }
        else {
            Write-Host "ERROR: Kasutaja '$user' loomine ebaõnnestus." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "ERROR: Kasutaja '$user' loomisel tekkis viga: $($_.Exception.Message)" -ForegroundColor Red
    }
}