function Get-AssessmentData {
    $results = @{}
    # Die korrigierte Basis-URL des Publishers
    $pubBase = "https://raw.githubusercontent.com/ThomasKur/M365Documentation/master/M365Documentation/Functions/Public"
    
    # Präzises Mapping der Unterordner
    $mapping = @{
        "AzureAD"  = "$pubBase/AzureAD/Get-M365RepoAzureAD.ps1"
        "Intune"   = "$pubBase/Intune/Get-M365RepoIntune.ps1"
        "Exchange" = "$pubBase/ExchangeOnline/Get-M365RepoExchangeOnline.ps1"
        "Teams"    = "$pubBase/Teams/Get-M365RepoTeams.ps1"
    }

    foreach ($service in $mapping.Keys) {
        try {
            $url = $mapping[$service]
            Write-Host "Hole Logik für $service..." -ForegroundColor Gray
            
            # Skriptinhalt vom Publisher laden
            $code = Invoke-RestMethod -Uri $url -ErrorAction Stop
            
            # In den lokalen Speicher laden (Dot-Sourcing)
            $sb = [scriptblock]::Create($code)
            . $sb 

            # Funktionsname bestimmen
            $funcName = "Get-M365Repo" + ($service -eq "Exchange" ? "ExchangeOnline" : $service)
            
            Write-Host "Extrahiere Daten: $service" -ForegroundColor Cyan
            $results[$service] = Invoke-Expression $funcName -ErrorAction Stop
        } catch {
            Write-Warning "Konnte $service nicht laden. Pfad prüfen: $url"
        }
    }
    return $results
}
