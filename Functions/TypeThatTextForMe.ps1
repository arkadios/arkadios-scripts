function TypeThatTextForMe {
<#
.SYNOPSIS
    Simulates keyboard typing of a given text string.

.DESCRIPTION
    Waits for a specified number of seconds, then sends each character of the
    provided text using System.Windows.Forms.SendKeys with a configurable delay
    between keystrokes. Useful for automating text input into applications that
    don't support paste.

.PARAMETER textToType
    The text string to type out.

.PARAMETER WaitBeforeTypingInSeconds
    Seconds to wait before typing begins. Defaults to 5.

.PARAMETER delayInMillisecondsBetweenStrkes
    Milliseconds to wait between each keystroke. Defaults to 1.

.EXAMPLE
    TypeThatTextForMe -textToType "Hello World" -WaitBeforeTypingInSeconds 3
#>
    param([string] $textToType, [int]$WaitBeforeTypingInSeconds=5, [int]$delayInMillisecondsBetweenStrkes=1)
    if ($PSVersionTable.PSEdition -ne 'Desktop' -and -not $IsWindows) {
        Write-Error "TypeThatTextForMe is only supported on Windows (requires System.Windows.Forms)."
        return
    }
    sleep $WaitBeforeTypingInSeconds; 
    $textToType.ToCharArray() | ForEach-Object { [System.Windows.Forms.SendKeys]::SendWait($_); Start-Sleep -Milliseconds $delayInMillisecondsBetweenStrkes; }; 
    
}