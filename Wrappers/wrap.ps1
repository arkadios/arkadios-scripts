<#------------------------------------------------------------------------------------------------------------------------------------

Description: 	This is wrapper for other powershell script to be able to have control over other script execution. 
				Here we controle the pre and the post fase of script execution.

Author: 	A.B. Fedorov
Date: 		25-05-2019
Version: 	v3

Releasenotes: 
cv3.1   Admin and security checks added. 
v3		Refactored and revised version of the script for more general use 
		and use with modules
v2		Script will call and run methods from inserted script. 
		param($ScriptToExecute) in use 
		$ScriptToExecute = Full File Path of the script that needs to be executed. That script must have only functions and not run anything on its own. 

v1		Initial release / version with some general stuff

IMPORTANT: 

HOW TO USE THIS SCRIPT: 
EXAMPLE 1 :
#TODO Example needed
#TODO Tree view of design of this script

------------------------------------------------------------------------------------------------------------------------------------#>

# Function is responsible for launching a new instance of powershell with correct parameters for the target machine/environment. 
function LaunchValidPowershellInstance($scriptBlockToExecuteInStartSPScript, [bool]$noSnapin = $true) {
    # this function will reload this script with current parameters
    write-log " Starting new elevated instance of Powershell..."
    [string[]]$argList = @()
    if ($(IsSharePointInstalled "2010")) { $argList += "-Version 2.0" }
    $argList += "-Command `"wrap -IsElevatedInstance:1 -ScriptBlockToExecute { $scriptBlockToExecuteInStartSPScript;}"
    if ($noSnapin) { $argList += "-NoSnapIn`"" } else { $argList += "`"" }
    write-log " Start-Process PowerShell.exe -verb runas -PassThru:1 -Wait:1 -ArgumentList `"$argList`""
    $newProc = Start-Process PowerShell.exe -verb runas -PassThru:1 -Wait:1 -ArgumentList $argList 
    $newProc | Format-List
    Start-Sleep 5 # Exit from the current, unelevated, process
    write-log -f cyan "Exiting this instance ... Bye Bye."
    exit 0
}

# no used yet
function SecurityProtocols(){
    $securityProtocol=@();
    $securityProtocol+=[Net.ServicePointManager]::SecurityProtocol;
    $securityProtocol+=[Net.SecurityProtocolType]::Tls12;

    [Net.ServicePointManager]::SecurityProtocol=$securityProtocol;                
}

# not used yet
function CheckPSVersion(){
    If($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0"))){ throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." };
}


function wrap {
    param(
        [bool]$IsElevatedInstance = $true,
        [Parameter(
            Mandatory = $False,
            ValueFromPipeline = $True,
            ValueFromPipelinebyPropertyName = $True)]
        [string]$ScriptToExecute, 
        [scriptblock]$ScriptBlockToExecute,
        [bool]$NoSnapIn = $true
    ) 
    begin {
        #------ Lets start clean -----
        Clear-Host
        $Error.Clear()

			
        #------ VARIABLE DEFINITION AND LOADING ------
        $LOGFOLDER = "D:\logs\scripts"
        If (-not $(get-module arkadios.core)) { install-module arkadios.core; }
        if ($(test-path $LOGFOLDER) -eq $false) { new-item $LOGFOLDER -type Directory; }
        [scriptblock]$scriptBlockToExecuteInStartSPScript = $null
        [string]$scriptToExecuteName = ""
        $DTSTAMPSCRIPTCALL = $(get-date -f "yyyyMMdd_HHmmss")

        # This function creates a scriptblok from a single line of code. 
        # This is done to normalize the execution of the code later
        # transform simple (string) input to a scriptblok
        if ($ScriptToExecute) { $scriptBlockToExecuteInStartSPScript = [scriptblock]::Create("$ScriptToExecute") } 
        if ($ScriptBlockToExecute) { $scriptBlockToExecuteInStartSPScript = $ScriptBlockToExecute }
		
        # ScriptBlockToExecute should not be empty
        if (-not [STRING]::IsNullOrEmpty($scriptBlockToExecuteInStartSPScript)) {
            $lastIndexOfPs1 = $scriptBlockToExecuteInStartSPScript.ToString().ToLower().LastIndexOf(".ps1")
            if ($lastIndexOfPs1 -gt 0) {
                $removeFromIndex = $($scriptBlockToExecuteInStartSPScript.ToString().Substring(0, $lastIndexOfPs1).LastIndexOf('\') + 1)
                $scriptToExecuteName = $scriptBlockToExecuteInStartSPScript.ToString().SubString($removeFromIndex, $($lastIndexOfPs1 - $removeFromIndex))
            }
            else {	$scriptToExecuteName = "custom_ps_command"; }
			
        }
		
        if (-not $IsElevatedInstance) {
            # write-log -f cyan " Starting elevated instance of PowerShell..."
            LaunchValidPowershellInstance -scriptBlockToExecuteInStartSPScript $scriptBlockToExecuteInStartSPScript -noSnapin $NoSnapIn
        }
		
        Add-ComputerAsTrustedLocation $ENV:COMPUTERNAME

        # Following is responsible for creation of the logfile. 
        # The name of the file is automatically determined
        $Global:WriteLogLogFileName = $dtStampScriptCall + "_" + $scriptToExecuteName + ".log"
        $LOGFFN = $LOGFOLDER + "\" + $Global:WriteLogLogFileName

        if (-not $scriptBlockToExecuteInStartSPScript) {
            write-log -f red " [ERROR] Required parameters are empty! -ScriptToExecute [string] or -ScriptBlockToExecute [scriptblock] must be provided! Script aborted, exiting in 10 seconds!"
            Start-Sleep 20
            Exit 9998
        }
		
        $startTimeStartSPScript = Get-Date
        write-log " " -LogFileName $Global:WriteLogLogFileName
        write-log "----------------"
        write-log "| INITIALIZED  |"
        write-log "----------------"
        write-log " "
        write-log "Script root: '$PSScriptRoot' "
        write-log "Log file location: '$LOGFFN'"
        write-log " "
    }	
    process {
        #------ MAIN ------
        write-log " "
        write-log " --------------------"
        write-log " | EXECUTING SCRIPT | "
        write-log " --------------------"
        write-log " "

	
        try {
            write-log " $scriptBlockToExecuteInStartSPScript"
            write-log $("--------------------")
		
            Invoke-Command -Scriptblock $scriptBlockToExecuteInStartSPScript
		
            write-log $("--------------------")
		
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            $customExitCode = $_.Exception.HResult

            write-log " "
            write-log " -----------" $TRUE
            write-log " | FAILED! |" $TRUE
            write-log " -----------" $TRUE
            write-log " "
		
            write-log " ERROR: Message: $ErrorMessage, exitcode/hresult: $customExitCode" -IsError:1
				
            break;
        }
        
        
        write-log " "
        write-log " ---------"
        write-log " | DONE! |"
        write-log " ---------"
        write-log " "

    }
    end {
        #------ FOOTER / FINISH ------
        write-log ""
        write-log "Ending script execution... "
		
        $endTimeStartSPScript = $(Get-Date) - $startTimeStartSPScript 
        write-log "Time taken:" 
        write-log "Seconds: $($endTimeStartSPScript.TotalSeconds)"
        write-log "Minutes: $($endTimeStartSPScript.Minutes)"
        write-log "Hours: $($endTimeStartSPScript.Hours)"
        write-log ""
		
        $errorCount = $error.count
		
        if ($errorCount -gt 0) {
            write-log "---------------------------------------------------------------------"
            write-log -f yellow $("Number of errors collected: '" + $errorCount + "'")

            $i = 0; 
            write-log -f red "Error messages are: "
            foreach ($err in $error) {
                $message = $null
                $message = $err.Exception.Message
                write-log -f red "Error $i = $message"
                $i++
            }
        }
        $timer = 5
        write-log -f yellow "End of script. Window will close in $timer seconds "
        while ($timer -ne 0) {
            # write-log . -NoNewLine
            Start-Sleep 1
            $timer--
        }
		
        $error.clear()
            
    }
}