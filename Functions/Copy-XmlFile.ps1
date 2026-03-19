function Copy-XmlFile {
<#
.SYNOPSIS
    Copies an XML file by loading and saving it to a new destination.

.DESCRIPTION
    Loads a source XML file, parses it as XML, and saves it to the destination path.
    This ensures the output is a well-formed XML file.

.PARAMETER SourceXmlFileName
    Path to the source XML file.

.PARAMETER DestinationXmlFileName
    Path where the XML file should be saved.

.PARAMETER WhatIf
    When $true, skips saving and logs a WhatIf message.

.EXAMPLE
    Copy-XmlFile -SourceXmlFileName "template.xml" -DestinationXmlFileName "output.xml"
#>
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
