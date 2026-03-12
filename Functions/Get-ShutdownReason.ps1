function Get-ShutdownReason(){

    write-host -f cyan " trying to find the reason of unknown shutdown"
    write-host -f cyan "  let check the eventviewer logs"
    Get-WinEvent -FilterHashtable @{ LogName = 'System'; Id = 41, 1074, 6006, 6605, 6008; } | Format-List Id, LevelDisplayName, TimeCreated, Message

}