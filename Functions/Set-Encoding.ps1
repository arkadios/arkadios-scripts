function Set-Encoding(
    [string]$input,
    [System.Text.Encoding]$srcEnc = [System.Text.Encoding]::ASCII,
    [System.Text.Encoding]$dstEnc = [System.Text.Encoding]::UTF8
) {
<#
.SYNOPSIS
    Converts a string from one encoding to another.

.DESCRIPTION
    Takes an input string, converts it from the source encoding to the destination
    encoding using System.Text.Encoding.Convert, and returns the re-encoded string.

.PARAMETER input
    The string to convert.

.PARAMETER srcEnc
    The source encoding. Defaults to ASCII.

.PARAMETER dstEnc
    The destination encoding. Defaults to UTF8.

.EXAMPLE
    Set-Encoding -input "Hello" -srcEnc ([System.Text.Encoding]::ASCII) -dstEnc ([System.Text.Encoding]::UTF8)
#>

    write-log "Input is '$input'";
    write-log "Changing encoding from '$($srcEnc.ToString())' to '$($dstEnc.ToString())' ";
    
    $srcBytes = $srcEnc.GetBytes($input);
    try {
    
        $dstBytes = [System.Text.Encoding]::Convert($srcEnc, $dstEnc, $srcBytes);
    
        $stringOutput = $dstEnc.GetString($dstBytes);
    }
    catch {
        $stringOutput = $null;
    }
    return $stringOutput
}