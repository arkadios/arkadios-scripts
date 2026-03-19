function ConvertToBase64String(){
<#
.SYNOPSIS
    Converts a string to its Base64-encoded representation.

.DESCRIPTION
    Takes a string input (including from pipeline) and converts it to a Base64 string
    using the default system encoding. Optionally copies the result to the clipboard.

.PARAMETER StringToConvert
    The string to encode as Base64. Accepts pipeline input.

.PARAMETER clip
    When $true, copies the result to the clipboard.

.PARAMETER WhatIf
    When $true, performs a dry run (no actual conversion).

.EXAMPLE
    "Hello World" | ConvertToBase64String

.EXAMPLE
    ConvertToBase64String -StringToConvert "Secret" -clip $true
#>
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline = $True, Mandatory = $True)]
        [string]$StringToConvert,
        [bool]$clip, 
        [bool]$WhatIf)

        begin{
            write-verbose " - ConvertToBase64String started"
            $base64AsString = $null;
        }
        process{
            write-verbose " - Converting '$StringToConvert'"
            $base64AsString = [System.Convert]::ToBase64String([System.Text.Encoding]::Default.GetBytes($StringToConvert));
            if($clip) {$base64AsString | clip;}
        }
        end{
            write-verbose " - Value converted '$base64AsString'"
            return $base64AsString;
            write-verbose " - End"
        }
}
