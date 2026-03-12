[CmdletBinding]
function ArrayToHash {
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline)]
        $myArray
    )
    
    $hash = @{}
    $myArray | ForEach-Object { $hash[$_] += $_ }
    return $hash
}