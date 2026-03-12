################################################################
#
# Author: A. Fedorov
# Date: 2020-07-10
# Description: This script changes Logon As account of a Windows service 
# 
################################################################

param([Parameter(Mandatory = $true)][string]$sServiceName, 
    [Parameter(Mandatory = $true)][string]$sComputerName, 
    [Parameter(Mandatory = $true)][string]$sUsername, 
    [Parameter(Mandatory = $true)][string]$sPassword
) 

write-host -f darkcyan " - Finding service '$sServiceName'" -NoNewline
$oService = Get-WmiObject -ComputerName $sComputerName -Query "SELECT * FROM Win32_Service WHERE Name = '$sServiceName'"
if ($oService) {
    write-host -f green " found!"
    write-host -f darkcyan "  - Changing account to '$sUsername'" 
    $oService.Change($null, $null, $null, $null, $null, $null, "$sUsername", $sPassword) | Out-Null
    
    write-host -f darkcyan "  - Stopping" 
    $oService.StopService() | Out-Null
    sleep 3
    while ($oService.Started) {
        sleep 1
        $oService = Get-WmiObject -ComputerName $sComputerName -Query "SELECT * FROM Win32_Service WHERE Name = '$sServiceName'"
    }##endwhile

    write-host -f darkcyan "  - Starting" 
    $oService.StartService() | Out-Null

    while (!$oService.Started) {
        sleep 1
        $oService = Get-WmiObject -ComputerName $sComputerName -Query "SELECT * FROM Win32_Service WHERE Name = '$sServiceName'"
    }##endwhile
    write-host -f darkcyan "  - $($oService.State)"
}
else {
    write-host -f red " not found!"
}
write-host -f green " Done."
