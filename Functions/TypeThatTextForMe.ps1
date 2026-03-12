function TypeThatTextForMe ([string] $textToType, [int]$WaitBeforeTypingInSeconds=5, [int]$delayInMillisecondsBetweenStrkes=1) { 
    sleep $WaitBeforeTypingInSeconds; 
    $textToType.ToCharArray() | ForEach-Object { [System.Windows.Forms.SendKeys]::SendWait($_); Start-Sleep -Milliseconds $delayInMillisecondsBetweenStrkes; }; 
    
}