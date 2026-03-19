function Add-ComputerAsTrustedLocation(){
<#
.SYNOPSIS
    Adds a computer name to the IE/Edge trusted locations zone map.

.DESCRIPTION
    Registers a computer name in the current user's Internet Settings ZoneMap registry
    under the Domains key, enabling file, http, and https protocols as trusted (Zone 1).
    Skips entries that contain a colon (i.e. already qualified paths).

.PARAMETER ComputerName
    The computer/server name to add as a trusted location.

.EXAMPLE
    Add-ComputerAsTrustedLocation -ComputerName "SERVER01"
#>
	param(
		[string]$ComputerName
	)
	if($ComputerName -notcontains ":"){

		write-log "  Adding '$ComputerName' to Domains zonemap of Internet Settings to trust that location..."
		$ieSettingRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$ComputerName";

		if (-not (Test-Path -Path $ieSettingRegPath -ErrorAction SilentlyContinue))
		{    
			New-Item -Path $ieSettingRegPath -ErrorAction SilentlyContinue
		}

		Set-ItemProperty -Path $ieSettingRegPath -Name file -Value 1 -ErrorAction SilentlyContinue
		Set-ItemProperty -Path $ieSettingRegPath -Name http -Value 1 -ErrorAction SilentlyContinue
		Set-ItemProperty -Path $ieSettingRegPath -Name https -Value 1 -ErrorAction SilentlyContinue
	}
}
