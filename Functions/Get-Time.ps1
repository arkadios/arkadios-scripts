function Get-Time 
{
	$time = $null
	# $time += (Get-Date).ToShortDateString();
	# $time += " "
	$time += (Get-Date).ToLongTimeString();
	#$time += "," 
	#$time += (Get-Date).MilliSecond
	return [string]$time;	
}
