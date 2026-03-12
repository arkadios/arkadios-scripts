function Get-PortProcessListener {
    param (
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [int]$PortNumber
    )
    
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