function Thread{
<#
.SYNOPSIS
    Runs a PowerShell command as a background process with throttling.

.DESCRIPTION
    Starts a new pwsh.exe background process with a Base64-encoded command. Manages
    a global pool of running threads and waits for an available slot when the maximum
    batch size is reached. The default batch size is the number of logical processors minus one.

.PARAMETER command
    The PowerShell command string to execute. Will be Base64-encoded automatically.

.PARAMETER maxProcessingBatchSize
    Maximum number of concurrent background processes. Defaults to logical processor count minus 1.

.PARAMETER Base64EncodedCommand
    An already Base64-encoded command string. If provided, skips encoding of the command parameter.

.EXAMPLE
    Thread -command "Get-Process | Out-File C:\temp\procs.txt"
#>
    param($command, $maxProcessingBatchSize, [string]$Base64EncodedCommand )

    if ($PSVersionTable.PSEdition -ne 'Desktop' -and -not $IsWindows) {
        Write-Error "Thread is only supported on Windows (requires Win32_ComputerSystem CIM)."
        return
    }

    if (-not $maxProcessingBatchSize) {
        $maxProcessingBatchSize = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors - 1
    }

    $counter++;
            
    if (-not $Global:runningThreads -or ($Global:runningThreads).Count -eq 0) { 
        $waitForJobsToFinish = $false; $Global:runningThreads = @(); 
    }
    else {
        $waitForJobsToFinish = ($Global:runningThreads | ? { $null -eq $_.ExitCode }).Count -ge $maxProcessingBatchSize;
        $waitingTime = 0;
        if ($waitForJobsToFinish) { write-host "  Waiting for available slot " }
        while ($waitForJobsToFinish -and $waitingTime -lt 3600) {
            $waitingTime += 30;
            Start-Sleep -Seconds 30; 
            write-host " - $waitingTime sec" # -NoNewline;
            $Global:runningThreads.Refresh(); 
            $waitForJobsToFinish = ($Global:runningThreads | ? { $null -eq $_.ExitCode }).Count -ge $maxProcessingBatchSize;
        }
        write-host "."
    }
    # add this array to the jobs 

    if (-not $Base64EncodedCommand) {
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
    }
    else {
        $encodedCommand = $Base64EncodedCommand
    }
    # passthru is belangrijk voor deze  
    write-host "  Starting new background job "
    # $Global:runningThreads += start-process powershell.exe -PassThru -ArgumentList "-encodedCommand","$encodedCommand";
    $Global:runningThreads += start-process pwsh.exe  -PassThru -ArgumentList "-encodedCommand", "$encodedCommand";
    
}