# Küsi eesnimi ja perenimi
$eesnimi = Read-Host "Sisesta oma eesnimi"
$perenimi = Read-Host "Sisesta oma perenimi"

$eesnimi = $eesnimi.ToLower()
$perenimi = $perenimi.ToLower()

$kasutajaNimi = "$eesnimi.$perenimi"

Write-Host "Loodav kasutaja on $kasutajaNimi"

$parool = ConvertTo-SecureString "Parool1!" -AsPlainText -Force

$olemas = Get-LocalUser -Name $kasutajaNimi -ErrorAction SilentlyContinue

if ($olemas) {
    Write-Host "Kasutaja $kasutajaNimi on juba olemas." -ForegroundColor Yellow
}
else {
    try {
        New-LocalUser `
        -Name $kasutajaNimi `
        -Password $parool `
        -FullName "$eesnimi $perenimi" `
        -Description "Lokaalne kasutaja $eesnimi $perenimi" `
        -ErrorAction Stop

        Write-Host "Tekkinud probleem kasutaja loomisega ei ole." -ForegroundColor Green
    }
    catch {
        Write-Host "Kasutaja loomine ebaõnnestus." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}