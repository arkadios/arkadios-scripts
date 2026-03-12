function Get-CharIntArray($rawValue) {
    $datearray = @()
    for ($i = 0; $i -lt $rawValue.Length; $i++) { $datearray += [int][char]$rawValue[$i] }					
    return $datearray
}