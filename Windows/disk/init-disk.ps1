
################################################################
#
# Author:   A. Fedorov 
# Date:     2020-03-25
# Summary:  This script will initiate all disks that are available
#           but not yet initated in Windows. Also will it create
#           new partition and volume @ maximumsize of the disk 
#
################################################################

# -------- PARAMETERS --------
param(
    [PARAMETER(Mandatory=$true,
    HelpMessage="Enter one or more computer names separated by commas.")]
    [string[]]$ServerNames
)
# Scriptname en tag verzinnen!
$scriptname = 'init-disk'
if ($scriptname -eq 'template') {
    write-host -f RED "You didn't create a scriptname!"
    EXIT
}

# -------- HEADER --------
$startTimeStartSPScript = get-date
write-host "Script started at:" $startTimeStartSPScript

# -------- MAIN --------

$command = "Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel '' -Confirm:`$false"


try {
    # execute your code here
    write-host -f cyan "-------------------------------------------------";
	
    write-host -f cyan "Executing on remote servers: '$command' ";


    if (!$cred) { $cred = Get-Credential }

    $ServerNames | % {
        $serverName = $_;
        write-host -f white "---------------- Configuring '$serverName'";

        Invoke-Command -ScriptBlock { param($command); invoke-expression -command $command; write-host -f green "[$($ENV:COMPUTERNAME)] Done here, returning." } -ComputerName $serverName -Credential $cred -Verbose -ArgumentList $command
        Start-Sleep -Seconds 10; 
        write-host  -f white "---------------- Done configuring '$serverName'";
    }


	
    write-host -f cyan "-------------------------------------------------";
	
}
catch {
    write-host " "
    write-host " -----------" 
    write-host " | ERROR! |"
    write-host " [ERROR] = '$_' "
    write-host " -----------"
    write-host " "
}

$endTimeStartSPScript = $(Get-Date) - $startTimeStartSPScript 
write-host -f cyan "-------------------------------------------------";
write-host "Time taken:" 
write-host "Seconds: $($endTimeStartSPScript.TotalSeconds)"
write-host "Minutes: $($endTimeStartSPScript.Minutes)"
write-host "Hours: $($endTimeStartSPScript.Hours)"
write-host -f cyan "-------------------------------------------------";
write-host -f cyan "-------------------------------------------------";
write-host -f cyan "-------------------------------------------------";
write-host -f cyan "-------------------------------------------------";


# -------- FOOTER --------
write-host "Script ended at:" $(Get-Date)
