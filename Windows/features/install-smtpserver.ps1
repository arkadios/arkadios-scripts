

Import-Module ServerManager 

$Networkip = @()
$Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName localhost | ? { $_.IPEnabled }
foreach ($Network in $Networks) { $Networkip = $Network.IpAddress[0] }


function InstallSMTP() {
    # Check if SMTP is installed before installing it.
    $smtp = get-WindowsFeature "smtp-server"
    if (!$smtp.Installed) {
        write-host "SMTP is not installed, installing it..." -ForegroundColor Yellow
        add-WindowsFeature $smtp
    }
    else {
        write-host "SMTP is already installed!" -ForegroundColor Green
        sleep 2
    }
}

InstallSMTP



$connectionips = read-host "Provide connection ip (format 10.10.10.10)"
# $connectionips = "10.10.10.10"      


function ConfigureSMTP() {

    #

} 

function ConfigAuthAndRelay() {
    $ipblock = @(24, 0, 0, 128,
        32, 0, 0, 128,
        60, 0, 0, 128,
        68, 0, 0, 128,
        1, 0, 0, 0,
        76, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        1, 0, 0, 0,
        0, 0, 0, 0,
        2, 0, 0, 0,
        1, 0, 0, 0,
        4, 0, 0, 0,
        0, 0, 0, 0,
        76, 0, 0, 128,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        255, 255, 255, 255)

    $ipList = @()
    $octet = @()
    $ipList = "127.0.0.1"
    $octet += $ipList.Split(".")
    $octet += $Networkip.Split(".")

    $ipblock[36] += 2 
    $ipblock[44] += 2;
    $smtpserversetting = get-wmiobject -namespace root\MicrosoftIISv2 -computername localhost -Query "Select * from IIsSmtpServerSetting"
    $ipblock += $octet
    $smtpserversetting.AuthAnonymous = 1
    $smtpserversetting.AuthBasic = 0
    $smtpserversetting.RelayIpList = $ipblock
    $smtpserversetting.put()
}

function AddConnections() {

    $checkArray = $connectionips.split(",") 
    if ($checkArray -notcontains $Networkip) {
        $connectionips += "," + $Networkip
    }

    $connectionipbuild = @()
    $ipArray = $connectionips.split(",")
    foreach ($ip in $ipArray) {   
        $connectionipbuild += $ip + ",255.255.255.255;"     
    }
    $bindingFlags = [Reflection.BindingFlags] "Public, Instance, GetProperty"

    $iisObject = new-object System.DirectoryServices.DirectoryEntry("IIS://localhost/SmtpSvc/1")
    $ipSec = $iisObject.Properties["IPSecurity"].Value

    # We need to pass values as one element object arrays
    [Object[]] $grantByDefault = @()
    $grantByDefault += , $false            # <<< We're setting it to false

    $ipSec.GetType().InvokeMember("GrantByDefault", $bindingFlags, $null, $ipSec, $grantByDefault);

    $iisObject.Properties["IPSecurity"].Value = $ipSec
    $iisObject.CommitChanges()

    $iisObject = new-object System.DirectoryServices.DirectoryEntry("IIS://localhost/SmtpSvc/1")
    $ipSec = $iisObject.Properties["IPSecurity"].Value
    $isGrantByDefault = $ipSec.GetType().InvokeMember("GrantByDefault", $bindingFlags, $null, $ipSec, $null);

    # to set an iplist we need to get it first
    if ($isGrantByDefault) {
        $ipList = $ipSec.GetType().InvokeMember("IPDeny", $bindingFlags, $null, $ipSec, $null);
    }
    else {
        $ipList = $ipSec.GetType().InvokeMember("IPGrant", $bindingFlags, $null, $ipSec, $null);
    }

    # Add a single computer to the list:
    $ipList = $ipList + $connectionipbuild

    # This is important, we need to pass an object array of one element containing our ipList array
    [Object[]] $ipArray = @()
    $ipArray += , $ipList

    # Now update
    $bindingFlags = [Reflection.BindingFlags] "Public, Instance, SetProperty"
    if ($isGrantByDefault) {
        $ipList = $ipSec.GetType().InvokeMember("IPDeny", $bindingFlags, $null, $ipSec, $ipArray);
    }
    else {
        $ipList = $ipSec.GetType().InvokeMember("IPGrant", $bindingFlags, $null, $ipSec, $ipArray);
    }

    $iisObject.Properties["IPSecurity"].Value = $ipSec
    $iisObject.CommitChanges()
}