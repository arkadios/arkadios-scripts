function DynamicMenu{
<#
.SYNOPSIS
    Displays an interactive numbered menu and returns the selected value.

.DESCRIPTION
    Presents a numbered list of options to the user in the console. The user selects
    an option by entering its number, and the corresponding value is returned.

.PARAMETER Values
    A string array of menu options to display.

.EXAMPLE
    $choice = DynamicMenu -Values @("Option A","Option B","Option C")
#>
    param([string[]]$Values)
    
    $null = $chosenReturnValue; 
    write-host ""
	write-host "----------------------------------"
    write-host "- Please select option: "
	write-host "-"
	
    $Script:index = 0;
    $options = ($Values | Select-Object @{N="Option";E={++$Script:index; $Script:index; }}, @{N="Value";E={$_;}})

    foreach ($o in $options) {
        write-host "- >" $o.Option "< " $o.Value
    }
	write-host "-"
	write-host "----------------------------------"
    
    $chosenOption = read-host " Option > # < "
    $chosenReturnValue = $($options | ?{$_.Option -eq $chosenOption}).Value

    write-host ""

    return $chosenReturnValue
}