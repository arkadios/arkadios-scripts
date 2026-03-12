# Write-Log function is a private initiative to enrich write-host with some styling and extra information like a timestamp. 
# From this point forward you can use write-log instead of write-host. 

# $global:WriteLogLogFileName = "";

function WriteToFile ([string]$WriteLogMessage) {
    $WriteLogMessage | Add-Content -Path "$WriteLogLogfileName" -Force
}

function WriteToScreenAndFileComplex ([string]$WriteLogMessage, [string]$WriteLogFGC, [string]$WriteLogBGC, [string]$WriteLogLogfileName) {
	
	if (-not [string]::IsNullOrEmpty($WriteLogMessage)) {
		$WriteLogMessage = $($(Get-Time) + " - " + $WriteLogMessage)
		Write-Host -F $WriteLogFGC -B $WriteLogBGC $WriteLogMessage
	}
	else {
		write-host ""
	}
	# write-output $WriteLogMessage
	WriteToFile $WriteLogMessage
}
 
function WriteToScreenAndFileSimple ([string[]]$WriteLogMessages, [bool]$IsError, [string]$WriteLogLogfileName, [string]$ForegroundColor, [string]$BackgroundColor) {

	$WriteLogFGC = $ForegroundColor
	$WriteLogBGC = $BackgroundColor
	If ($IsError) {
		$WriteLogFGC = "White"
		$WriteLogBGC = "Red"
	}
	foreach ($WriteLogMessage in $WriteLogMessages) {
		WriteToScreenAndFileComplex -WriteLogMessage $WriteLogMessage -WriteLogFGC $WriteLogFGC -WriteLogBGC $WriteLogBGC -WriteLogLogfileName $WriteLogLogfileName
	}
}

# $message = string that must be shown on screen and written to log
# $error as boolean = indicator wheater this message is an error
# Errors are shown as red
function Write-Log {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $False,
			ValueFromPipeline = $True,
			ValueFromPipelinebyPropertyName = $True,
			HelpMessage = "Provide a message as a string (array).")]
		[string[]]$Messages, 
		[alias("LFN")]
		[string]$LogFileName, 
		[alias("f")]
		[string]
		$ForegroundColor = "Cyan",
		[alias("b")]
		[string]
		$BackgroundColor = "Black",
		[bool]$IsError = $False,
		[switch]$IsVerbose
	)
	PROCESS {

		# this is tricky but we need to assume it will work. 
		# but in general this comes down to ... if a logfilename is provided, we will use that one for current session
		if($LogFileName){
			$global:LogFileNameProvided = $LogFileName;
		}
		elseif($global:LogFileNameProvided){
			$LogFileName = $global:LogFileNameProvided;
		}
		else{
			$LogFileName = "";
		}

		$LogFileNameToUse = Get-LogFile -LogNameProvided "$LogFileName"
		$errMessages = ""

		if ($IsVerbose -or $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
			foreach ($WriteLogMessage in $Messages) {

				if (-not [string]::IsNullOrEmpty($WriteLogMessage)) {
					$WriteLogMessage = $($(Get-Time) + " - " + $WriteLogMessage)
				}
				write-verbose $WriteLogMessage;
			}
		}
		else {
		

			if ($error.Count -gt 0 -or $IsError) {
				$errMessages = @();
				if ($IsError) {
					foreach ($Message in $Messages) {
						$errMessages += "[ERROR] $Message"
					}
				}
				if ($Error.Count -gt 0) {
					for ($i = 0; $i -lt $error.Count; $i++) {
						$errMessages += @($("[ERROR] (" + $i.ToString() + ") : " + $error[$i]).ToString())
					}
				}
		
				WriteToScreenAndFileSimple $errMessages $true $($LogFileNameToUse.Replace(".log", "-ERROR.log"))
				$error.clear()
			}
			else {
				WriteToScreenAndFileSimple $Messages $false $LogFileNameToUse $ForegroundColor $BackgroundColor
			}
		}

	}
}