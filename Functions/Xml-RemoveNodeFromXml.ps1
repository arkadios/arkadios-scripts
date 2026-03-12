function Xml-RemoveNodeFromXml {
    Param (
        [Parameter(Mandatory = $True)][string]$SourceXmlFileName, 
        [Parameter(Mandatory = $True)][string]$XPath, 
        [switch]$SaveChanges, 
        [string]$XmlNamespace, 
        [bool]$WhatIf = $false
    )
        
    write-log " Removing nodes based on xpath"
    write-log "  Processing template '$SourceXmlFileName'"
    write-log "  XPath = '$XPath'"

    $sourceXmlFilePath = $SourceXmlFileName

    [xml]$sourceXml = Get-Content -Path $sourceXmlFilePath

    $fieldNodes = $sourceXml | Select-Xml -XPath $XPath -Namespace $XmlNamespace

    if ($fieldNodes) {
        # removing all exported nodes from original
        
        $fieldNodes | ForEach-Object { 
            write-log "   Removing node $($_.Pattern)";
            $_.Node.ParentNode.RemoveChild($_.Node);
        }
    }
    else {
        write-log "  Nothing found. Nothing to remove."
    }
    
    
    if ($SaveChanges -and -not $WhatIf) {
        $sourceXml.Save($sourceXmlFilePath)
        write-log " Xml saved"
        start-sleep 3
    }

    write-log " Done removing nodes."

}
