function IncrementalSync($Source, $Destination){
	write-log -f cyan "Starting incremental sync process"," for: '$Source'"," to '$Destination'" 
	xcopy $Source $Destination /c /s /e /r /h /d /y /x
	$Dt = Get-Date
	write-log -f cyan "Incremental sync process has completed at $Dt" 
}
