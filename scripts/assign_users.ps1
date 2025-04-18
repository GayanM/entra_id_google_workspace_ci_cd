
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "AppRoleAssignment.ReadWrite.All"

# Get the service principal
$sp = Get-MgServicePrincipal -Filter "DisplayName eq 'Google Workspace'"

# Import users
$assignments = Import-Csv "../config/user_assignments.csv"

foreach ($user in $assignments) {
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id `
        -PrincipalId $user.PrincipalId `
        -AppRoleId $user.AppRoleId `
        -ResourceId $sp.Id
}
