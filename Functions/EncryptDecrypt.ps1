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
    $returnValue = $null
	
    $returnValue = ConvertTo-SecureString $EncryptedString -Key $encryptionkey 
    if ($clip) { $returnValue | clip; write-host -f cyan "It's in your clipboard"; }

    return $returnValue	
}

function EncryptedStringToPlainText([string]$EncryptedString, [switch]$clip) {
    $SecString = DecryptSecureString -EncryptedString $EncryptedString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecString)
    $returnValue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) 
    # Write-Host -f cyan "Value in plain text between 'single quotes' -> '$PlainString'"
    if ($clip) { $returnValue | clip; write-host -f cyan "It's in your clipboard"; }

    return $returnValue

}