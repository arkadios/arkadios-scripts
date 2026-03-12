param([bool]$Force = $false, [bool]$WhatIf = $false)

# if(! ($DEPLOYMENTSERVER)) { ."D:\\\00_COMMON\00_VARIABELEN.ps1" }

# if (! (test-path function:Write-Log)) {.'$COMMONSCRIPTS\10_FUNC_Write-Log.ps1'}
# if (! (test-path function:DoesPropertyExists)) {.'$COMMONSCRIPTS\10_FUNC_DoesPropertyExists.ps1'}

$Error.Clear()

Write-Host -ForegroundColor Cyan "-----------------------------------------------------------------"
Write-Host -ForegroundColor Cyan "Script for configuration of shares for shared folders!"
Write-Host -ForegroundColor Cyan "-----------------------------------------------------------------"
Write-Host
if ($WhatIf) { Write-Host -ForegroundColor yellow "WhatIf = True. No changes wil be committed." }


$foldersToCheckOrCreate = @()

$sharesToCreate = @{
    "Config"        = "D:\Config";
    "Scripts"       = "D:\Scripts";
    "CruiseControl" = "D:\CruiseControl";
    "Logs"          = "D:\Logs"
	"Install"		= "D:\Install"
}

$htLogFilesGroupsPermissions = @{
    "$($env:USERDOMAIN)\Users"  = "ReadAndExecute, Write";
    "$($env:USERDOMAIN)\Administrator" = "FullControl"
}

function ConfigureAcl($folderPath, $htUsersAndGroupsPermissions, $WhatIf) {

    $Acl = (Get-Item $folderPath).GetAccessControl([System.Security.AccessControl.AccessControlSections]::Access)
    if ($Acl) {
        foreach ($userPN in $htUsersAndGroupsPermissions.Keys) {
            $userName = $userPN
            $effectivePermission = $htUsersAndGroupsPermissions[$userPN];
            Write-Host "  Setting following acl permissions : '$userName', '$effectivePermission','ContainerInherit,ObjectInherit', 'None', 'Allow'"
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($userName, $effectivePermission, 'ContainerInherit,ObjectInherit', 'None', 'Allow')
            $Acl.SetAccessRule($accessRule)

        }
		
        Write-Host "  Committing changes (WhatIf = $WhatIf)..."
        Set-Acl -path $folderPath -AclObject $Acl -WhatIf:$WhatIf
        Write-Host "  DONE!"
    }
    else {
        Write-Host "  Could not find ACL for folder '$folderPath'" 
    }

}

function ResetFolderPermissions($folderPath, $htUsersAndGroupsPermissions, $WhatIf) {

    Write-Host "  Setting permissions for folder : '$folderPath'" 
    ConfigureAcl $folderPath $htUsersAndGroupsPermissions $WhatIf

}

function GetShare($folderpath) {
    $allShares = Get-SmbShare 
    $aShare = $allShares | where { $_.Path -like $folderpath }
	
    if ($aShare) { return $true; }
    else { return $false; }
}

function CreateShare([string] $shareName, [string]$folderpath, [bool]$Force, [bool]$WhatIf) {

    if ($(GetShare $folderpath) -and $Force) {

        Write-Host -ForegroundColor yellow " Share exists and Force is used! Removing share first. Some settings might get lost! (WhatIf = $WhatIf)"
        try {
            $shareToRemove = Get-SmbShare | where { $_.Path -like $folderpath }
            Remove-SmbShare -InputObject $shareToRemove -Confirm:0 -WhatIf:$WhatIf -Force:$Force
        }
        catch {	
            Write-Host " Failed to remove share!" 
        }

    }

    Write-Host " Creating share with name '$shareName' and path '$folderPath'... "
    try {
        if (-not $(GetShare $folderpath)) {
            #	Write-Host " Creating share with name '$shareName' and path '$folderPath'... "
            try {
                if (-not $(GetShare $folderpath)) {
                    New-SmbShare -Path $folderpath -Name $shareName -ReadAccess "$($env:USERDOMAIN)\Users" -FullAccess "$($env:USERDOMAIN)\Administrator"
                }
                else {
                    Write-Host -ForegroundColor yellow " No share created, because there is already a share for this path and (Force = False)  "
                }
            }
            catch {	
                Write-Host "Failed to create share!" 
                throw "Failed to create share!"
            }
        }
    }
    catch { }
}


function UpdateToDesiredState($force, $WhatIf) {
    $updateNecessery = $false
    # enumerating all defined propeties 
	
    #folder check 
    foreach( $folder in $sharesToCreate.Values )
    {
		if(-not $(Test-Path $folder) -and -not $Force){
		Write-Host -ForegroundColor Yellow "Path '$folder' not found! Need creation!"
		$updateNecessery = $true
		}
		else
		{
			Write-Host -ForegroundColor Green "Folder already exists!"
		}
		
    # # if not whatif, commiting all changes to the farm
    if($updateNecessery -or $Force){
			
    Write-Host -ForegroundColor yellow "(Re)Creating folder (Force = $Force) (WhatIf = $WhatIf)... "
    New-Item -Path $folder -ItemType Directory -Force:$Force -WhatIf:$WhatIf -ErrorAction SilentlyContinue
		
    Write-Host -ForegroundColor yellow "(Re)Setting folder permissions (Force = $Force) (WhatIf = $WhatIf)..."
    ResetFolderPermissions $folder $htLogFilesGroupsPermissions $WhatIf

    }
     else
     {
     Write-Host -ForegroundColor green "Everything seems fine! No changes required!"
     }
     }

    #share check
    write-host ------------------------------
    write-host Creating shares 
    write-host $($sharesToCreate | out-string)
    write-host ------------------------------

    foreach ( $shareName in $sharesToCreate.Keys ) {

        $sharePath = $sharesToCreate[$shareName]
        $createNewShare = $false

        if ($(GetShare $sharePath)) {
            Write-Host -ForegroundColor green "Share exists '$shareName' !"
        }
        else {
            Write-Host -ForegroundColor Yellow "No share exists! Need creation!"
            $createNewShare = $true
        }
			
        if ($createNewShare -or $force) {

            Write-Host -ForegroundColor yellow "(Re)Creating share (Force = $Force)(WhatIf = $WhatIf)... "
            try {
                CreateShare $shareName $sharePath $force $WhatIf
                Write-Host -ForegroundColor green "Folder and share (re)created! (Force = $Force)(WhatIf = $WhatIf)"
            }
            catch {
                Write-Host "Failed to create share for '$shareName = $sharePath'!" 
            }

            Write-Host -ForegroundColor yellow "(Re)Setting folder permissions (Force = $Force) (WhatIf = $WhatIf)..."
            ResetFolderPermissions $sharePath $htLogFilesGroupsPermissions $WhatIf

        }
		


    }
}

function CheckCurrentState() {
    # not implemented
}


Write-Host 
Write-Host -f cyan "Updating configuration to desired state"

UpdateToDesiredState $Force $WhatIf

Write-Host -f cyan "DONE!"
Write-Host "";