function Remove-XmlNode {
<#
.SYNOPSIS
    Removes XML nodes matching an XPath expression from an XML file.

.DESCRIPTION
    Loads an XML file, finds all nodes matching the provided XPath expression,
    removes them from the document, and optionally saves the changes.

.PARAMETER SourceXmlFileName
    Path to the XML file to process.

.PARAMETER XPath
    The XPath expression to select nodes for removal.

.PARAMETER SaveChanges
    When specified, saves the modified XML back to disk.

.PARAMETER XmlNamespace
    Optional XML namespace hashtable for XPath queries.

.PARAMETER WhatIf
    When $true, skips saving changes to disk.

.EXAMPLE
    Remove-XmlNode -SourceXmlFileName "config.xml" -XPath "//OldNode" -SaveChanges
#>
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
