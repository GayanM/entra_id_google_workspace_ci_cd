
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "AppRoleAssignment.ReadWrite.All"

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
