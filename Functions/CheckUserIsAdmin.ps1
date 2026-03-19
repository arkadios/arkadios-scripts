function CheckUserIsAdmin(){
<#
.SYNOPSIS
    Checks whether the current user is running as Administrator.

.DESCRIPTION
    Returns $true if the current Windows identity has the Administrator built-in role,
    $false otherwise.

.EXAMPLE
    if (CheckUserIsAdmin) { Write-Host "Running as admin" }
#>
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator")
}