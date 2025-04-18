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

# 1. Split the token
$parts = $tokenResponse.access_token -split '\.'

# 2. Fix padding + convert from base64url to base64
$payload = $parts[1].PadRight($parts[1].Length + (4 - $parts[1].Length % 4) % 4, "=")
$payload = $payload -replace '_', '/' -replace '-', '+'

# 3. Decode
$bytes = [Convert]::FromBase64String($payload)
$json = [System.Text.Encoding]::UTF8.GetString($bytes)
$decoded = $json | ConvertFrom-Json

# 4. Print roles or scopes
$decoded | Select aud, roles, scp

$accessToken = $tokenResponse.access_token

if (-not $accessToken) {
    Write-Error "❌ Failed to retrieve access token."
    exit 1
}

# ✅ Convert access token to SecureString and connect
$secureToken = ConvertTo-SecureString $accessToken -AsPlainText -Force
Connect-MgGraph -AccessToken $secureToken
Write-Host "✅ Connected to Microsoft Graph using token."

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
Export-Csv -Path "../config/user_assignments.csv" -NoTypeInformation

