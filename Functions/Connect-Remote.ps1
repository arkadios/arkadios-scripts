function Connect-Remote {
<#
.SYNOPSIS
    Creates a remote PowerShell session to a computer over SSL.

.DESCRIPTION
    Prompts for credentials and establishes a new PSSession to the specified computer
    using SSL and Negotiate authentication. Optionally enters the session interactively
    with the -Enter switch, or returns the session object.

.PARAMETER ComputerName
    The remote computer name to connect to.

.PARAMETER Enter
    When specified, immediately enters the interactive remote session.

.EXAMPLE
    Connect-Remote -ComputerName "SERVER01"

.EXAMPLE
    Connect-Remote -ComputerName "SERVER01" -Enter
#>
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