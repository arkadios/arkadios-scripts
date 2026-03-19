function IsSharePointInstalled([string]$version = "") {
<#
.SYNOPSIS
    Checks whether SharePoint Server is installed on the local machine.

.DESCRIPTION
    Queries installed Office software via Get-InstalledOfficeSoftware and checks
    if any entry matches "SharePoint Server" with the optionally specified version.

.PARAMETER version
    Optional SharePoint version string to match (e.g. "2016", "2019"). If empty, matches any version.

.EXAMPLE
    if (IsSharePointInstalled -version "2016") { Write-Host "SP 2016 found" }
#>
    [bool]$resultAsBool = $false; 
	
    Get-InstalledOfficeSoftware | % {
        if ($_ -like "*SharePoint Server $version*") {
            $resultAsBool = $true
        }
    }

	
    return $resultAsBool; 
}
