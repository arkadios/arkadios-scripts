function Get-InstalledOfficeSoftware{
<#
.SYNOPSIS
    Lists installed Microsoft Office software from the registry.

.DESCRIPTION
    Queries the HKLM Uninstall registry key and filters entries matching the
    specified PsPath filter pattern. Returns display name and major version
    for each matching entry.

.PARAMETER PsPathFilter
    A wildcard filter applied to the PsPath of registry entries. Defaults to "*\Office*".

.EXAMPLE
    Get-InstalledOfficeSoftware

.EXAMPLE
    Get-InstalledOfficeSoftware -PsPathFilter "*\Visio*"
#>
    param([string]$PsPathFilter="*\Office*")
	$resultAsStringArray = ""
	$RegLoc = Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall
	$Programms  = $RegLoc | where { $_.PsPath -like "$PsPathFilter" } 
	$resultAsStringArray = $Programms | %{"Name: '" + $_.GetValue("DisplayName") + "' Version: '" + $_.GetValue("VersionMajor")+ "'"}
	return $resultAsStringArray
}

