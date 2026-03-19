function Get-CharIntArray{
<#
.SYNOPSIS
    Converts a string into an array of integer character codes.

.DESCRIPTION
    Iterates through each character in the input string and returns an array
    of their integer (ASCII/Unicode) values.

.PARAMETER rawValue
    The string to convert to an integer array.

.EXAMPLE
    Get-CharIntArray -rawValue "ABC"
    Returns @(65, 66, 67)
#>
    param($rawValue)
    $datearray = @()
    for ($i = 0; $i -lt $rawValue.Length; $i++) { $datearray += [int][char]$rawValue[$i] }					
    return $datearray
}