

$Global:TeamsConnection = $null
function ConnectToTeams() {
    $Global:TeamsConnection = "";
}
function CreateNewTeamsPost([string[]]$MSGs, [bool]$IsError) {

}
function WriteToTeams([string[]]$MSGs, [bool]$IsError) {

}

function Write-Teams {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False,
            ValueFromPipeline = $True,
            ValueFromPipelinebyPropertyName = $True,
            HelpMessage = "Provide a message as a string (array).")]
        [string[]]$Messages, 
        [bool]$IsError = $False
    )
    BEGIN {
        # connect to Teams if no existing connection is found (within this session)
        if (-not $Global:TeamsConnection) {
            # ConnectToTeams
        }
    }
    PROCESS {

        # WriteToTeams $Messages $IsError 
        Write-Warning " NOT IMPLEMENTED "
    
    }
}