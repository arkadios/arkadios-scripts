<#
    Script for the function that defines a log folder and or file and makes sure those are available.
#>

function CheckCreateArkadiosPSLogsFolder() {
<#
.SYNOPSIS
    Ensures the Arkadios PowerShell logs folder exists and is configured.

.DESCRIPTION
    Checks for the ArkadiosPSLogsFolder user environment variable. If not set,
    determines the appropriate drive (D: or system drive, avoiding Azure temp storage)
    and creates a logs\powershell folder. Stores the path in a user environment variable
    and returns it.
    This function is only supported on Windows.

.EXAMPLE
    $logsFolder = CheckCreateArkadiosPSLogsFolder
#>
	if ($PSVersionTable.PSEdition -ne 'Desktop' -and -not $IsWindows) {
		Write-Error "CheckCreateArkadiosPSLogsFolder is only supported on Windows (requires WMI and Windows drive paths)."
		return
	}

	if ([System.Environment]::GetEnvironmentVariable("ArkadiosPSLogsFolder", "USER") -eq $null) {
		$drive = ""
		# check if D drive exists first 
		if (-not (Test-Path "d:") ) { $drive = [System.Environment]::GetEnvironmentVariable("SYSTEMDRIVE") }
		else {
			# on azure machines the D drive is reserved for temporary storage
			# check if it is an azure machine 
			$azure = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer
			if ($azure -eq "Microsoft Corporation") { $drive = [System.Environment]::GetEnvironmentVariable("SYSTEMDRIVE") }
			else { 
				$drive = "d:" 
			}

		}

		$global:PSLogsFolder = "$drive\logs\powershell\"
		# check or create logs folder for scripts
		if (-not (Test-Path $global:PSLogsFolder)) { mkdir $global:PSLogsFolder -ErrorAction SilentlyContinue; }

		Write-Verbose " Created PSLogs folder"
		[System.Environment]::SetEnvironmentVariable("ArkadiosPSLogsFolder", $global:PSLogsFolder, "User")
	}
	else {
		$global:PSLogsFolder = [System.Environment]::GetEnvironmentVariable("ArkadiosPSLogsFolder","USER");
		Write-Verbose " Re-using (env var) PSLogs folder"
	}
	
	write-verbose " PSLogsFolder: ' $($global:PSLogsFolder) '"
	return $global:PSLogsFolder
}

function Get-LogFile{
<#
.SYNOPSIS
    Resolves or generates a log file path with date-stamped naming.

.DESCRIPTION
    Returns a full log file path. If no name is provided, generates one using the
    current date/hour. If a name is provided without a folder, uses the default
    Arkadios PS logs folder. Ensures the filename has a .log extension and a date
    component.

.PARAMETER LogNameProvided
    Optional log file name or full path. If empty, a default name is generated.

.EXAMPLE
    $logPath = Get-LogFile -LogNameProvided "MyScript"

.EXAMPLE
    $logPath = Get-LogFile
#>
    param([string]$LogNameProvided)
	$result = ""; 
	$folderOfTheLogFile = ""; 
	$fileNameOfTheLogFile = ""; 
	
	if ([string]::IsNullOrEmpty($LogNameProvided) ) {	

		# No name provided, we will create a new name
		$folderOfTheLogFile = CheckCreateArkadiosPSLogsFolder;


		# hier is geen naam opgegeven en is er nog geen global (standaard) naam eerder gedefinieerd (global is leeg). 
		# wij gaan hier een naam voor log definieren en die ook op global zetten
					
		$logName = $(Get-Date -Format yyyyMMdd-HH) + "-PS-ScriptLog.log"; 
		$result = "$folderOfTheLogFile\$logName";
		
	}
	else {
		# er is een naam opgegeven, die is leidend, dus global wordt gezet/overschreven
		
		# Check for folder
		if ($LogNameProvided.Contains(":") -or $LogNameProvided.Contains("\") -or $LogNameProvided.Contains("/")) {

			$folderOfTheLogFile = Split-Path $LogNameProvided -Parent;
			$fileNameOfTheLogFile = Split-Path $LogNameProvided -Leaf;

		}
		else {
			# No folder provided, we will use the default folder
			$folderOfTheLogFile = CheckCreateArkadiosPSLogsFolder
			$fileNameOfTheLogFile = $LogNameProvided;
		}

		# Check for extention
		if ($fileNameOfTheLogFile.EndsWith(".log")) {
			$fileNameOfTheLogFile = $fileNameOfTheLogFile;
		}
		else {
			$fileNameOfTheLogFile = "$fileNameOfTheLogFile.log";
		}
		
		# Check for date time presence
		$matchDatum = $fileNameOfTheLogFile -match "(\d{2}-\d{2}-\d{4})";
		$matchDate = $fileNameOfTheLogFile -match "(\d{4}-\d{2}-\d{2})";
		$matchDate2 = $fileNameOfTheLogFile -match "(\d{8})";

		# If no date time is present, we will add it
		if (-not ($matchDatum -or $matchDate -or $matchDate2)) {
			$fileNameOfTheLogFile = $(Get-Date -Format yyyyMMdd-HH) + "-" + $fileNameOfTheLogFile;
		}

		# complete result 
		$result = "$folderOfTheLogFile\$fileNameOfTheLogFile";
	}	
	return $result;
}
