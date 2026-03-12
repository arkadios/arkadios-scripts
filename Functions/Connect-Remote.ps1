function Connect-Remote {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]$ComputerName,
        [switch]$Enter
    )
    
    begin {
        $cred = Get-Credential
        $session = New-PSSessionOption
        $session.SkipCACheck = $true

    }
    
    process {
        
        $Global:newSession = New-PSSession -ComputerName $ComputerName -Credential $cred -UseSSL -Authentication Negotiate -Name 1 -SessionOption $session

        if($Global:newSession -and $Enter){
            Enter-PSSession $Global:newSession; 
        }

    }
    
    end {
        if(-not $Enter) { return $Global:newSession}
    }
}