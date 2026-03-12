function Split-Array([object[]]$array, [int]$splitsize){

    
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