function DynamicMenu([string[]]$Values){
    
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