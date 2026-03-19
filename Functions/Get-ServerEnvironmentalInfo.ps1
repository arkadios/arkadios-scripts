# General server related functions

function Get-ServerEnvironmentalInfo([string]$ServerName){
<#
.SYNOPSIS
    Retrieves server environment information from a SharePoint list.

.DESCRIPTION
    Connects to a SharePoint site and queries a server information list to retrieve
    details such as SharePoint version, environment (OTAP), farm name, and farm role
    for the specified server. Requires SharePoint to be installed on the local machine.

.PARAMETER ServerName
    The name of the server to look up.

.EXAMPLE
    Get-ServerEnvironmentalInfo -ServerName "SERVER01"
#>
	if ($PSVersionTable.PSEdition -ne 'Desktop' -and -not $IsWindows) {
		Write-Error "Get-ServerEnvironmentalInfo is only supported on Windows (requires SharePoint)."
		return
	}

	# get the sharepoint list item for current server
	$serverInfo = New-Object -TypeName PSObject
	$serverInfo | Add-Member -MemberType NoteProperty -Name ServerName -Value $ServerName
	$serverInfo | Add-Member -MemberType NoteProperty -Name Version -Value ""
	$serverInfo | Add-Member -MemberType NoteProperty -Name Platform -Value ""
	$serverInfo | Add-Member -MemberType NoteProperty -Name Environment -Value ""
	$serverInfo | Add-Member -MemberType NoteProperty -Name Farm -Value ""
	$serverInfo | Add-Member -MemberType NoteProperty -Name IP -Value ""
	$serverInfo | Add-Member -MemberType NoteProperty -Name FarmRole -Value ""
	
	# asuming that we are on a server with SharePoint installed... 
	if($(IsSharePointInstalled)) 
	{
		write-log "SharePoint is installed. Connecting to '$SERVERINFORMATIONLISTSITEURL'... "
		$subSite = Get-SPWeb $SERVERINFORMATIONLISTSITEURL
		$serverInfoList = $subSite.TryGetList($SERVERINFORMATIONLISTNAME)
		
		if($serverInfoList)
		{
			write-log "Server information list '$SERVERINFORMATIONLISTNAME' found!"
			# list found, lets get the info	
			# FindListItem($List, $FieldNameRef, $FieldValue, $FieldType)

			$serverInfoItem = FindListItem $serverInfoList Title $ServerName "Text"
			
			if($serverInfoItem)
			{
				
				# item with information found 
				$serverInfo.Version = $serverInfoItem["Versie SharePoint"] # 2010/2013/2016 op moment van schrijven
				$serverInfo.Environment = $serverInfoItem["OTAP"] # TEST,Productie, Acceptatie
				$serverInfo.Farm = $serverInfoItem["Farm"] # U3, S1, etc
				$serverInfo.FarmRole = "APP/WFE/FSTINDEX"
				
				write-log "Collected information: "
				$serverInfo
			}
		}
	}
	else
	{
		Write-Log "SharePoint not installed. Unable to connect to '$SERVERINFORMATIONLISTSITEURL'." -IsError $true
	}
	
}