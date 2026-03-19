function OpenTCPConnections(){
<#
.SYNOPSIS
    Displays all established TCP connections with process and DNS details.

.DESCRIPTION
    Retrieves all TCP connections in the Established state and displays local address,
    local port, resolved remote hostname, remote address, remote port, state, owning
    process path, offload state, and creation time in a formatted table.

.EXAMPLE
    OpenTCPConnections
#>

    if ($PSVersionTable.PSEdition -ne 'Desktop' -and -not $IsWindows) {
        Write-Error "OpenTCPConnections is only supported on Windows (requires Get-NetTCPConnection)."
        return
    }

    Get-NetTCPConnection -State Established |Select-Object -Property LocalAddress, LocalPort,@{name='RemoteHostName';expression={(Resolve-DnsName $_.RemoteAddress).NameHost}},RemoteAddress, RemotePort, State,@{name='ProcessName';expression={(Get-Process -Id $_.OwningProcess). Path}},OffloadState,CreationTime |ft

}