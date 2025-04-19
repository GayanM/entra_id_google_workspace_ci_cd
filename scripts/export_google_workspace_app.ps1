$tenantId = $env:AZURE_TENANT_ID
$clientId = $env:AZURE_CLIENT_ID
$clientSecret = $env:AZURE_CLIENT_SECRET

# Validate input
if (-not $tenantId -or -not $clientId -or -not $clientSecret) {
    Write-Error "❌ One or more required environment variables are missing: AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET"
    exit 1
}

# Convert client secret to secure string
#$secureSecret = ConvertTo-SecureString $clientSecret -AsPlainText -Force

# Connect to Microsoft Graph using client credentials
Connect-MgGraph -ClientId $clientId -TenantId $tenantId -ClientSecret $clientSecret

# Confirm the connection
$context = Get-MgContext
Write-Output "✅ Connected to tenant: $($context.TenantId)"
#$tenantId = $env:AZURE_TENANT_ID
#$clientId = $env:AZURE_CLIENT_ID
#$clientSecret = $env:AZURE_CLIENT_SECRET

#$secureSecret = ConvertTo-SecureString $clientSecret -AsPlainText -Force
#$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientId, $secureSecret

#Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $creds

# Connect to Microsoft Graph
#Connect-MgGraph -Scopes "Application.Read.All", "Directory.Read.All", "AppRoleAssignment.Read.All"

# Get the Google Workspace Enterprise App
#$sp = Get-MgServicePrincipal -Filter "DisplayName eq 'Google Workspace'"

# Export service principal configuration
#$sp | ConvertTo-Json -Depth 10 | Out-File "../config/google_workspace_config.json"

# Export user assignments
#Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $sp.Id |
#    Select-Object PrincipalDisplayName, PrincipalId, AppRoleId |
#    Export-Csv -Path "../config/user_assignments.csv" -NoTypeInformation
