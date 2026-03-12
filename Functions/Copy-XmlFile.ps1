function Copy-XmlFile {
    Param(
        [Parameter(Mandatory = $True)][string]$SourceXmlFileName, 
        [Parameter(Mandatory = $True)][string]$DestinationXmlFileName, 
        [bool]$WhatIf = $false
    ) 
 

    write-log " Copying template '$SourceXmlFileName' to '$DestinationXmlFileName'"
    $sourceXmlFilePath = $SourceXmlFileName
    $destinationXmlFilePath = $DestinationXmlFileName

    [xml]$sourceXml = Get-Content -Path $sourceXmlFilePath
    
    if ($WhatIf) { write-log -f yellow "   [WhatIf] Changes not commited" }else { $sourceXml.Save($destinationXmlFilePath); start-sleep 3; }
    write-log " Done copy."
}
