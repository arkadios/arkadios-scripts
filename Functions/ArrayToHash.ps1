[CmdletBinding]
function ArrayToHash {
<#
.SYNOPSIS
    Converts an array to a hashtable.

.DESCRIPTION
    Takes an array (including from the pipeline) and converts it into a hashtable
    where each element is both the key and value.

.PARAMETER myArray
    The input array to convert. Accepts pipeline input.

.EXAMPLE
    @("a","b","c") | ArrayToHash
#>
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline)]
        $myArray
    )
    
    $hash = @{}
    $myArray | ForEach-Object { $hash[$_] += $_ }
    return $hash
}