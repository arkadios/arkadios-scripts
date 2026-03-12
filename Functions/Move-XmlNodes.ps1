function Move-XmlNodes {
    
    Param(
        [Parameter(Mandatory = $True)][string]$SourceXmlFileName, 
        [Parameter(Mandatory = $True)][string]$DestinationXmlFileName, 
        [Parameter(Mandatory = $True)][string]$XPath, 
        [Parameter(Mandatory = $True)][string]$IdentifyingPropertyName, 
        [string]$XmlNamespace, 
        [bool]$WhatIf = $false
    )
    
    
    <#
        .DESCRIPTION
        move and overwrite
        find xmlnode(s) and move* all nodes from SourceXml to the DestingationXml
        *move means that those nodes will be deleted in the SourceXml
    #>

    write-log " Finding and moving nodes from source to new destination."

    <# for test purposes 
    $SourceXmlFileName = "icp_provisioning_template_Lists"
    $DestinationXmlFileName = "icp_provisioning_template_Lists"
    $XPath = "//pnp:ListInstance"
    #>

    $sourceXmlFilePath = $SourceXmlFileName
    $destinationXmlFilePath = $DestinationXmlFileName

    [xml]$sourceXml = Get-Content -Path $sourceXmlFilePath
    [xml]$destinationXml = Get-Content -path $destinationXmlFilePath

    write-log "  Processing template '$SourceXmlFileName'"
    
    $fieldNodes = $sourceXml | Select-Xml -XPath $XPath -Namespace $XmlNamespace
    if ($fieldNodes) {
        
        write-log "  Nodes found for '$XPath'"
        write-log "  Copying (and overwriting) nodes to/in '$DestinationXmlFileName'"
        
        $totalNodes = $fieldNodes.Count
        $counter = 0
        foreach ($node in $fieldNodes) {
            
            # parent node should be the same in both files
            $parentName = $node.Node.ParentNode.Name

            # dynamically find parent node 
            $destParentNodeInfo = $destinationXml | select-xml -Namespace $XmlNamespace -XPath "//$parentName"
            
            $counter++
            write-log "   '$counter/$totalNodes' Processing '$($node.Pattern)'"
            
            $existingNodeInDestination = $null
            if ($fieldNodes.Count -gt 1) {
                
                $existingNodeInDestination = $destinationXml | Select-Xml -XPath "$($node.Pattern)[@$IdentifyingPropertyName='$($node.Node.$IdentifyingPropertyName)']" -Namespace $XmlNamespace
            }
            else {
                $existingNodeInDestination = $destinationXml | Select-Xml -XPath $node.Pattern -Namespace $XmlNamespace
            }
            
            if ($existingNodeInDestination) {
                
                write-log -f yellow "   Existing child node found, replacing '$($existingNodeInDestination.Pattern)'"
                $null = $destParentNodeInfo.Node.RemoveChild($existingNodeInDestination.Node)
                $null = $destParentNodeInfo.Node.AppendChild($destinationXml.ImportNode($node.Node, $true))
                
            }
            else {
                write-log "   Adding new node to xml. DisplayName '$($node.Pattern)'"
                $null = $destParentNodeInfo.Node.AppendChild($destinationXml.ImportNode($node.Node, $true)) 
            }

            # we have copied node, so now we remove it from the source
            write-log "   Deleting '$($node.Pattern)' from source xml."
            $null = $node.Node.ParentNode.RemoveChild($node.Node);
        }
    
        # save xml
        if ($WhatIf) { write-log -f yellow "[WhatIf] Changes not commited" }else { $sourceXml.Save($sourceXmlFilePath); start-sleep 3 }
        if ($WhatIf) { write-log -f yellow "[WhatIf] Changes not commited" }else { $destinationXml.Save($destinationXmlFilePath); start-sleep 3 }
    }
    else {
        # add
        write-log "  No xml nodes found for xpath '$XPath'"
        write-log "  Nothing to process for '$DestinationXmlFileName'"
    }
    write-log " Done moving nodes." 
}
