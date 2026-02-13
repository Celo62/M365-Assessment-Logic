function Get-AssessmentData {
    $results = @{}
    
    # Wir definieren mögliche Basis-Pfade, falls der Publisher etwas verschoben hat
    $basePaths = @(
        "https://raw.githubusercontent.com/ThomasKur/M365Documentation/master/M365Documentation/Functions/Public/Microsoft365",
        "https://raw.githubusercontent.com/ThomasKur/M365Documentation/main/M365Documentation/Functions/Public/Microsoft365",
        "https://raw.githubusercontent.com/ThomasKur/M365Documentation/master/M365Documentation/Functions/Public",
        "https://raw.githubusercontent.com/ThomasKur/M365Documentation/main/M365Documentation/Functions/Public"
    )

    $services = @{
        "AzureAD"  = "Get-M365RepoAzureAD.ps1"
        "Intune"   = "Get-M365RepoIntune.ps1"
        "Exchange" = "Get-M365RepoExchangeOnline.ps1"
        "Teams"    = "Get-M365RepoTeams.ps1"
    }

    foreach ($service in $services.Keys) {
        $found = $false
        Write-Host "`nSuche Logik für $service..." -ForegroundColor Yellow
        
        foreach ($base in $basePaths) {
            # Wir bauen den Pfad dynamisch (manche liegen in Unterordnern, manche nicht)
            $urlsToTry = @(
                "$base/$($services[$service])",
                "$base/$service/$($services[$service])"
            )
            
            foreach ($url in $urlsToTry) {
                try {
                    $response = Invoke-WebRequest -Uri $url -Method Head -ErrorAction SilentlyContinue
                    if ($response.StatusCode -eq 200) {
                        Write-Host "Gefunden! Lade von: $url" -ForegroundColor Gray
                        $code = Invoke-RestMethod -Uri $url
                        $sb = [scriptblock]::Create($code)
                        . $sb # Dot-Sourcing lokal
                        
                        $funcName = "Get-M365Repo" + ($service -eq "Exchange" ? "ExchangeOnline" : $service)
                        Write-Host "Extrahiere Daten für $service..." -ForegroundColor Cyan
                        $results[$service] = Invoke-Expression $funcName
                        $found = $true
                        break
                    }
                } catch { }
            }
            if ($found) { break }
        }
        
        if (!$found) {
            Write-Warning "Konnte die Logik für $service unter keinem bekannten Pfad finden."
        }
    }
    return $results
}
