. "$PSScriptRoot/common-auth.ps1"
Connect-ToGraph

# Get the Google Workspace Enterprise App
$sp = Get-MgServicePrincipal -Filter "DisplayName eq 'Google Cloud / G Suite Connector by Microsoft'"
Write-Host "🔎 Service principal found: $($sp.DisplayName) [$($sp.Id)]"

# Ensure export directory exists relative to this script
$exportPath = Join-Path $PSScriptRoot "../config"

if (-not (Test-Path $exportPath)) {
    New-Item -ItemType Directory -Path $exportPath -Force | Out-Null
}

Write-Host "📁 Export path is: $exportPath"

# Export service principal config
$sp | ConvertTo-Json -Depth 10 | Out-File (Join-Path $exportPath "google_workspace_config.json")
Write-Host "✅ Exported service principal config"

# Export user assignments
Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $sp.Id |
Select-Object PrincipalDisplayName, PrincipalId, AppRoleId |
Export-Csv -Path (Join-Path $exportPath "user_assignments.csv") -Append -NoTypeInformation
Write-Host "✅ Exported user assignments"
