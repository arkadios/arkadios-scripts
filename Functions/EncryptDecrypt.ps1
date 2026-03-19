<#
execute:
# EXAMPLE TO EnCRYPT
."EncryptDecrypt.ps1"
EncryptSecureString -stringToEncryptOrDecrypt "stringToEncryptOrDecrypt" -Clip 


# EXAMPLE TO DECRYPT
."EncryptDecrypt.ps1"
$inputValue = read-host "paste encrypted string here"
EncryptedStringToPlainText $inputValue
#>

$script:encryptionkey = (13, 74, 2, 3, 56, 34, 5235, 22, 77, 71, 2, 223, 42, 54, 3, 233, 1, 4, 12, 7, 62, 53, 35, 43)



function EncryptDecrypt([string]$stringToEncryptOrDecrypt, [switch]$encrypt, [switch]$decrypt, [switch]$clip) {
<#
.SYNOPSIS
    Encrypts or decrypts a string using a symmetric key.

.DESCRIPTION
    Uses ConvertTo-SecureString / ConvertFrom-SecureString with a predefined encryption
    key to encrypt a plain text string or decrypt an encrypted string. Optionally copies
    the result to the clipboard.

.PARAMETER stringToEncryptOrDecrypt
    The string to encrypt or decrypt.

.PARAMETER encrypt
    Switch to encrypt the input string.

.PARAMETER decrypt
    Switch to decrypt the input string.

.PARAMETER clip
    Switch to copy the result to the clipboard.

.EXAMPLE
    EncryptDecrypt -stringToEncryptOrDecrypt "MySecret" -encrypt -clip

.EXAMPLE
    EncryptDecrypt -stringToEncryptOrDecrypt $encryptedValue -decrypt
#>
    $returnValue = $null

    if ($encrypt) {
        $ss = ConvertTo-SecureString $stringToEncryptOrDecrypt -AsPlainText -Force 

        $returnValue = ConvertFrom-SecureString $ss -Key $encryptionkey 
        if ($clip) { $returnValue | clip; write-host -f cyan "It's in your clipboard"; }

	}
	else{
		if($decrypt){
            $returnValue = EncryptedStringToPlainText -EncryptedString $stringToEncryptOrDecrypt 
            if ($clip) { $returnValue | clip; write-host -f cyan "It's in your clipboard"; }
		}

	}
    return $returnValue	
}

function DecryptSecureString([string]$EncryptedString, [switch]$clip) {
<#
.SYNOPSIS
    Decrypts an encrypted string back to a SecureString object.

.PARAMETER EncryptedString
    The encrypted string to convert back to a SecureString.

.PARAMETER clip
    Switch to copy the result to the clipboard.
#>
    $returnValue = $null
	
    $returnValue = ConvertTo-SecureString $EncryptedString -Key $encryptionkey 
    if ($clip) { $returnValue | clip; write-host -f cyan "It's in your clipboard"; }

    return $returnValue	
}

function EncryptedStringToPlainText([string]$EncryptedString, [switch]$clip) {
<#
.SYNOPSIS
    Converts an encrypted string to plain text.

.PARAMETER EncryptedString
    The encrypted string to convert to plain text.

.PARAMETER clip
    Switch to copy the result to the clipboard.
#>
    $SecString = DecryptSecureString -EncryptedString $EncryptedString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecString)
    $returnValue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) 
    # Write-Host -f cyan "Value in plain text between 'single quotes' -> '$PlainString'"
    if ($clip) { $returnValue | clip; write-host -f cyan "It's in your clipboard"; }

    return $returnValue

}