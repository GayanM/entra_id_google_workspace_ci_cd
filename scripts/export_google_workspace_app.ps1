Import-Module Microsoft.Graph -ErrorAction Stop
Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

# Load credentials from environment
$tenantId     = $env:AZURE_TENANT_ID
$clientId     = $env:AZURE_CLIENT_ID
$clientSecret = $env:AZURE_CLIENT_SECRET

# Validate input
if (-not $tenantId -or -not $clientId -or -not $clientSecret) {
    Write-Error "❌ One or more required environment variables are missing: AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET"
    exit 1
}

# Get access token using MSAL
$tokenResponse = az account get-access-token `
    --service-principal `
    --username $clientId `
    --password $clientSecret `
    --tenant $tenantId `
    --resource https://graph.microsoft.com `
    --output json | ConvertFrom-Json

$accessToken = $tokenResponse.accessToken

if (-not $accessToken) {
    Write-Error "❌ Failed to retrieve access token."
    exit 1
}

# Connect to Microsoft Graph using the token
Connect-MgGraph -AccessToken $accessToken
Write-Output "✅ Connected to Microsoft Graph with token."