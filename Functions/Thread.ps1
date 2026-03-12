function Thread($command, $maxProcessingBatchSize = $((Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors - 1), [string]$Base64EncodedCommand ) {
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