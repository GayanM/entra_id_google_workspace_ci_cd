# common-auth.ps1

function Get-GraphAccessToken {
    param (
        [string]$TenantId = $env:AZURE_TENANT_ID,
        [string]$ClientId = $env:AZURE_CLIENT_ID,
        [string]$ClientSecret = $env:AZURE_CLIENT_SECRET
    )

    if (-not $TenantId -or -not $ClientId -or -not $ClientSecret) {
        throw "Missing AZURE_TENANT_ID, AZURE_CLIENT_ID, or AZURE_CLIENT_SECRET"
    }

    $body = @{
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = "https://graph.microsoft.com/.default"
        grant_type    = "client_credentials"
    }

    $response = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $body -ContentType "application/x-www-form-urlencoded"
    return $response.access_token
}

function Connect-ToGraph {
    $token = Get-GraphAccessToken
    $secureToken = ConvertTo-SecureString $token -AsPlainText -Force
    Connect-MgGraph -AccessToken $secureToken
    Write-Host "✅ Connected to Microsoft Graph"
}
