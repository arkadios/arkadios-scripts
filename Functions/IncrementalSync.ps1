function IncrementalSync($Source, $Destination){
<#
.SYNOPSIS
    Performs an incremental file sync from source to destination using xcopy.

.DESCRIPTION
    Uses xcopy with /c /s /e /r /h /d /y /x flags to incrementally copy only
    newer or changed files from the source path to the destination path.

.PARAMETER Source
    The source folder path to sync from.

.PARAMETER Destination
    The destination folder path to sync to.

.EXAMPLE
    IncrementalSync -Source "C:\Data" -Destination "D:\Backup"
#>
	write-log -f cyan "Starting incremental sync process"," for: '$Source'"," to '$Destination'" 
	xcopy $Source $Destination /c /s /e /r /h /d /y /x
	$Dt = Get-Date
	write-log -f cyan "Incremental sync process has completed at $Dt" 
}
