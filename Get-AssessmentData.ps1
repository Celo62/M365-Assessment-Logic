function Get-AssessmentData {
    $results = @{}
    # Die Basis-URL des Publishers (Thomas Kur)
    $pubBase = "https://raw.githubusercontent.com/ThomasKur/M365Documentation/master/M365Documentation/Functions/Public"
    
    $mapping = @{
        "AzureAD"  = "$pubBase/AzureAD/Get-M365RepoAzureAD.ps1"
        "Exchange" = "$pubBase/ExchangeOnline/Get-M365RepoExchangeOnline.ps1"
        "Intune"   = "$pubBase/Intune/Get-M365RepoIntune.ps1"
        "Teams"    = "$pubBase/Teams/Get-M365RepoTeams.ps1"
    }

    foreach ($service in $mapping.Keys) {
        try {
            Write-Host "Lade Deep-Logic für $service von Publisher..." -ForegroundColor Gray
            $code = Invoke-RestMethod -Uri $mapping[$service]
            $sb = [scriptblock]::Create($code)
            . $sb # Dot-Sourcing der Publisher-Logik

            # Dynamischer Aufruf der Publisher-Funktion
            $funcName = "Get-M365Repo" + ($service -eq "Exchange" ? "ExchangeOnline" : $service)
            Write-Host "Extrahiere alle Daten für $service..." -ForegroundColor Cyan
            $results[$service] = Invoke-Expression $funcName
        } catch {
            Write-Warning "Konnte $service nicht extrahieren: $($_.Exception.Message)"
        }
    }
    return $results
}
