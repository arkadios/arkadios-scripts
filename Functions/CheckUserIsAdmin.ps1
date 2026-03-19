function CheckUserIsAdmin(){
<#
.SYNOPSIS
    Checks whether the current user is running as Administrator.

.DESCRIPTION
    Returns $true if the current Windows identity has the Administrator built-in role,
    $false otherwise.
    This function is only supported on Windows.

.EXAMPLE
    if (CheckUserIsAdmin) { Write-Host "Running as admin" }
#>
    if ($PSVersionTable.PSEdition -ne 'Desktop' -and -not $IsWindows) {
        Write-Error "CheckUserIsAdmin is only supported on Windows."
        return $false
    }
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator")
}