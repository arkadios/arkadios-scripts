# functions

function AddValue2Item {
    param ( [string] $sItemPath, [string] $sItemValue )

    $sCurValue = (get-item $sItemPath).value

    if (-not $sCurValue.Contains($sItemValue)) {
        "Adding $($sItemValue) to $($sItemPath)"
        if ($sCurValue -ne "") { $sCurValue += ", " }
        set-item $sItemPath -value "$($sCurValue)$($sItemValue)" -Force
    }
} 

# Start of code
$sAdminPCs = read-host "Please provide administrative computernames (non-fqdn names like dev-dc-01)"
$bIsServer = $true
foreach ($sAdminPC in $sAdminPCs) {
    if ($sAdminPC.ToUpper().Contains($env:computername)) { $bIsServer = $false } else { $bIsServer = $true }
}
# Check if 
$asResults = Get-WSManCredSSP
if ($asResults[0].Contains("not configured")) {
    if ($bIsServer) { 
        "Enabled server role"
        Enable-PSRemoting 
        Enable-WSManCredSSP -Role Server
    }
    else { 
        "Enabled client role"
        Enable-PSRemoting -Force
        Enable-WSManCredSSP -Role Client -DelegateComputer * -force
    }
}

$sPath = "wsman:\localhost\Client\TrustedHosts"
foreach ($sAdminPC in $sAdminPCs) {
    # Step 1 Add Admin PC to be trusted 
    AddValue2Item $sPath $sAdminPC
}
#get-item $sPath




<#
examples 

$oCred=Get-Credential

cls
$codeGetServerName={ $env:computername; }
invoke-command -computer $asServers -credential $oCred -scriptblock $codeGetServerName 

cls
$codeGetServerName={ $env:computername; }
invoke-command -computer $asServers -credential $oCred -scriptblock $codeGetServerName -authentication CredSSP

cls
$codeGetServerName={ Add-PsSnapin Microsoft.SharePoint.PowerShell; $env:computername; (get-spsite -limit all).count }
invoke-command -computer $asServers -credential $oCred -scriptblock $codeGetServerName -authentication CredSSP

cls
$codeGetServerName={ Add-PsSnapin Microsoft.SharePoint.PowerShell; $env:computername; (get-spsite -limit all).count }
invoke-command -computer $asServers -credential $oCred -scriptblock $codeGetServerName -authentication CredSSP

cls
$codeGetServerName={ Add-PsSnapin Microsoft.SharePoint.PowerShell; $env:computername; (get-spsite -limit all).count }
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters' -name "AllowEncryptionOracle" 2 -Type DWord
invoke-command -computer $asServers -credential $oCred -scriptblock $codeGetServerName -authentication CredSSP
Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters' -name "AllowEncryptionOracle"


cls
$codeSetup=[scriptblock]::Create((Get-Content "C:\scripts_$domainName_DevOps\IIS\Deployment\SetupWebSiteBull.ps1" -encoding utf8 -raw))
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters' -name "AllowEncryptionOracle" 2 -Type DWord
invoke-command -computer $asServers -credential $oCred -scriptblock $codeSetup -authentication CredSSP
Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters' -name "AllowEncryptionOracle"

cls
$codeTestScrip=[scriptblock]::Create((Get-Content "C:\scripts\testscript.ps1" -encoding utf8 -raw))
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters' -name "AllowEncryptionOracle" 2 -Type DWord
invoke-command -computer $asServers -credential $oCred -scriptblock $codeTestScrip -authentication CredSSP
Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters' -name "AllowEncryptionOracle"


#>