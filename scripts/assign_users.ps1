
# Import Microsoft Graph module
Import-Module Microsoft.Graph -ErrorAction Stop

# Load credentials from environment variables
$tenantId     = $env:AZURE_TENANT_ID
$clientId     = $env:AZURE_CLIENT_ID
$clientSecret = $env:AZURE_CLIENT_SECRET

# Validate inputs
if (-not $tenantId -or -not $clientId -or -not $clientSecret) {
    Write-Error "❌ Missing one or more required environment variables."
    exit 1
}

# Acquire Microsoft Graph token using client credentials
$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Body @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type    = "client_credentials"
} -ContentType "application/x-www-form-urlencoded"

Write-Host "📁 Raw Token Response: $tokenResponse"

$accessToken = $tokenResponse.access_token

if (-not $accessToken) {
    Write-Error "❌ Failed to retrieve access token."
    exit 1
}

# ✅ Convert access token to SecureString and connect
$secureToken = ConvertTo-SecureString $accessToken -AsPlainText -Force
Connect-MgGraph -AccessToken $secureToken
Write-Host "✅ Connected to Microsoft Graph using token."

# Get the service principal
$sp = Get-MgServicePrincipal -Filter "DisplayName eq 'Google Cloud / G Suite Connector by Microsoft'"

$Path = Join-Path $PSScriptRoot "../config/user_assignments.csv"
# Import users
$assignments = Import-Csv $Path

foreach ($user in $assignments) {
    $existing = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $sp.Id |
        Where-Object { $_.PrincipalId -eq $user.PrincipalId -and $_.AppRoleId -eq $user.AppRoleId }

    if (-not $existing) {
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id `
            -PrincipalId $user.PrincipalId `
            -AppRoleId $user.AppRoleId `
            -ResourceId $sp.Id
        Write-Host "✅ Assigned $($user.PrincipalDisplayName)"
    } else {
        Write-Host "⏭️ Skipped existing assignment for $($user.PrincipalDisplayName)"
    }
}
