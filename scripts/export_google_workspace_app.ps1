
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.Read.All", "Directory.Read.All", "AppRoleAssignment.Read.All"

# Get the Google Workspace Enterprise App
$sp = Get-MgServicePrincipal -Filter "DisplayName eq 'Google Workspace'"

# Export service principal configuration
$sp | ConvertTo-Json -Depth 10 | Out-File "../config/google_workspace_config.json"

# Export user assignments
Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $sp.Id |
    Select-Object PrincipalDisplayName, PrincipalId, AppRoleId |
    Export-Csv -Path "../config/user_assignments.csv" -NoTypeInformation
