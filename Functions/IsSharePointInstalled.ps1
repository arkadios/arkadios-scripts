# we need to check if SharePoint is installed, therefor we need the following function(s)
function IsSharePointInstalled([string]$version = "") { 
    [bool]$resultAsBool = $false; 
	
    Get-InstalledOfficeSoftware | % {
        if ($_ -like "*SharePoint Server $version*") {
            $resultAsBool = $true
        }
    }

	
    return $resultAsBool; 
}
