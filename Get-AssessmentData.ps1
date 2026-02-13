function Get-AssessmentData {
    $results = @{}
    # Wir testen beide gängigen Zweige: main und master
    $branches = @("main", "master")
    $foundBase = $null

    # Suche nach dem richtigen Pfad beim Publisher
    foreach ($branch in $branches) {
        $testUrl = "https://raw.githubusercontent.com/ThomasKur/M365Documentation/$branch/M365Documentation/Functions/Public/Teams/Get-M365RepoTeams.ps1"
        try {
            $test = Invoke-WebRequest -Uri $testUrl -Method Head -ErrorAction SilentlyContinue
            if ($test.StatusCode -eq 200) { 
                $foundBase = "https://raw.githubusercontent.com/ThomasKur/M365Documentation/$branch/M365Documentation/Functions/Public"
                break 
            }
        } catch {}
    }

    if (!$foundBase) {
        Write-Error "Konnte die Basis-URL des Publishers nicht finden (404 auf allen Branches)."
        return $results
    }

    $mapping = @{
        "AzureAD"  = "$foundBase/AzureAD/Get-M365RepoAzureAD.ps1"
        "Intune"   = "$foundBase/Intune/Get-M365RepoIntune.ps1"
        "Exchange" = "$foundBase/ExchangeOnline/Get-M365RepoExchangeOnline.ps1"
        "Teams"    = "$foundBase/Teams/Get-M365RepoTeams.ps1"
    }

    foreach ($service in $mapping.Keys) {
        try {
            $url = $mapping[$service]
            Write-Host "Lade Logik für $service von: $url" -ForegroundColor Gray
            
            $code = Invoke-RestMethod -Uri $url -ErrorAction Stop
            $sb = [scriptblock]::Create($code)
            . $sb # Dot-Sourcing: Lädt die Funktion lokal in den RAM

            $funcName = "Get-M365Repo" + ($service -eq "Exchange" ? "ExchangeOnline" : $service)
            Write-Host "Extrahiere Daten: $service..." -ForegroundColor Cyan
            $results[$service] = Invoke-Expression $funcName -ErrorAction Stop
        } catch {
            Write-Warning "Konnte $service nicht laden. Fehler: $($_.Exception.Message)"
        }
    }
    return $results
}
