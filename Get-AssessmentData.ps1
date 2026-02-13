# INHALT FÜR DEINE GITHUB-DATEI: Get-AssessmentData.ps1
function Get-AssessmentData {
    $results = @{}

    # --- Azure AD / Entra ID ---
    Write-Host "Extracting Azure AD..." -ForegroundColor Gray
    $results.AzureAD = @{
        Organization = Get-MgOrganization
        Domains      = Get-MgDomain
        Security     = Get-MgDirectorySetting
    }

    # --- Exchange Online ---
    Write-Host "Extracting Exchange..." -ForegroundColor Gray
    $results.Exchange = @{
        OrgConfig      = Get-OrganizationConfig
        TransportConfig = Get-TransportConfig
        MailFlow       = Get-AcceptedDomain
    }

    # --- Intune ---
    Write-Host "Extracting Intune..." -ForegroundColor Gray
    $results.Intune = @{
        DeviceSettings = Get-MgDeviceManagementManagedDevice
        Policies       = Get-MgDeviceManagementDeviceConfiguration
    }

    return $results
}
