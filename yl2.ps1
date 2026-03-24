# Küsi eesnimi ja perenimi
$eesnimi = Read-Host "Sisesta kasutaja eesnimi"
$perenimi = Read-Host "Sisesta kasutaja perenimi"

# Muuda väikesteks tähtedeks
$eesnimi = $eesnimi.ToLower()
$perenimi = $perenimi.ToLower()

# Loo kasutajanimi
$kasutajaNimi = "$eesnimi.$perenimi"

Write-Host "Kustutatav kasutaja on $kasutajaNimi"

# Kontroll kas kasutaja eksisteerib
$kasutaja = Get-LocalUser -Name $kasutajaNimi -ErrorAction SilentlyContinue

if ($kasutaja) {

    # Kustuta kasutaja
    Remove-LocalUser -Name $kasutajaNimi -ErrorAction SilentlyContinue

    if ($?) {
        Write-Host "Kasutaja $kasutajaNimi kustutati edukalt." -ForegroundColor Green
    }
    else {
        Write-Host "Kasutaja kustutamine ebaõnnestus." -ForegroundColor Red
    }

}
else {
    Write-Host "Kasutajat $kasutajaNimi ei leitud." -ForegroundColor Yellow
}