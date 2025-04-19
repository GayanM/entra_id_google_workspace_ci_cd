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

# Create a ClientSecretCredential from Azure.Identity
$credential = [Microsoft.Graph.Auth.ClientSecretCredentialFactory]::Create($tenantId, $clientId, $clientSecret)

# Connect to Microsoft Graph
Connect-MgGraph -Credential $credential
Write-Host "✅ Connected to Microsoft Graph using ClientSecretCredential."