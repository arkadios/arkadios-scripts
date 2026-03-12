
function Get-InstalledOfficeSoftware([string]$PsPathFilter="*\Office*"){ 
	$resultAsStringArray = ""
	$RegLoc = Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall
	$Programms  = $RegLoc | where { $_.PsPath -like "$PsPathFilter" } 
	$resultAsStringArray = $Programms | %{"Name: '" + $_.GetValue("DisplayName") + "' Version: '" + $_.GetValue("VersionMajor")+ "'"}
	return $resultAsStringArray
}

