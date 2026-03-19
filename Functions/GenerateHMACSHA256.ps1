function GenerateHMACSHA256([string]$message, [string]$key){
<#
.SYNOPSIS
    Generates an HMAC-SHA256 signature for a message using a secret key.

.DESCRIPTION
    Computes an HMAC-SHA256 hash of the provided message using the specified key.
    Returns the signature as a Base64-encoded string.

.PARAMETER message
    The message string to sign.

.PARAMETER key
    The secret key used for HMAC computation.

.EXAMPLE
    GenerateHMACSHA256 -message "Hello" -key "mysecret"
#>
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

