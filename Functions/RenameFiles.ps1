<#

    examples: 
        - to remove a double prefix (that was created by mistake)
            RenameFiles -Items $(Get-ChildItem) -ReplaceHashTable @{"([0-9]{8}_[0-9]{6} )([0-9]{8}_[0-9]{6} [A-Za-z]+_[0-9])"=2;} -IsRegex:1 -WhatIf:0 -Verbose

            # VERBOSE:  (Regex) Match found for ([0-9]{8}_[0-9]{6} )([0-9]{8}_[0-9]{6} [A-Za-z]+_[0-9]), renaming to '20240501_133304 IMG_6088'
            # VERBOSE:  - Renaming to '20240501_133304 IMG_6088.jpg'
            # VERBOSE:  - Performing the operation "Rename File" on target "Item: D:\Fotos ZA 2024\160CANON\20240501_132212 20240501_132212 IMG_6084.jpg Destination: D:\Fotos ZA 2024\160CANON\20240501_132212 IMG_6084.jpg".
            # VERBOSE:  - Done renaming

        - 
#>


function ReplaceInItemname($fileToRenamePath, $oldValue, $newValue, $IsRegex) {
    $item = get-childitem -Path $fileToRenamePath
    if (-not $item) {
        Write-Warning " - No file found at path '$fileToRenamePath'. Skippin file."
        return
    }
    
    if ($IsRegex) {
        if ($item.BaseName -match $oldValue) {
            $newItemName = $item.BaseName -replace $oldValue, $Matches[$newValue]
            Write-Verbose " (Regex) Match found for $oldValue, renaming to '$newItemName'" 
            if (-not [string]::IsNullOrEmpty($newItemName)) {
                RenameItem $item.FullName -newItemName $newItemName -Prefix $Prefix;
            }
        }else {
            Write-Verbose " (Regex) Skipping '$($item.BaseName)' did not match '$oldValue'"
        }
    }
    else {   
        if ($item.BaseName -match "$oldValue") {
            $newItemName = $item.BaseName -replace $oldValue, $newValue
            Write-Verbose " (Non Regex) Match found for $oldValue, renaming to '$newItemName'" 
            if (-not [string]::IsNullOrEmpty($newItemName)) {
                RenameItem $item.FullName -newItemName $newItemName -Prefix $Prefix;
            }
        }else {
            Write-Verbose " (Non Regex) Skipping '$($item.BaseName)' did not match '$oldValue'"
        }
    }
}
function RenameItem($fileToRenamePath, $newItemName, $Prefix) {
    $item = get-childitem -Path $fileToRenamePath
    
    if ($Prefix -ne $null -and $Prefix.ToLower() -eq "LastWriteTime") {    
        $newNamePrefix = $item.LastWriteTime.ToString("yyyyMMdd_HHmmss") + $DefaulDevider
    }
    # elseif (-not [string]::IsNullOrEmpty($Prefix)) {
    #     $newNamePrefix = $Prefix + " "
    # }
    else {
        $newNamePrefix = $Prefix
    }

    # if no new item name is provided use old name
    if ([string]::IsNullOrEmpty($newItemName)) {
        $newItemName = $item.BaseName; 
    }
    
    $newName = $newNamePrefix + $newItemName + $($item.Extension)
    Write-Verbose -Message " - Renaming to '$newName'"
    
    Rename-Item -Path $fileToRenamePath -NewName $newName -WhatIf:$WhatIf
    write-verbose -Message " - Done renaming"
}
<#
.SYNOPSIS
Rename childitems

.DESCRIPTION
Long description

.PARAMETER Items
An array of childitems. Also accepted via pipeline

.PARAMETER Prefix
A prefix all files should get. 
Use 'LastWriteTime' to put the files LastWriteTime property value (+ space) in the title as prefix. 

.PARAMETER NewItemName
Give a generic name for all files

.PARAMETER ReplaceHashTable
A hashtable with key's and values to be replaced in filenames. Found key in name will be replaced by the value from the hashtable. Can be empty.
Powershell shell syntax = @{"key" = "value";}

.PARAMETER IsRegex
When this parameter is set, 'value' from Hashtable is position of in the Matches array. Meaning 'key' must be a grouped regex.

.PARAMETER WhatIf
WhatIf

.EXAMPLE
Get-ChildItem | RenameFiles -Prefix "LastWriteTime" -WhatIf:1

.NOTES

#>

function RenameFiles() {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline = $True, Mandatory = $True)]
        [object[]]$Items,
        [parameter(ValueFromPipeline = $False, Mandatory = $False, HelpMessage = "Give a generic name for all files. Use with dynamic prefix = LastWriteTime")]
        [string]$NewItemName,
        [parameter(ValueFromPipeline = $False, Mandatory = $False, HelpMessage = "Dynamic prefix = LastWriteTime, other just a string")]
        [string]$Prefix,
        [hashtable]$ReplaceHashTable, 
        [string]$DefaulDevider = "_",
        
        [parameter(ValueFromPipeline = $False, Mandatory = $False, HelpMessage = "When this parameter is set, 'value' from Hashtable is position of in the Matches array. Meaning 'key' must be a grouped regex.")]
        [bool]$IsRegex = $false,
        [bool]$WhatIf)

    begin {
        if ($ReplaceHashTable -eq $null -and [string]::IsNullOrEmpty($NewItemName)) {
            
            write-host -f Cyan " - If no prefix is provided all the files will be renamed to the same name! (meaning it will fail with second file)."
            write-host -f Cyan " - If prefix is provided, this value can be left empty, old BaseName will be used instead."
            write-host -f Cyan " - New filename will be " 
            write-host -f Magenta " >> '`$Prefix''New or Old name here'.ext <<"
            
            $NewItemName = Read-Host " - Give a generic name for all files"       
        }
    }
    process {

        if ($ReplaceHashTable -eq $null) { 
            $Items | ForEach-Object { 
                Write-Verbose " - Renaming item = '$_'"; 
                RenameItem -newItemName $NewItemName -fileToRenamePath $($_.FullName) -Prefix $Prefix;
            } 
        }

        if ($ReplaceHashTable -and $ReplaceHashTable.Count -gt 0) {
            foreach ($key in $ReplaceHashTable.Keys) { 
                $Items | ForEach-Object { ReplaceInItemname -fileToRenamePath $($_.FullName) -oldValue $key -newValue $ReplaceHashTable[$key] -IsRegex $IsRegex };
            }; 
        }
    }

    end {
        Write-Verbose " - The end."
    }
}



