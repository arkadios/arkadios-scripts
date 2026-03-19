function Get-ShutdownReason(){
<#
.SYNOPSIS
    Retrieves shutdown and unexpected restart events from the Windows Event Log.

.DESCRIPTION
    Queries the System event log for event IDs 41, 1074, 6006, 6605, and 6008
    which indicate shutdowns, restarts, and unexpected power loss events.
    Displays the results as a formatted list.
    This function is only supported on Windows.

.EXAMPLE
    Get-ShutdownReason
#>

    if ($PSVersionTable.PSEdition -ne 'Desktop' -and -not $IsWindows) {
        Write-Error "Get-ShutdownReason is only supported on Windows."
        return
    }

    write-host -f cyan " trying to find the reason of unknown shutdown"
    write-host -f cyan "  let check the eventviewer logs"
    Get-WinEvent -FilterHashtable @{ LogName = 'System'; Id = 41, 1074, 6006, 6605, 6008; } | Format-List Id, LevelDisplayName, TimeCreated, Message

}