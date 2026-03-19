function Copy-Items {
<#
.SYNOPSIS
    Copies one or more items to a destination path.

.DESCRIPTION
    Accepts child items via pipeline or prompts for a source path, then copies
    them to the specified destination. Displays a confirmation prompt before
    copying unless Autoconfirm is set to $true. Logs progress using Write-Log.

.PARAMETER SourceChildItems
    An array of child items to copy. Accepts pipeline input.

.PARAMETER Destination
    The destination path to copy items to. Prompted if not provided.

.PARAMETER Autoconfirm
    When $true, skips the confirmation prompt. Defaults to $false.

.EXAMPLE
    Get-ChildItem "C:\Source" | Copy-Items -Destination "D:\Backup"

.EXAMPLE
    Copy-Items -SourceChildItems (Get-ChildItem *.txt) -Destination "C:\Archive" -Autoconfirm $true
#>
    param (
		[Parameter(
			Mandatory=$False,
			ValueFromPipeline=$True,
			ValueFromPipelinebyPropertyName=$True,
			HelpMessage="Provide a childitem as source")]
        [Object[]]$SourceChildItems,
        [string]$Destination,
        [bool]$Autoconfirm = $false
    )
    begin{
        $sourceFilePaths = @()
        Write-Log -LogFileName "Copy-Items" -Messages "Copy-Items start ..."
    }
    process{
        if(-not $SourceChildItems -and $SourceChildItems.Count -le 0){
            $sourcePathAsInput = read-host "Source path to file or folder (or pipe childitems to here)"
            $sourceFilePaths += $sourcePathAsInput
        }
        else{
            $sourceFilePaths = $SourceChildItems
        }

    
        if(-not $Destination){$destinationFilePath = Read-Host "Destination "}
        else {$destinationFilePath = $Destination}
        
        write-log "About to copy '$($sourceFilePaths.Count)' items "
        write-log "to '$destinationFilePath'"
        if(-not $Autoconfirm) { read-host "Continue (enter/ctrl-c)" }
        if($sourceFilePaths -and $sourceFilePaths.Count -gt 0){
            foreach($sourceFilePath in $sourceFilePaths){
                # write-log "Copying from '$($sourceFilePath)' to '$destinationFilePath'"
                # xcopy "$($sourceFilePath)" "$destinationFilePath" /O /X /E /H /K /I
                copy-item "$($sourceFilePath)" "$destinationFilePath" -Recurse #-UseTransaction
                # write-log "Done"
            }
        }
    }
    end{
        write-log "Copy-Items end." -ForegroundColor green
    }

}
