[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [STRING[]]
    $scriptFilesToExecute,
    [Parameter(Mandatory=$false)]
    [STRING]
    $RunAsAccount,
    [Parameter(Mandatory=$false)]
    [STRING]
    $RunAsAccPwd    
)

# $scriptFilesToExecute = @("D:\Scripts\sp\nintex\start-install.ps1", "D:\Scripts\sp\metalogix\start-install.ps1")
Remove-Module PSReadline

foreach($scriptFileToExecute in $scriptFilesToExecute){

    if($RunAsAccount){
        $RunAsAccount = $RunAsAccount    
        $RunAsAccountPWD = $RunAsAccPwd
    }else{
        $RunAsAccount = "$domainName0\svc_spfarm"
        $RunAsAccountPWD = ""
    }
    $secPassword = ConvertTo-SecureString "$RunAsAccountPWD" -AsPlaintext -Force
    
    $runAsCredential = New-Object System.Management.Automation.PsCredential $RunAsAccount,$secPassword
    
    if($runAsCredential){
        write-host -f cyan " Trying to execute '$scriptFileToExecute' as '$RunAsAccount'"
        # Run our Add-SPProfileSyncConnection script as the Farm Account - doesn't seem to work otherwise

	$elevatedCommnd = "write-host -f yellow `" starting elevated instance as `$(`$ENV:USERNAME)`"; Start-Process -WorkingDirectory ```"$PSHOME```" -FilePath ```"powershell.exe```" -ArgumentList ```"-ExecutionPolicy Bypass '$script'```" -Verb Runas" 

        Start-Process -WorkingDirectory $PSHOME -FilePath "powershell.exe" -Credential $runAsCredential -ArgumentList "-ExecutionPolicy Bypass -Command ``$elevatedCommnd " -Wait

	write-host -f cyan " Done."
    }
    else {
        write-host -f yellow " Unable to create credential obj for '$RunAsAccount' "
        write-host -f Yellow " Please check account, password and double hop issue (dont execute this script remotelly)."
        write-host -f Yellow " Nothing executed."
    }
}

Import-Module PSReadline