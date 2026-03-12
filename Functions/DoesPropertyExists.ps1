
function DoesPropertyExists([string]$WantedPropertyName, $ObjectToLookIn){
	<#
		.DESCRIPTION
		This a function that can be called to check if a property with a certain name is available within an object. That object and property name must be provided as input!
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