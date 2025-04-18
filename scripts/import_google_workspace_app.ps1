
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.ReadWrite.All", "Directory.ReadWrite.All"

# Load configuration
$config = Get-Content "../config/google_workspace_config.json" | ConvertFrom-Json

# Note: For gallery apps like Google Workspace, manual app creation is required
# Here we fetch the existing app instead
$sp = Get-MgServicePrincipal -Filter "DisplayName eq 'Google Workspace'"
Write-Output "App exists with ID: $($sp.Id)"
