
function DoesPropertyExists([string]$WantedPropertyName, $ObjectToLookIn){
<#
.SYNOPSIS
    Checks if a property with a given name exists on an object.

.DESCRIPTION
    Inspects the PSObject properties of the provided object and returns $true
    if a property matching the specified name is found, $false otherwise.

.PARAMETER WantedPropertyName
    The name of the property to search for.

.PARAMETER ObjectToLookIn
    The object to inspect for the property.

.EXAMPLE
    DoesPropertyExists -WantedPropertyName "Name" -ObjectToLookIn $myObject
#>
	
	[bool]$returnValue=$false
	
	if($ObjectToLookIn){
		[String[]]$allProperties = $ObjectToLookIn.PSObject.Properties | select Name
		$foundProperty = $($allProperties -match "$WantedPropertyName")
		$returnValue = ![string]::IsNullOrEmpty($foundProperty)
	}
	else
	{
		write-error "[DoesPropertyExists] Empty object not accepted!"
	}
	
	return $returnValue
}