function Set-Encoding(
    [string]$input, 
    [System.Text.Encoding]$srcEnc = [System.Text.Encoding]::ASCII,
    [System.Text.Encoding]$dstEnc = [System.Text.Encoding]::UTF8
) {

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