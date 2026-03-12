
function GenerateHMACSHA256([string]$message, [string]$key){
    #$message = 'Message'
    #$secret = 'secret'

    
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
    $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($key)
    
    # encrypt
    $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
    $signature = [Convert]::ToBase64String($signature)

    Write-host "Output as base64 string: $signature" 
    Write-Output $signature
}

