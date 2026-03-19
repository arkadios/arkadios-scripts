function Get-PortProcessListener {
<#
.SYNOPSIS
    Identifies which process is listening on a specified port.

.DESCRIPTION
    Checks both TCP and UDP endpoints for the given port number and displays
    the owning process details for each protocol.

.PARAMETER PortNumber
    The port number to look up.

.EXAMPLE
    Get-PortProcessListener -PortNumber 443
#>
    param (
        [Parameter(Mandatory = $true)]
        [int]$PortNumber
    )

    if ($PSVersionTable.PSEdition -ne 'Desktop' -and -not $IsWindows) {
        Write-Error "Get-PortProcessListener is only supported on Windows (requires Get-NetTCPConnection/Get-NetUDPEndpoint)."
        return
    }

    # TCP
    write-host -f cyan " === TCP === "
    $owningProcTCP = (Get-NetTCPConnection -LocalPort $PortNumber -ErrorAction SilentlyContinue).OwningProcess
    if($owningProcUDP){
        Get-Process -Id $owningProcTCP;
    }
    else {
        write-host -f Yellow " No owning process found for TCP port $PortNumber"
    }

    # UDP
    write-host -f cyan " === UDP === "
    
    $owningProcUDP = (Get-NetUDPEndpoint -LocalPort $PortNumber -ErrorAction SilentlyContinue).OwningProcess 
    if($owningProcUDP){
        Get-Process -Id $owningProcUDP;
    }
    else {
        write-host -f Yellow " No owning process found for UDP port $PortNumber"
    }
}