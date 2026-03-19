function Wait-Task {
<#
.SYNOPSIS
    Waits for an async task to complete and returns its result.

.DESCRIPTION
    Blocks until the provided async task's wait handle signals completion,
    then returns the result via GetAwaiter().GetResult(). Useful for awaiting
    .NET async tasks in PowerShell.

.PARAMETER task
    The async task to wait for. Accepts pipeline input.

.EXAMPLE
    $result = $asyncTask | Wait-Task
#>
    param (
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        $task
    )

    process {
        while (-not $task.AsyncWaitHandle.WaitOne(200)) { }
        $task.GetAwaiter().GetResult()
    }
}