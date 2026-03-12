function Get-HWSpecs(
    [string[]]$servers = @()
) {
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