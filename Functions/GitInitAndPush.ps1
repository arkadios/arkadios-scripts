function GitInitAndPush {
<#
.SYNOPSIS
    Initializes a new Git repository in the current directory and pushes it to a remote.

.DESCRIPTION
    Initializes a new Git repository in the current working directory, configures user
    identity, creates an initial commit with all files, and pushes to the specified remote
    repository. Prompts for confirmation before executing.

    The following steps are performed in order:
    1. git init
    2. git checkout -b main
    3. git config user.email / user.name
    4. git add -A
    5. git commit -m "initial add and commit"
    6. git remote add origin <RepoUrl>
    7. git push -u origin main

    Execution stops immediately if any step fails.

.PARAMETER RepoUrl
    The remote repository URL to add as origin (e.g. https://github.com/user/repo.git).

.PARAMETER userName
    The Git user name to configure for this repository.

.PARAMETER userEmail
    The Git user email to configure for this repository.

.EXAMPLE
    GitInitAndPush -RepoUrl "https://github.com/user/repo.git" -userName "John" -userEmail "john@example.com"

    Initializes git in the current directory and pushes to the specified GitHub repository.
#>
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