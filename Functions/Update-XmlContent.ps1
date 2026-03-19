function Update-XmlContent {
<#
.SYNOPSIS
    Performs a string find-and-replace in an XML file.

.DESCRIPTION
    Reads an XML file as raw text, replaces all occurrences of the specified string,
    and writes the modified content back as UTF-8 encoded file.

.PARAMETER SourceXmlFileName
    Path to the XML file to modify.

.PARAMETER StringToReplace
    The string to find in the file content.

.PARAMETER ReplacingValue
    The replacement string.

.PARAMETER WhatIf
    When $true, performs a dry run (not currently implemented in logic).

.EXAMPLE
    Update-XmlContent -SourceXmlFileName "config.xml" -StringToReplace "oldValue" -ReplacingValue "newValue"
#>
    Param(
        [Parameter(Mandatory = $True)][string]$SourceXmlFileName, 
        [Parameter(Mandatory = $True)][string]$StringToReplace, 
        [Parameter(Mandatory = $True)][string]$ReplacingValue, 
        [bool]$WhatIf = $false) 

    $templateContent = Get-Content -Path $SourceXmlFileName -Encoding UTF8 -Raw 
    if ($templateContent) {
        remove-item -Path $SourceXmlFileName
    }
    $templateContent = $templateContent.Replace($StringToReplace, $ReplacingValue);
    $templateContent | Out-File -FilePath $SourceXmlFileName -Encoding UTF8 -Force -NoClobber

}
