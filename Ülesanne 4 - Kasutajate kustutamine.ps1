Import-Module ActiveDirectory

# --- Translit funktsioon ---
function Convert-ToUsername {
    param ([string]$text)

    $text = $text.ToLower()

    $map = @{
        "ä"="a"; "ö"="o"; "ü"="u"; "õ"="o";
        "š"="s"; "ž"="z"
    }

    foreach ($key in $map.Keys) {
        $text = $text -replace $key, $map[$key]
    }

    return $text
}

# --- Küsi kasutajalt nimi ---
$firstName = Read-Host "Sisesta kasutaja eesnimi"
$lastName  = Read-Host "Sisesta kasutaja perenimi"

# --- Tee kasutajanimi ---
$username = "$(Convert-ToUsername $firstName).$(Convert-ToUsername $lastName)"

Write-Host "INFO: Otsin kasutajat '$username'..." -ForegroundColor Cyan

# --- Kontroll: kas kasutaja olemas ---
$user = Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue

if (-not $user) {
    Write-Host "INFO: Kasutajat '$username' ei eksisteeri. Midagi ei kustutata." -ForegroundColor Yellow
}
else {
    try {
        Remove-ADUser -Identity $user -Confirm:$false -ErrorAction Stop

        if ($?) {
            Write-Host "SUCCESS: Kasutaja '$username' kustutati edukalt." -ForegroundColor Green
        }
        else {
            Write-Host "ERROR: Kasutaja '$username' kustutamine ebaõnnestus." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "ERROR: Kustutamisel tekkis viga: $($_.Exception.Message)" -ForegroundColor Red
    }
}