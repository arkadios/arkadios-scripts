function GitInitAndPush {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepoUrl,
        [Parameter(Mandatory = $true)]

        [Parameter(Mandatory = $true)]
        [string]$userName,
        [Parameter(Mandatory = $true)]
        [string]$userEmail
        )

    $currentLocation = Get-Location

    $continue = read-host " (y/N) Are you sure you want to init new git here '$currentLocation'"
    if ($continue -like "y" ) {

        $cmds = @()
        $cmds += "git init"
        $cmds += "git checkout -b main"
        $cmds += "git config user.email `"$userEmail`""
        $cmds += "git config user.name `"$userName`" "
        $cmds += "git add -A"
        $cmds += "git commit -m `"initial add and commit`""
        $cmds += "git remote add origin $RepoUrl"
        $cmds += "git push -u origin main"
        
        foreach ($cmd in $cmds) {
            write-host -f DarkYellow $cmd
            try {

                Invoke-Expression -Command $cmd -ErrorAction Stop;
            }
            catch {
                Write-Error "Failed to execute '$cmd'. Breaking and exiting. "
                return;
            }
        }
        write-host " Git init finished"
        
    }
    else {
        write-warning "Nothing executed"
    }
}