function Split-Array{
<#
.SYNOPSIS
    Splits an array into smaller sub-arrays of a specified size.

.DESCRIPTION
    Divides a large array into multiple smaller arrays (chunks) based on the
    provided split size. Returns an array of arrays.

.PARAMETER array
    The source array to split.

.PARAMETER splitsize
    The maximum number of elements per sub-array.

.EXAMPLE
    Split-Array -array @(1..100) -splitsize 25
#>
    param([object[]]$array, [int]$splitsize)

    
    $nrOfArrays = [math]::Ceiling($array.Count / $splitsize)
    [object[]]$returnArrayOfArrays = New-Object object[] $nrOfArrays;

    for ($i = 0; $i -lt $nrOfArrays; $i++) {
    
        $floor = $i * $splitsize
        $ceiling  = $floor + $splitsize-1

        write-verbose " - split nr $($i+1)"
        $returnArrayOfArrays[$i] = $array[$floor..$ceiling]

    }

    return $returnArrayOfArrays
}