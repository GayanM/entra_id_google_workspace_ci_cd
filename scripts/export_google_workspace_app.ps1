# Install MSAL module if not already available
if (-not (Get-Module -ListAvailable -Name Microsoft.Authentication.MSAL.PS)) {
    Install-Module Microsoft.Authentication.MSAL.PS -Force -Scope CurrentUser
}

Import-Module Microsoft.Graph -ErrorAction Stop
Import-Module Microsoft.Authentication.MSAL.PS -ErrorAction Stop

# Load credentials from environment
$tenantId     = $env:AZURE_TENANT_ID
$clientId     = $env:AZURE_CLIENT_ID
$clientSecret = $env:AZURE_CLIENT_SECRET

# Validate input
if (-not $tenantId -or -not $clientId -or -not $clientSecret) {
    Write-Error "❌ One or more required environment variables are missing: AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET"
    exit 1
}

# ✅ Get access token using Client Credentials via MSAL
$token = Get-MsalToken `
    -ClientId $clientId `
    -ClientSecret (ConvertTo-SecureString $clientSecret -AsPlainText -Force) `
    -TenantId $tenantId `
    -Scopes "https://graph.microsoft.com/.default"

if (-not $token.AccessToken) {
    Write-Error "❌ Failed to acquire token using client credentials."
    exit 1
}

# 🔐 Authenticate using the access token
Connect-MgGraph -AccessToken $token.AccessToken
Write-Host "✅ Connected to Microsoft Graph."