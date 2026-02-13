function Get-AssessmentData {
    $results = @{}
    
    # EXAKTER PFAD AUS DEINEM SCREENSHOT
    # Wir fügen 'main' als Branch ein und nutzen dann deinen Pfad
    $pubBase = "https://raw.githubusercontent.com/ThomasKur/M365Documentation/main/PSModule/M365Documentation/Functions"
    
    # In diesem Repo liegen die Repo-Skripte meist in einem 'Public/Microsoft365' Unterordner
    $mapping = @{
        "AzureAD"  = "$pubBase/Public/Microsoft365/AzureAD/Get-M365RepoAzureAD.ps1"
        "Intune"   = "$pubBase/Public/Microsoft365/Intune/Get-M365RepoIntune.ps1"
        "Exchange" = "$pubBase/Public/Microsoft365/ExchangeOnline/Get-M365RepoExchangeOnline.ps1"
        "Teams"    = "$pubBase/Public/Microsoft365/Teams/Get-M365RepoTeams.ps1"
    }

    foreach ($service in $mapping.Keys) {
        $url = $mapping[$service]
        try {
            Write-Host "Hole Logik für $service von Publisher..." -ForegroundColor Gray
            $code = Invoke-RestMethod -Uri $url -ErrorAction Stop
            
            # Dot-Sourcing: Lädt den Code in deinen lokalen RAM
            $sb = [scriptblock]::Create($code)
            . $sb 

            $funcName = "Get-M365Repo" + ($service -eq "Exchange" ? "ExchangeOnline" : $service)
            Write-Host "Extrahiere Daten: $service" -ForegroundColor Cyan
            
            # Ausführung auf deinem Rechner
            $results[$service] = Invoke-Expression $funcName -ErrorAction Stop
        } catch {
            Write-Warning "Pfad-Check: Konnte $service nicht laden unter $url"
        }
    }
    return $results
}
