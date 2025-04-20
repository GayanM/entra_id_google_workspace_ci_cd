. "$PSScriptRoot/common-auth.ps1"
Connect-ToGraph

$importPath = Join-Path $PSScriptRoot "../config/google_workspace_config.json"
# Load configuration
$config = Get-Content $importPath | ConvertFrom-Json

# Note: For gallery apps like Google Workspace, manual app creation is required
# Here we fetch the existing app instead
$sp = Get-MgServicePrincipal -Filter "DisplayName eq 'Google Cloud / G Suite Connector by Microsoft'"
Write-Output "App exists with ID: $($sp.Id)"