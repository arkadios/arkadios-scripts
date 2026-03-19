function Get-Time {
<#
.SYNOPSIS
    Returns the current time as a long time string.

.DESCRIPTION
    Gets the current date/time and returns only the long time string portion
    (e.g. "14:30:05").

.EXAMPLE
    $timestamp = Get-Time
#>
	$time = $null
	# $time += (Get-Date).ToShortDateString();
	# $time += " "
	$time += (Get-Date).ToLongTimeString();
	#$time += "," 
	#$time += (Get-Date).MilliSecond
	return [string]$time;	
}
