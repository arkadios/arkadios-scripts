function Get-HWSpecs(
    [string[]]$servers = @()
) {
<#
.SYNOPSIS
    Retrieves hardware specifications (CPU, RAM, disk) from remote servers.

.DESCRIPTION
    Connects to one or more remote servers via Invoke-Command and collects CPU count,
    RAM (GB), and disk usage (used/free in GB). Displays results in a formatted table,
    copies to clipboard, and shows summary totals.

.PARAMETER servers
    An array of server names to query. If empty, prompts for comma-separated input.

.EXAMPLE
    Get-HWSpecs -servers @("Server01","Server02")
#>
    if ($PSVersionTable.PSEdition -ne 'Desktop' -and -not $IsWindows) {
        Write-Error "Get-HWSpecs is only supported on Windows (requires WMI)."
        return
    }

    $results = @();

    if ($null -eq $servers -or $servers.Count -le 0) {
        $serverInput = read-host "Provide an array of server to check (comman separated)"
        $servers = $serverInput -split ','
    }
	
	if (-not $servers) { write-log -b red "Servers list is empty, exiting script." } 
	else {
        write-log " counting '$($servers.count)' servers"
        foreach ($server in $servers) {
            write-log "  reading '$server'..." 
            $results += Invoke-Command -ComputerName $server { 
                $free = $(Get-PSDrive | measure -Property "Free" -sum).Sum / 1GB
                $used = $(Get-PSDrive | measure -Property "Used" -sum).Sum / 1GB
				
                $cpuCount = $(Get-WmiObject Win32_processor | measure).Count;
                $ramCount = $(Get-WmiObject win32_physicalmemory | measure -Property Capacity -Sum).Sum / 1GB
                $json = @{Used = $used; Free = $free; Server = $env:computername; CPU = $cpuCount; RAM = $ramCount } 
                return $($json);
            } | convertto-json;
			
		
        }
        write-log ""
        if ($results) {
            $results | ConvertFrom-Json | ft
            $results | ConvertFrom-Json | ft | clip
            write-log " "
            write-log " result table copied to clipboard"
            write-log " summary are:"
            write-log " " 
            $results | ConvertFrom-Json | Measure-Object -Property Used, Free, CPU, RAM -Sum
            write-log "" 
            write-log "the end"
        }
        else {
            write-log " no results :("
        }
		
    }
}