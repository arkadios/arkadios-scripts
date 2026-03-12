function Update-XmlContent {
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
